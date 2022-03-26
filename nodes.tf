resource "aws_eks_node_group" "k8s-cluster" {
  cluster_name      = aws_eks_cluster.k8s-cluster.name
  node_group_name   = "${var.name}-cluster-nodes"
  node_role_arn     = aws_iam_role.kube-node-group.arn
  subnet_ids        = var.vpc_private_subnet_ids
  instance_types    = ["t3a.medium"]
  scaling_config {
    desired_size    = 1
    max_size        = 2
    min_size        = 1
  }
  tags = merge(var.global_default_tags, var.environment.default_tags, {
    Name            = "${var.name}-cluster-nodes"
  })
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.kube-eks-worker-node-policy,
    aws_iam_role_policy_attachment.kube-eks-cni-policy,
    aws_iam_role_policy_attachment.kube-ecr-readonly
  ]
}

