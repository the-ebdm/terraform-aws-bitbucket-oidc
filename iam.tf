locals {
  thumb_slug_a = replace(var.url, "https://", "")
  thumb_slug_b = "${replace(local.thumb_slug_a, "//.*/", "")}:443"

  main_policy_statement = {
    "Effect" : "Allow",
    "Action" : "sts:AssumeRoleWithWebIdentity",
    "Principal" : {
      "Federated" : "${aws_iam_openid_connect_provider.main.arn}"
    },
    "Condition" : {
      "StringEquals" : {
        "${aws_iam_openid_connect_provider.main.url}:aud" : aws_iam_openid_connect_provider.main.client_id_list
      }
    }
  }

  main_policy_statements = setunion([local.main_policy_statement], var.allow_account != "" ? [{
    "Effect" : "Allow",
    "Action" : "sts:AssumeRole",
    "Principal" : {
      "AWS": "arn:aws:iam::${var.allow_account}:root"
    },
    "Condition": {}
  }] : [])
}

data "external" "thumbprint" {
  program = ["bash", "${path.module}/getthumbprint.sh", local.thumb_slug_b]
}

resource "aws_iam_openid_connect_provider" "main" {
  url = var.url

  client_id_list = var.audiences

  thumbprint_list = [data.external.thumbprint.result.data]
}

resource "aws_iam_user" "main" {
  name = "bitbucket-pipeline"
}

resource "aws_iam_access_key" "main" {
  user    = aws_iam_user.main.name
}

resource "aws_iam_user_policy" "main" {
  name = "${aws_iam_user.main.name}-policy"
  user = aws_iam_user.main.name

  policy = var.iam_policy
}

output "keys" {
  value = aws_iam_access_key.main
}

resource "aws_iam_role" "main" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : local.main_policy_statements
  })
}

resource "aws_iam_policy" "main" {
  name        = "${var.name}-access-policy"
  description = "IAM policy for ${var.name}"

  policy = var.iam_policy
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}
