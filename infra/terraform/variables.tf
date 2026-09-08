variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "flask-postgresql-two-tier"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name in this region"
}

variable "ssh_cidr" {
  type        = string
  description = "Your public IP/CIDR for SSH (never 0.0.0.0/0 if avoidable)"
  default     = "0.0.0.0/0"
}

variable "jenkins_cidr" {
  type        = string
  description = "Who may reach Jenkins UI"
  default     = "0.0.0.0/0"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/yashassuresh775/flask-postgresql-two-tier.git"
}
