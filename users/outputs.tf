output "arn" {
  description = "The ARN assigned by AWS for this user."
  value       = "${aws_iam_user.user.arn}"
}

output "name" {
  description = "The user's name."
  value       = "${aws_iam_user.user.name}"
}

output "unique_id" {
  description = "The unique ID assigned by AWS. "
  value       = "${aws_iam_user.user.unique_id}"
}
