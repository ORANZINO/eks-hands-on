project                         = "onboarding" # between / storyplay / hellobot / master / onboarding
env                             = "dev"     # dev / staging / prod
owner                           = "dachan.choi"
region                          = "ap-northeast-2"

############### VPC
vpc_id                          = "vpc-"
eks_subnet_ids                  = [ "subnet-", "subnet-"]
azs                             = [ "ap-northeast-2a", "ap-northeast-2c" ]

############### EKS Cluster
cluster_version                 = "1.22"
enable_irsa                     = true
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = true
cluster_addons = {
  coredns = { resolve_conflicts = "OVERWRITE" }
  kube-proxy = {}
  vpc-cni = { resolve_conflicts = "OVERWRITE" }
  aws-ebs-csi-driver = {}
}

create_cloudwatch_log_group     = false
############### EKS NodeGroup
eks_managed_node_group_defaults = {
  ami_type                   = "AL2_x86_64"
  use_name_prefix            = false
  instance_types             = ["t3.large", "t3a.large"]
  iam_role_attach_cni_policy = true
  capacity_type              = "ON_DEMAND"
  create_iam_role          = false
  iam_role_use_name_prefix = false

}
node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
}

builders_node = {
    min_size                 = 1
    max_size                 = 10
    desired_size             = 1
}
workers_node = {
    min_size                 = 1
    max_size                 = 10
    desired_size             = 1
    instance_types           = ["t3.large"]
}

############### IAM
trusted_role_services = ["ec2.amazonaws.com"]
custom_role_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
]
additional_policy_actions = [
  "ec2:*",
  "elasticloadbalancing:*",
  "iam:ListServerCertificates",
  "iam:GetServerCertificate",
]

tags     = {}
