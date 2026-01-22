variable "aws_cred" {
  type = object({
    access_key = string,
    secreatkey = string,
    region     = string
  })
}

variable "instanceinfo" {
  type = object({
    ami          = string,
    instancetype = string,
    disksize     = number,
    disktype     = string
    tags         = map(string)
  })
}
