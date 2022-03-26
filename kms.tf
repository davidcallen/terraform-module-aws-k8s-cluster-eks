# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes : KMS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "k8s-cluster" {
  description             = "${var.name}-cluster-kms"
  deletion_window_in_days = 10
}
resource "aws_kms_alias" "k8s-cluster" {
  name          = "alias/${var.name}-kms-kube-fargate-cluster"
  target_key_id = aws_kms_key.k8s-cluster.key_id
}
