variable "region" {
    
}
variable "aws-credential-profile" {

    description = "insert here the name of your profile configured inside of ~/.aws/credentials"

}
variable "project-prefix" {
    description = "insert here the prefix/name of your project"
}


variable "vpc-id" {
    description = "ID of your VPC"
}

variable "subnets-ids-az-a" {
    description = "ID of Subnets on availability Zone 1a"
    type        = map(any)
}

variable "subnets-ids-az-b" {
    description = "ID of Subnets on availability Zone 1b"
    type        = map(any)
}

variable "subnets-ids-az-c" {
    description = "ID of Subnets on availability Zone 1c"
    type        = map(any)
}

variable "arn-ecsTaskExecutionRole" {
    description = "ARN of ecsTaskExecutionRole"

}