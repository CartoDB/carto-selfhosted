variable "tags" {
  description = "Tags assigned to all the resources"
  type        = map(string)
  default = {
    Product = "Carto"
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "node_group_default_instance_type" {
  description = "Default EC2 instance type for the node group"
  type        = string
  default     = "m5.large"
}

variable "node_group_desired_capacity" {
  description = "The desired number of EC2 instances in the node group"
  type        = string
  default     = "1"
}

variable "node_group_min_capacity" {
  description = "The minimum number of EC2 instances in the node group at a given time"
  type        = string
  default     = "1"
}

variable "node_group_max_capacity" {
  description = "The maximum number of EC2 instances in the node group at a given time. Used when auto scaling is enabled"
  type        = string
  default     = "3"
}

variable "assume_developer_role" {
  description = "A list of ARN's of users/roles that can assume the cluster_developer role"
  type        = list(string)
  default     = [""]
}

variable "assume_admin_role" {
  description = "A list of ARN's of users/roles that can assume the cluster_admin role"
  type        = list(string)
  default     = [""]
}