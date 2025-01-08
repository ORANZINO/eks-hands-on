resource "local_file" "cluster_autoscaler_sh" {
    content  = <<-EOT
#0. Metric Server 설치 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
#Cluster Autoscaler 배포
#1. ekstcl 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

#2. ServiceAccount 와 IAM Role 연결
eksctl create iamserviceaccount \
--cluster=${module.eks.cluster_id} \
--namespace=kube-system \
--name=cluster-autoscaler \
--attach-role-arn=${module.cluster_autoscaler_irsa_role.iam_role_arn} \
--override-existing-serviceaccounts \
--region=${var.region} \
--approve

#3. Cluster Autoscaler 배포
curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
sed -i s/'<YOUR CLUSTER NAME>'/${module.eks.cluster_id}/g cluster-autoscaler-autodiscover.yaml
kubectl apply -f cluster-autoscaler-autodiscover.yaml
kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=${module.cluster_autoscaler_irsa_role.iam_role_arn}
kubectl patch deployment cluster-autoscaler \
-n kube-system \
-p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl patch deployments -n kube-system cluster-autoscaler -p '{"spec": {"template": {"spec": {"nodeSelector": {"role": "builders"}}}}}'
# (option)
# kubectl set image deployment cluster-autoscaler \
# -n kube-system \
# cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.24.?
    EOT
    filename = "sh/02.cluster_autoscaler.sh"
}


resource "local_file" "aws_load_balancer_controller_sh" {
    content  = <<-EOT
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.4.1/cert-manager.yaml

# eksctl create iamserviceaccount \
#     --cluster eks-btw-d-apn2-service \
#     --namespace kube-system \
#     --name aws-load-balancer-controller \
#     --attach-role-arn ${module.load_balancer_controller_irsa_role.iam_role_arn} \
#     --override-existing-serviceaccounts \
#     --approve \
#     --region ${var.region}

helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=${module.eks.cluster_id} -n kube-system --set serviceAccount.create=true --set nodeSelector.role=builders
    EOT
    filename = "sh/01.aws_load_balancer_controller.sh"
}

resource "local_file" "secrets_store_csi_driver_sh" {
    content  = <<-EOT
REGION=${var.region}
CLUSTERNAME=${module.eks.cluster_id}

helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set nodeSelector.role=builders
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
    EOT
    filename = "sh/03.secrets-store-csi-driver.sh"
}


resource "local_file" "update_kubeconfig_sh" {
    content  = <<-EOT
CLUSTER_NAME=${module.eks.cluster_id}
aws eks update-kubeconfig --region ap-northeast-2 --name $CLUSTER_NAME --alias $CLUSTER_NAME
    EOT
    filename = "sh/00.update-kubeconfig.sh"
}
