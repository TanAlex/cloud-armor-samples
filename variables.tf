variable "region" {
  default = "us-west1"
}

variable "region_zone" {
  default = "us-west1-a"
}

variable "project" {
  description = "The ID of the Google Cloud project"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "~/.gcloud/Terraform.json"
}

variable "network" {
  description = "The network in your VPC"
}

variable "subnet" {
  description = "The subnet in your VPC network"
}

variable "ip_white_list" {
  description = "A list of ip addresses that can be white listed through security policies"
  default     = ["192.0.2.0/24"]
}