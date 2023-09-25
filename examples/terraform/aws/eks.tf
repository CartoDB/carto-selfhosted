locals {
  cluster_name = "${var.cluster_name}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnets         = module.vpc.private_subnets
  map_roles       = local.role_map_users

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.node_group_default_instance_type
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = var.node_group_desired_capacity
      asg_max_size                  = var.node_group_max_capacity
      asg_min_size                  = var.node_group_min_capacity
    },
    {
      name                          = "worker-group-2"
      instance_type                 = var.node_group_default_instance_type
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = var.node_group_desired_capacity
      asg_max_size                  = var.node_group_max_capacity
      asg_min_size                  = var.node_group_min_capacity
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}