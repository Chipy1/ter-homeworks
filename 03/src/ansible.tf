locals {
  webservers = yandex_compute_instance.web
  databases  = values(yandex_compute_instance.vm_db)
  storage    = [yandex_compute_instance.storage]
}

resource "local_file" "hosts_ini" {
  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = local.webservers
    databases  = local.databases
    storage    = local.storage
  })
  filename = "${abspath(path.module)}/hosts.ini"
}
