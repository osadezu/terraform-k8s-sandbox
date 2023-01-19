resource "aws_eks_node_group" "workers_node_group" {
  cluster_name    = aws_eks_cluster.sandbox.name
  node_group_name = "${var.cluster_name}-workers-node-group"
  node_role_arn   = aws_iam_role.worker_role.arn
  subnet_ids      = [for subnet in aws_subnet.private_subnets : subnet.id]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
    # aws_iam_role_policy_attachment.sqs_policy,
  ]
}

# Role's trust policy allows EC2 to assume it
resource "aws_iam_role" "worker_role" {
  name = "terraform-eks-demo-node-role"
  assume_role_policy = data.aws_iam_policy_document.worker_trust_policy.json
}

# The aws_iam_policy_document data source uses HCL to generate a JSON representation of an IAM policy document.
# This has advantages over including the policy as a json HEREDOC string.
data "aws_iam_policy_document" "worker_trust_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Policies attached to above role
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_role.name
}

# resource "aws_iam_role_policy_attachment" "sqs_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
#   role       = aws_iam_role.worker_role.name
# }
