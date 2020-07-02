variable "region" {
    default = "us-east-1" 
}
variable "access_key" {
    default = "AKIAI7CUTIT2PKUXXPFQ"
}
variable "secret_key" {
    default = "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"
}    
variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}

variable "pub_subnet_cidr_block" {
    default = "10.0.0.0/24"
}

variable "priv_subnet_cidr_block" {
    default = "10.0.1.0/24"
} 

variable "pub_rt_table_cidr_block" {
    default = "0.0.0.0/0"
} 

variable "ami" {
  type = "map"

  default = {
    "us-east-1" = "ami-09d95fab7fff3776c"
  }
}

variable "instance_count" {
  default = "1"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "aws_region" {
  default = "us-east-1"
}

variable "device_name" {
    default = "/dev/xvda"
}

variable "volume_size" {
    default = "8"
}
variable "bucket" {
    default = "jabbucket"
}
variable "versioning_enabled" {
    default = false
}



