variable "s3_bucket_name" {
  description = "Name for the s3 bucket"
  type        = string
  default     = ""
  validation {
    condition     = length(var.s3_bucket_name) > 0
    error_message = "Error : the variable 's3_bucket_name' must be non-empty."
  }
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = ""
  validation {
    condition     = length(var.aws_region) > 0
    error_message = "Error : the variable 'aws_region' must be non-empty."
  }
}
variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = ""
  validation {
    condition     = length(var.account_id) > 0
    error_message = "Error : the variable 'account_id' must be non-empty."
  }
}
variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}