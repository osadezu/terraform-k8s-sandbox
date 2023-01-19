output "rendered_cluster_policy" {
  value = data.aws_iam_policy_document.cluster_trust_policy.json
}

output "rendered_worker_policy" {
  value = data.aws_iam_policy_document.worker_trust_policy.json
}
