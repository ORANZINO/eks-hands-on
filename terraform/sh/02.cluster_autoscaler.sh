#0. Metric Server 설치 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
#Cluster Autoscaler 배포
#1. ekstcl 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

#2. ServiceAccount 와 IAM Role 연결
eksctl create iamserviceaccount \
--cluster=eks-onboarding-d-apn2-service \
--namespace=kube-system \
--name=cluster-autoscaler \
--attach-role-arn=arn:aws:iam::408627781643:role/cluster-autoscaler \
--override-existing-serviceaccounts \
--region=ap-northeast-2 \
--approve

#3. Cluster Autoscaler 배포
curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
sed -i s/'<YOUR CLUSTER NAME>'/eks-onboarding-d-apn2-service/g cluster-autoscaler-autodiscover.yaml
kubectl apply -f cluster-autoscaler-autodiscover.yaml
kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::408627781643:role/cluster-autoscaler
kubectl patch deployment cluster-autoscaler \
-n kube-system \
-p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl patch deployments -n kube-system cluster-autoscaler -p '{"spec": {"template": {"spec": {"nodeSelector": {"role": "builders"}}}}}'
# (option)
# kubectl set image deployment cluster-autoscaler \
# -n kube-system \
# cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.24.?
