variable "security_group_ids" {
  description = "The AWS security group to apply."
  type        = list(string)
}

variable "ami" {
  description = "The AMI ID to use for the instance."
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "key_name" {
  description = "Key pair"
  type        = string
}

variable "eip" {
  description = "Optional Elastic IP address to associate with instance if present"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "The domain name to use for the application."
  type        = string
}
