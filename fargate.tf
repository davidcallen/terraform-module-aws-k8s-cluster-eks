resource "aws_eks_fargate_profile" "k8s-cluster" {
  cluster_name           = aws_eks_cluster.k8s-cluster.name
  fargate_profile_name   = "${var.name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.kube-fargate-profile.arn
  subnet_ids             = var.vpc_private_subnet_ids
  selector {
    namespace = var.namespace
    //    labels    = {
    //      app = "prpl"
    //    }
  }
  tags = {
    Name = aws_eks_cluster.k8s-cluster.name
  }
}

// Probably dont need this - have the system pods running in the single Node
//resource "aws_eks_fargate_profile" "k8s-cluster-kube-system-fargate-profile" {
//  cluster_name           = aws_eks_cluster.k8s-cluster.name
//  fargate_profile_name   = "${var.name}-system-fargate-profile"
//  pod_execution_role_arn = aws_iam_role.kube-fargate-profile.arn
//  subnet_ids             = var.vpc_private_subnet_ids
//  selector {
//    namespace = "kube-system"
//  }
//}