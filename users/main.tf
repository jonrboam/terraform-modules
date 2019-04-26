data "aws_caller_identity" "current" {}

resource "aws_iam_user" "user" {
  #name = "${var.name}"
  count = "${length(var.name)}"
  name = "${element(var.name, count.index)}"
}

