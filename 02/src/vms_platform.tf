###vm_web vars

# variable "vm_web_name" {
#   type    = string
#   default = "netology-develop-platform-web"
# }

variable "vm_web_platform_id" {
  type    = string
  default = "standard-v1"
}

# variable "vm_web_cores" {
#   type    = number
#   default = 1
# }

# variable "vm_web_memory" {
#   type    = number
#   default = 1
# }

# variable "vm_web_core_fraction" {
#   type    = number
#   default = 5
# }

variable "vm_web_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

###vm_db vars

# variable "vm_db_name" {
#   type    = string
#   default = "netology-develop-platform-db"
# }

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v1"
}

# variable "vm_db_cores" {
#   type    = number
#   default = 2
# }

# variable "vm_db_memory" {
#   type    = number
#   default = 2
# }

# variable "vm_db_core_fraction" {
#   type    = number
#   default = 20
# }

variable "vm_db_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

### vms_resources map

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    hdd_type      = string
  }))
}

### metadata map

variable "metadata" {
  type = map(string)
}
