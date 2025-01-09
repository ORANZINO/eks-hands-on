kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.4.1/cert-manager.yaml

eksctl create iamserviceaccount \
    --cluster eks-btw-d-apn2-service \
    --namespace kube-system \
    --name aws-load-balancer-controller \
    --attach-role-arn arn:aws:iam::408627781643:role/load-balancer-controller \
    --override-existing-serviceaccounts \
    --approve \
    --region ap-northeast-2

helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=eks-onboarding-d-apn2-service -n kube-system --set serviceAccount.create=true --set nodeSelector.role=builders
