variable "vpc_cidr" {
    type        = string
    description = "Enter CIDR value"
    default     = "10.100.0.0/16"
}

/* variable "Env" {
    type       = string
    description = "Enter enviroment tag"
    default    = "testing"
} */

variable "public_subnet"{
    type = list(string)
    description = "enter public subnet value "
    default = ["10.100.1.0/24","10.100.2.0/24"]
}

variable "private_subnet"{
    type = list(string)
    description = "enter private subnet value "
    default = ["10.100.10.0/24","10.100.11.0/24"]
}

variable "public_ip"{
    type = string
    description = "enter public ip value "
    default = "106.210.209.1/32"
}
variable "endpoint_service_name"{
    type        = string
    description = "Enter endpoint service name"
    default     = "com.amazonaws.eu-north-1.s3"
}

variable "ec2_count"{
    type        = number
    description = "No of ec2 instance launch"
    default     = 1
}

variable "vol_size"{
    type        = number
    description = "GB size select"
    default     = 10
}

variable "instance_type"{
    type = string
    default = "t3.micro"
}

variable "key"{
    type = string
    default = "linux"
}