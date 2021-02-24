#!/bin/bash
$cluster=testcluster
$region=ap-southeast-2
$nodetype=t2.medium

eksctl create cluster --region $region --with-oidc --name $cluster --node-type $nodetype --alb-ingress-access

aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document https://raw.githubusercontent.com/kubernetes-sigs/aws-load
-balancer-controller/main/docs/install/iam_policy.json

eksctl create iamserviceaccount \
  --cluster=$cluster \
  --namespace=kube-system \
  --region=$region \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=$cluster \
  --set region=$region \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system