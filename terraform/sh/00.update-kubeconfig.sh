CLUSTER_NAME=eks-onboarding-d-apn2-service
aws eks update-kubeconfig --region ap-northeast-2 --name $CLUSTER_NAME --alias $CLUSTER_NAME
