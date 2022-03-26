resource "aws_eks_cluster" "k8s-cluster" {
  name     = "${var.name}-k8s-cluster"
  role_arn = aws_iam_role.k8s-cluster.arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    subnet_ids              = var.vpc_private_subnet_ids
    security_group_ids      = [aws_security_group.k8s-cluster.id]
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_internal_cidr # Must not overlap with other VPCs
  }
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.k8s-cluster.arn
    }
  }
  version                   = "1.21"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.k8s-cluster-policy,
    aws_iam_role_policy_attachment.kube-service-policy
  ]
  tags = merge(var.global_default_tags, var.environment.default_tags)
}

