data "aws_caller_identity" "current" {}

resource "aws_iam_user" "user" {
  #name = "${var.name}"
  count = "${length(var.name)}"
  name = "${element(var.name, count.index)}"
}

data "aws_iam_policy_document" "user_profile_self_service" {
  count = "${length(var.name)}"
  statement {
    actions   = [
      "iam:*AccessKey*",
      "iam:*LoginProfile",
      "iam:*SigningCertificate*"
    ]
    resources = [
      "${aws_iam_user.user.*.arn}"
    ]
    sid       = "AllowIndividualUserToManageTheirAccountInformation"
  }

  statement {
    actions   = [
      "iam:*MFADevice"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/${aws_iam_user.user.*.name}",
      "${aws_iam_user.user.*.arn}"
    ]
    sid       = "AllowIndividualUserToManageTheirrMFA"
  }

  statement {
    actions   = [
      "iam:GetRolePolicy",
      "iam:GetRoles",
      "iam:ListRoles"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
    sid       = "AllowUserToViewRoles"
  }

  statement {
    actions = [
      "iam:ListGroups"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/*"
    ]
    sid = "AllowUserToListGroups"
  }
}

