resource "aws_iam_openid_connect_provider" "oidc" {
  url             = var.github_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.certificate.certificates.0.sha1_fingerprint]
  
  tags = var.tags
}

data "tls_certificate" "certificate" {
  url = var.github_url
}

resource "aws_iam_role" "role" {
  assume_role_policy    = data.aws_iam_policy_document.asume_role_policy.json
  name                  = var.role_name
  managed_policy_arns   = var.managed_policy_arns
  force_detach_policies = true 

  tags = var.tags
}

data "aws_iam_policy_document" "asume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = [ for repo in var.github_repositories : "repo:${var.github_organization}/${repo}:*" ]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

