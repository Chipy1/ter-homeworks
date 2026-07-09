## Задача 1.1
Не получилось. Почему? Потому что указана неподдерживаемая версия Terraform. Что странно. `terraform --version` возвращает `Terraform v1.15.8`, это выше чем `1.12.0`.
```sh
> terraform init
Initializing the backend...

╷
│ Error: Unsupported Terraform Core version
│
│   on main.tf line 7, in terraform:
│    7:   required_version = "~>1.12.0" /*Многострочный комментарий.
│
│ This configuration does not support Terraform
│ version 1.15.8. To proceed, either choose
│ another supported Terraform version or update
│ this version constraint. Version constraints
│ are normally set for good reason, so updating
│ the constraint may lead to other errors or
│ unexpected behavior.
╵
```

Фикс: `required_version = "~>1.12"` вместо `required_version = "~>1.12.0"`.
Теперь init сработал корректно.

## Задача 1.2
`personal.auto.tfvars` присутствует в `.gitignore`. Так что, да, допустимо.

## Задача 1.3
```sh
> terraform apply -auto-approve
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_password.random_string will be created
  + resource "random_password" "random_string" {
      + bcrypt_hash = (sensitive value)
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 1
      + min_numeric = 1
      + min_special = 0
      + min_upper   = 1
      + number      = true
      + numeric     = true
      + result      = (sensitive value)
      + special     = false
      + upper       = true
    }

Plan: 1 to add, 0 to change, 0 to destroy.
random_password.random_string: Creating...
random_password.random_string: Creation complete after 0s [id=none]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
Файл `terraform.tfstate`: `"result": "VoPPsy0qaIRZkU5I"`

## Задача 1.4
```sh
> terraform validate
╷
│ Error: Missing name for resource
│
│   on main.tf line 23, in resource "docker_image":
│   23: resource "docker_image" {
│
│ All resource blocks must have 2 labels
│ (type, name).
╵
╷
│ Error: Invalid resource name
│
│   on main.tf line 28, in resource "docker_container" "1nginx":
│   28: resource "docker_container" "1nginx" {
│
│ A name must start with a letter or
│ underscore and may contain only letters,
│ digits, underscores, and dashes.
╵
```
В первой части (`resource "docker_image" {...}`) TF ругается на отсутствие имени ресурса. После строки "docker_image" должна идти вторая строка названия, присваемая к ресурсу.
Фикс: дать имя ресурсу. Тогда:
```tf
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}
```

Во второй (`resource "docker_container" "1nginx" {}`) TF ругается на некорректное имя ресурса, коим является `1nginx`. Имя должно начинаться с `_` или буквы (только английские, разумеется), и содержать исключительно только буквы, цифры, `_` и `-`.
Фикс: дать корректное имя. Будет:
```tf
resource "docker_container" "nginx-1" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string_FAKE.resulT}"

  ports {
    internal = 80
    external = 9090
  }
}
```
Но неееет... Глупо было думать что это всё. Остались проблемы.
Вот эта злая опухоль не проходит validate: `name  = "example_${random_password.random_string_FAKE.resulT}"`

Тут сразу две ошибки: 
1. `random_string_FAKE` не существует. Фикс: сменить на существующий - `random_string`
2. Опечатка в параметре `resulT`. Фикс - `result`
Тогда будет `name  = "example_${random_password.random_string.result}"`

И только тогда получаем заслуженный "Success!" от validate.

## Задача 1.5
Но я уже всё исправил в прошлой задаче. Остался лишь apply.
```sh
> terraform apply
random_password.random_string: Refreshing state... [id=none]

Terraform used the selected providers to generate the
following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.nginx-1 will be created
  + resource "docker_container" "nginx-1" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = (known after apply)
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + memory_reservation                          = 0
      + must_run                                    = true
      + name                                        = (sensitive value)
      + network_data                                = (known after apply)
      + network_mode                                = "bridge"
      + platform                                    = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + healthcheck (known after apply)

      + labels (known after apply)

      + ports {
          + external = 9090
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id           = (known after apply)
      + image_id     = (known after apply)
      + keep_locally = true
      + name         = "nginx:latest"
      + repo_digest  = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_image.nginx: Creating...
docker_image.nginx: Still creating... [00m10s elapsed]
docker_image.nginx: Creation complete after 15s [id=sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bcenginx:latest]
docker_container.nginx-1: Creating...
docker_container.nginx-1: Creation complete after 0s [id=776fd8029d18799879df953e25a189b1cf2b6779981e18db8b429b8ba8c62537]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

docker ps любит быть широким, настолько, что это бесит...
```sh
> docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
776fd8029d18   ec4ed8b5299e   "/docker-entrypoint.…"   9 seconds ago   Up 8 seconds   0.0.0.0:9090->80/tcp   example_VoPPsy0qaIRZkU5I
```

## Задача 1.6
Меняем значение name на "hello_world":
```tf
resource "docker_container" "nginx-1" {
  image = docker_image.nginx.image_id
  name  = "hello_world"
  ...
}

Применяем.
```sh
> terraform apply -auto-approve
random_password.random_string: Refreshing state... [id=none]
docker_image.nginx: Refreshing state... [id=sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bcenginx:latest]
docker_container.nginx-1: Refreshing state... [id=776fd8029d18799879df953e25a189b1cf2b6779981e18db8b429b8ba8c62537]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # docker_container.nginx-1 must be replaced
-/+ resource "docker_container" "nginx-1" {
      + bridge                                      = (known after apply)
      ~ command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> (known after apply)
      + container_logs                              = (known after apply)
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      ~ entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> (known after apply)
      ~ env                                         = [] -> (known after apply)
      + exit_code                                   = (known after apply)
      - group_add                                   = [] -> null
      ~ hostname                                    = "776fd8029d18" -> (known after apply)
      ~ id                                          = "776fd8029d18799879df953e25a189b1cf2b6779981e18db8b429b8ba8c62537" -> (known after apply)
      ~ init                                        = false -> (known after apply)
      ~ ipc_mode                                    = "private" -> (known after apply)
      ~ log_driver                                  = "json-file" -> (known after apply)
      - log_opts                                    = {} -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_swap                                 = 0 -> null
      # Warning: this attribute value will no longer be marked as sensitive
      # after applying this change.
      ~ name                                        = (sensitive value) # forces replacement
      ~ network_data                                = [
          - {
              - gateway                   = "172.17.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.17.0.2"
              - ip_prefix_length          = 16
              - mac_address               = "56:db:44:7c:ed:9d"
              - network_name              = "bridge"
                # (2 unchanged attributes hidden)
            },
        ] -> (known after apply)
      ~ platform                                    = "linux" -> (known after apply)
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      ~ runtime                                     = "runc" -> (known after apply)
      ~ security_opts                               = [] -> (known after apply)
      ~ shm_size                                    = 64 -> (known after apply)
      ~ stop_signal                                 = "SIGQUIT" -> (known after apply)
      ~ stop_timeout                                = 1 -> (known after apply)
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
        # (21 unchanged attributes hidden)

      ~ healthcheck (known after apply)

      ~ labels (known after apply)

        # (1 unchanged block hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
docker_container.nginx-1: Destroying... [id=776fd8029d18799879df953e25a189b1cf2b6779981e18db8b429b8ba8c62537]
docker_container.nginx-1: Destruction complete after 1s
docker_container.nginx-1: Creating...
docker_container.nginx-1: Creation complete after 0s [id=84f2c30cf41d43294cfbd30450815e3e3526a94ca25709bbed45523e32024b73]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

Получаем имя "hello_world":
```sh
> docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
84f2c30cf41d   ec4ed8b5299e   "/docker-entrypoint.…"   6 seconds ago   Up 6 seconds   0.0.0.0:9090->80/tcp   hello_world
```

Опасность `-auto-approve` в том что можно пропустить опасное действие плана, который TF составляет для apply. Это не беда для CI/CD только когда знаешь, что делаешь, и всё под контролем...

## Задача 1.8
Задачу 1.7 кто-то съел, наверное.
```sh
> terraform destroy
random_password.random_string: Refreshing state... [id=none]
docker_image.nginx: Refreshing state... [id=sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bcenginx:latest]
docker_container.nginx-1: Refreshing state... [id=378f4a38b42eef10baa61f502fe12dac7db3411843f82a234a8f6e56267e793a]

Terraform used the selected providers to
generate the following execution plan.
Resource actions are indicated with the
following symbols:
  - destroy

Terraform will perform the following actions:

  # docker_container.nginx-1 will be destroyed
  - resource "docker_container" "nginx-1" {
      - attach                                      = false -> null
      - command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> null
      - container_read_refresh_timeout_milliseconds = 15000 -> null
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      - entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> null
      - env                                         = [] -> null
      - group_add                                   = [] -> null
      - hostname                                    = "378f4a38b42e" -> null
      - id                                          = "378f4a38b42eef10baa61f502fe12dac7db3411843f82a234a8f6e56267e793a" -> null
      - image                                       = "sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bce" -> null
      - init                                        = false -> null
      - ipc_mode                                    = "private" -> null
      - log_driver                                  = "json-file" -> null
      - log_opts                                    = {} -> null
      - logs                                        = false -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_reservation                          = 0 -> null
      - memory_swap                                 = 0 -> null
      - must_run                                    = true -> null
      - name                                        = "hello_world" -> null
      - network_data                                = [
          - {
              - gateway                   = "172.17.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "172.17.0.2"
              - ip_prefix_length          = 16
              - mac_address               = "ba:b7:b4:83:3e:58"
              - network_name              = "bridge"
                # (2 unchanged attributes hidden)
            },
        ] -> null
      - network_mode                                = "bridge" -> null
      - platform                                    = "linux" -> null
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      - read_only                                   = false -> null
      - remove_volumes                              = true -> null
      - restart                                     = "no" -> null
      - rm                                          = false -> null
      - runtime                                     = "runc" -> null
      - security_opts                               = [] -> null
      - shm_size                                    = 64 -> null
      - start                                       = true -> null
      - stdin_open                                  = false -> null
      - stop_signal                                 = "SIGQUIT" -> null
      - stop_timeout                                = 1 -> null
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - tty                                         = false -> null
      - wait                                        = false -> null
      - wait_timeout                                = 60 -> null
        # (6 unchanged attributes hidden)

      - ports {
          - external = 9090 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }
    }

  # docker_image.nginx will be destroyed
  - resource "docker_image" "nginx" {
      - id           = "sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bcenginx:latest" -> null
      - image_id     = "sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bce" -> null
      - keep_locally = true -> null
      - name         = "nginx:latest" -> null
      - repo_digest  = "nginx@sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bce" -> null
    }

  # random_password.random_string will be destroyed
  - resource "random_password" "random_string" {
      - bcrypt_hash = (sensitive value) -> null
      - id          = "none" -> null
      - length      = 16 -> null
      - lower       = true -> null
      - min_lower   = 1 -> null
      - min_numeric = 1 -> null
      - min_special = 0 -> null
      - min_upper   = 1 -> null
      - number      = true -> null
      - numeric     = true -> null
      - result      = (sensitive value) -> null
      - special     = false -> null
      - upper       = true -> null
    }

Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

random_password.random_string: Destroying... [id=none]
random_password.random_string: Destruction complete after 0s
docker_container.nginx-1: Destroying... [id=378f4a38b42eef10baa61f502fe12dac7db3411843f82a234a8f6e56267e793a]
docker_container.nginx-1: Destruction complete after 0s
docker_image.nginx: Destroying... [id=sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bcenginx:latest]
docker_image.nginx: Destruction complete after 0s

Destroy complete! Resources: 3 destroyed.
```

`terraform.tfstate`:
```json
{
  "version": 4,
  "terraform_version": "1.15.8",
  "serial": 18,
  "lineage": "89e330f3-fb03-5f12-5927-0e5db22231fe",
  "outputs": {},
  "resources": [],
  "check_results": null
}
```

## Задача 1.9
В коде `main.tf` указано `keep_locally = true` у `docker_image.nginx`, это запрещает удалять образ при уничтожении ресурса.
Из документации (https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image): `keep_locally (Boolean)` — если `true`, образ не будет удалён при `destroy`.

## Задача 3.1
OpenTofu v1.12.3 установил через scoop.
Проект работает с ним так же как и с TF.
```sh
> tofu init
OpenTofu has been successfully initialized!

> tofu plan
Plan: 3 to add, 0 to change, 0 to destroy.
```

И, apply работает абсолютно так же:
```sh
> tofu apply

OpenTofu used the selected providers to
generate the following execution plan.
Resource actions are indicated with the
following symbols:
  + create

OpenTofu will perform the following actions:

  # docker_container.nginx-1 will be created
  + resource "docker_container" "nginx-1" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = (known after apply)
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + memory_reservation                          = 0
      + must_run                                    = true
      + name                                        = "hello_world"
      + network_data                                = (known after apply)
      + network_mode                                = "bridge"
      + platform                                    = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + healthcheck (known after apply)

      + labels (known after apply)

      + ports {
          + external = 9090
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id           = (known after apply)
      + image_id     = (known after apply)
      + keep_locally = true
      + name         = "nginx:latest"
      + repo_digest  = (known after apply)
    }

  # random_password.random_string will be created
  + resource "random_password" "random_string" {
      + bcrypt_hash = (sensitive value)
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 1
      + min_numeric = 1
      + min_special = 0
      + min_upper   = 1
      + number      = true
      + numeric     = true
      + result      = (sensitive value)
      + special     = false
      + upper       = true
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

random_password.random_string: Creating...
docker_image.nginx: Creating...
random_password.random_string: Creation complete after 0s [id=none]
docker_image.nginx: Creation complete after 0s [id=sha256:ec4ed8b5299e5e90694af7750eb6dffd2627317d30544d056b0371f8082f7bcenginx:latest]
docker_container.nginx-1: Creating...
docker_container.nginx-1: Creation complete after 0s [id=c82d6f0b7ed75df61ab4e8a4fd352c7919c14caf53c62d5561655a2991928ae3]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```