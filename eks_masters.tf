resource "aws_eks_cluster" "sandbox" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster_sg.id]
    subnet_ids         = [for subnet in aws_subnet.private_subnets : subnet.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.service_policy,
  ]
}

# Role's trust policy allows EKS to assume it
resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-eks-role"

  assume_role_policy = data.aws_iam_policy_document.cluster_trust_policy.json
  # assume_role_policy = <<-POLICY
  # {
  # 	"Version": "2012-10-17",
  # 	"Statement": [
  # 		{
  # 			"Effect": "Allow",
  # 			"Principal": {
  # 				"Service": "eks.amazonaws.com"
  # 			},
  # 			"Action": "sts:AssumeRole"
  # 		}
  # 	]
  # }
  # POLICY
}

# The aws_iam_policy_document data source uses HCL to generate a JSON representation of an IAM policy document.
# This has advantages over including the policy as a json HEREDOC string (commented above).
data "aws_iam_policy_document" "cluster_trust_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Policies attached to above role
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_security_group" "cluster_sg" {
  name        = "${var.cluster_name}-eks-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.sandbox.id

  # Allow all egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  type              = "ingress"
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster_sg.id
}
