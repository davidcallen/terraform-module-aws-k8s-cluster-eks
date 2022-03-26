# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes : IAM
# ---------------------------------------------------------------------------------------------------------------------

# TODO : assess if better to use https://github.com/terraform-aws-modules/terraform-aws-eks
#
resource "aws_iam_role" "k8s-cluster" {
  name               = "${var.name}-k8s-cluster-role"
  description        = "Allow cluster to manage node groups, VPC for LoadBalancers and cloudwatch logs"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8s-cluster.name
}
resource "aws_iam_role_policy_attachment" "kube-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.k8s-cluster.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.k8s-cluster.name
}

# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes : IAM for Node Group
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "kube-node-group" {
  name = "${var.name}-k8s-cluster-node-group-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "kube-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.kube-node-group.name
}
resource "aws_iam_role_policy_attachment" "kube-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.kube-node-group.name
}
resource "aws_iam_role_policy_attachment" "kube-ecr-readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.kube-node-group.name
}

# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes : IAM for Fargate
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "kube-fargate-profile" {
  name        = "${var.name}-fargate-profile"
  description = "Allow fargate cluster to allocate resources for running pods"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [
          "eks-fargate-pods.amazonaws.com"
        ]
      }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "example-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.kube-fargate-profile.name
}
//# TODO : This article mentions these but check if really need them
//#    https://betterprogramming.pub/with-latest-updates-create-amazon-eks-fargate-cluster-and-managed-node-group-using-terraform-bc5cfefd5773
//#
//resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
//  role       = aws_iam_role.eks_fargate_role.name
//}
//resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
//  role       = aws_iam_role.eks_fargate_role.name
//}

# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes : Create OIDC Provider for our cluster so can link IAM Roles to Kube Service Accounts
#    See https://marcincuber.medium.com/amazon-eks-with-oidc-provider-iam-roles-for-kubernetes-services-accounts-59015d15cb0c
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "k8s-cluster" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.k8s-cluster.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.k8s-cluster.identity.0.oidc.0.issuer
}
data "tls_certificate" "k8s-cluster" {
  url = aws_eks_cluster.k8s-cluster.identity.0.oidc.0.issuer
}