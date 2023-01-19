output "rendered_policy" {
  value = data.aws_iam_policy_document.cluster_trust_policy.json
}
