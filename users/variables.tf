variable "name" {
  description = "The user's name. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. User names are not distinguished by case. For example, you cannot create users named both \"TESTUSER\" and \"testuser\"."
  type        = list
  default     =["test1","test2"]
}



