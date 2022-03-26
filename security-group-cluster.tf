# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes : Cluster security group
# ---------------------------------------------------------------------------------------------------------------------
# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "k8s-cluster" {
  name        = "${var.name}-cluster"
  description = "kubernetes cluster"
  vpc_id      = var.vpc_id
  tags = merge(var.global_default_tags, var.environment.default_tags, {
    Name            = "${var.name}-cluster"
  })
}
# All ingress to all ports
resource "aws_security_group_rule" "k8s-cluster-allow-ingress-all" {
  type            = "ingress"
  description     = "all"
  from_port       = 0
  to_port         = 65535
  protocol        = "all"
  cidr_blocks     = var.cluster_ingress_allowed_cidrs
  security_group_id = aws_security_group.k8s-cluster.id
}
# All Egress to all ports and destinations
resource "aws_security_group_rule" "k8s-cluster-allow-egress-all" {
  type            = "egress"
  description     = "all"
  from_port       = 0
  to_port         = 65535
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s-cluster.id
}
