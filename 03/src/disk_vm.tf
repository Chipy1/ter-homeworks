resource "yandex_compute_disk" "storage_disk" {
  count = 3

  name = "storage-disk-${count.index + 1}"
  type = "network-hdd"
  size = 1
  zone = var.default_zone
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage_disk[*].id
    content {
      disk_id = secondary_disk.value
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
}
