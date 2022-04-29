variable "region" {
   default = "us-west-2"
}

variable "cluster_name" {
  type = string
  default = "test-cluster-tf"
}

variable "subnet_name" {
  type = string
  default = "test-subnet-tf"
}

variable "profile" {
  description = "default"
}

variable "cluster_version" {
  default = "1.21"
}

variable "name" {
  default = "test"
}

variable "stage" {
  default = "dev"
}