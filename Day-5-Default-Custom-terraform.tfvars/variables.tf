variable "ami_id" {
    default = ""
  
}

variable "Instance_type" {
    type = string
    default = ""
}
  
variable "name" {
    default = ""
  
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance sizing type"
}
