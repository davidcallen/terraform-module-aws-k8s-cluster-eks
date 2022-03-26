output "k8s_cluster_name" {
  value = aws_eks_cluster.k8s-cluster.name
}
output "k8s_cluster_endpoint" {
  value = aws_eks_cluster.k8s-cluster.endpoint
}
output "k8s_cluster_certificate_authority" {
  value = aws_eks_cluster.k8s-cluster.certificate_authority
}
output "k8s_cluster_identity_oidc_issuer" {
  value = aws_eks_cluster.k8s-cluster.identity[0].oidc[0].issuer
}