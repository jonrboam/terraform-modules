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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/${element(var.name, count.index)}",
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

resource "aws_iam_user_policy" "user_profile_self_service" {
  name    = "UserProfileSelfService"
  count   = "${length(var.name)}"
  policy  = "${data.aws_iam_policy_document.user_profile_self_service.json.*}"
  user    = "${aws_iam_user.user.*.name}"
}

data "aws_iam_policy_document" "enforce_mfa" {
  count   = "${length(var.name)}"
  statement {
    condition {
      test      = "Null"
      values    = [
        "true"
      ]
      variable  = "aws:MultiFactorAuthPresent"
    }
    effect = "Deny"
    not_actions = [
      "iam:*LoginProfile",
      "iam:*MFADevice",
      "iam:ChangePassword",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:List*MFADevices",
      "iam:ListAccountAliases",
      "iam:ListUsers"
    ]
    resources   = [
      "*"
    ]
    sid         = "DenyEverythingExceptForBelowUnlessMFAd"
  }

  statement {
    condition {
      test        = "Null"
      values      = [
        "true"
      ]
      variable    = "aws:MultiFactorAuthPresent"
    }
    effect        = "Deny"
    actions       = [
      "iam:*LoginProfile",
      "iam:*MFADevice",
      "iam:ChangePassword",
      "iam:GetAccountSummary"
    ]
    not_resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/${element(var.name, count.index)}",
      "${aws_iam_user.user.*.arn}"
    ]
    sid           = "DenyIamAccessToOtherAccountsUnlessMFAd"
  }
}

resource "aws_iam_user_policy" "enforce_mfa" {
  name    = "EnforceMFA"
  count   = "${length(var.name)}"
  policy  = "${data.aws_iam_policy_document.enforce_mfa.*.rendered[count.index].json}"
  user    = "${aws_iam_user.user.*.name}"
}

resource "aws_iam_user_policy_attachment" "manage_specific_credentials" {
  policy_arn = "arn:aws:iam::aws:policy/IAMSelfManageServiceSpecificCredentials"
  count      = "${length(var.name)}"
  user       = "${aws_iam_user.user.*.name}"
}

resource "aws_iam_user_policy_attachment" "change_password" {
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
  count      = "${length(var.name)}"
  user       = "${aws_iam_user.user.*.name}"
}

resource "aws_iam_user_policy_attachment" "manage_ssh_keys" {
  policy_arn = "arn:aws:iam::aws:policy/IAMUserSSHKeys"
  count      = "${length(var.name)}"
  user       = "${aws_iam_user.user.*.name}"
}

resource "aws_iam_user_policy_attachment" "iam_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  count      = "${length(var.name)}"
  user       = "${aws_iam_user.user.*.name}"
}


