data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# data "template_file" "autoscaler" {
#   template = file("templates/eks_cluster_autoscaler.sh")
#   vars = {
#     CLUSTERNAME     = module.eks.cluster_id
#     AUTOSCALER_ROLE = module.cluster_autoscaler_irsa_role.iam_role_arn
#   }
# }
