additional_tags = {}

# EKS
cluster_name                     = "eks"
cluster_version                  = "1.20"
node_group_default_instance_type = "m5.large"
node_group_desired_capacity      = 1
node_group_min_capacity          = 1
node_group_max_capacity          = 3

# arn thag can assume the eks developer role
assume_developer_role = []

# arn thag can assume the eks admin role
assume_admin_role = []
