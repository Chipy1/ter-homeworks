locals {
  vm_web_name = "${var.project}-${var.vpc_name}-platform-${var.vm_web_role}"
  vm_db_name  = "${var.project}-${var.vpc_name}-platform-${var.vm_db_role}"
}
