variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
  }))
}

locals {
  vm_db_map = { for vm in var.each_vm : vm.vm_name => vm }
}

resource "yandex_compute_instance" "vm_db" {
  for_each = local.vm_db_map

  name        = each.value.vm_name
  platform_id = "standard-v1"

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = each.value.disk_volume
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id         = yandex_vpc_subnet.develop.id
    nat               = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
}
