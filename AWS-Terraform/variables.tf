variable "project_name" {
  description = "Name prefix applied to all resources and tags."
  type        = string
  default     = "ha-wordpress"
}

variable "region" {
  description = "AWS region. The diagram uses us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "The two AZs to spread subnets across (matches the diagram: us-east-1a / us-east-1b)."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "This architecture is built for exactly two Availability Zones."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for the two public subnets (ALB + NAT), one per AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for the two private subnets (EC2 fleet + RDS), one per AZ."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# ---------------------------------------------------------------------------
# Compute
# ---------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for the WordPress fleet."
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of WordPress instances."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of WordPress instances."
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of WordPress instances at launch."
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Optional EC2 key pair name. Leave null if you don't need SSH (instances are private)."
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Optional existing IAM instance profile name to attach to the fleet. Leave null (default) for AWS Academy Learner Lab unless you want SSM Session Manager access, in which case set it to the lab's profile (often \"LabInstanceProfile\" — confirm with `aws iam list-instance-profiles`)."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

variable "db_name" {
  description = "Initial WordPress database name."
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Master username for the RDS MySQL instance."
  type        = string
  default     = "wpadmin"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB."
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "MySQL engine version for RDS."
  type        = string
  default     = "8.0"
}
