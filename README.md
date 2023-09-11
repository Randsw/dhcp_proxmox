# Автоматическое развертывание DHCP сервера на гипервизоре Proxmox c помощью Terraform и Ansible

## Необходимые компоненты

* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* Для тестирование роли ansible нужно установисть [Molecule](https://ansible.readthedocs.io/projects/molecule/installation/#pip) с драйвером [Docker](https://github.com/ansible-community/molecule-plugins)
* Заранее созданный шаблон виртуальной машины в Proxmox с поддержкой [Cloud-Init](https://cloudinit.readthedocs.io/en/latest/)

## Порядок действий

### Создание виртуальной машины с помощью Terraform

Убедится что в Proxmox есть подходящий шаблон виртуальной машины с поддержкой `Cloud-Init`.

Перейти в папку `terraform` и выполнить `terraform init` для установки необходимых провайдеров.

:warning: Необходим VPN - Hashicorp заблокировал доступ из РФ.

Задать необходимые параметры в файле `terrafrom/terraform.tfvars`.

#### Параметры Terraform

|Название         |Описание                                                    |Значение по умолчанию  |
|-----------------|------------------------------------------------------------|-----------------------|
|proxmox_host     | IP адресс Proxmox                                          |-                      |
|proxmox_token_id | ID токена Proxmox                                          |root@pam!terraform     |
|proxmox_storage  | Тип хранилища Proxmox для VM                               |local-lvm              |
|region           | Название датацентра Proxmox                                |-                      |
|target_node_name | Название ноды Proxmox                                      |pve                    |
|pool             | Название пула хранилища Proxmox для VM                     |                       |
|dhcp_server_ip   | IP адрес dhcp сервера                                      |-                      |
|cores            | Количество ядер VM                                         |1                      |
|ram              | Объем оперативной памяти VM в МБ                           |2048                   |
|disk_size        | Размер диска VM                                            |20G                    |
|dhcp_vm_template | Имя шаблона VM                                             |-                      |

Задать секретный токен Proxmox `proxmox_token_secret` в файле `terrafrom/credential.tfvars`.

При необходимости добавить дополнительный публичный ключ в поле `sshkeys` между `EOT`.

Выполнить команду `make plan` и убедится что ресурсы создаются корректно.

Выполнить команду `make apply`.

Удалить виртуальную машину можно выполнив команду `make destroy`.

Команда make apply также создает файл hosts.yml в папке `ansible/inventories/dhcp/` необходимый для развертывания DNS сервера с помощью Ansible.

### Развертывание DNS сервера с помощью Ansible

Убедится что по пути `ansible/inventories/dhcp/hosts.yml` создан файл с верными значениями.

Создать переменную среды `SSH_PRIVATE_KEY_PATH` со значением пути к SSH Private key для VM:
`export SSH_PRIVATE_KEY_PATH=<путь-до-файла-ключа>`

Открыть файл `ansible/inventories/dhcp/host-vars/dhcp-1.yml`. Проверить настройки, при необходимости изменить.

#### Параметры Ansible

```Yaml
dhcp_subnets:
  - ip: 192.168.222.0
    netmask: 255.255.255.128
    domain_name_servers:
      - 10.0.2.3
      - 10.0.2.4
    range_begin: 192.168.222.50
    range_end: 192.168.222.127
  - ip: 192.168.222.128
    default_lease_time: 3600
    max_lease_time: 7200
    netmask: 255.255.255.128
    domain_name_servers: 10.0.2.3
    routers: 192.168.222.129
```

An alphabetical list of supported options in a subnet declaration:

| Option                | Required | Comment                                                               |
| :-------------------- | :------: | :-------------------------------------------------------------------- |
| `booting`             |    no    | allow,deny,ignore                                                     |
| `bootp`               |    no    | allow,deny,ignore                                                     |
| `default_lease_time`  |    no    | Default lease time for this subnet (in seconds)                       |
| `domain_name_servers` |    no    | List of domain name servers for this subnet(1)                        |
| `domain_search`       |    no    | List of domain names for resolution of non-FQDNs(1)                   |
| `filename`            |    no    | filename to retrieve from boot server                                 |
| `hosts`               |    no    | List of fixed IP address hosts for each subnet, similar to dhcp_hosts |
| `interface`           |    no    | Overrides the `interface` of the subnet declaration                   |
| `ip`                  |   yes    | **Required.** IP address of the subnet                                |
| `max_lease_time`      |    no    | Maximum lease time for this subnet (in seconds)                       |
| `netmask`             |   yes    | **Required.** Network mask of the subnet (in dotted decimal notation) |
| `next_server`         |    no    | IP address of the boot server                                         |
| `ntp_servers`         |    no    | List of NTP servers for this subnet                                   |
| `range_begin`         |    no    | Lowest address in the range of dynamic IP addresses to be assigned    |
| `range_end`           |    no    | Highest address in the range of dynamic IP addresses to be assigned   |
| `ranges`              |    no    | If multiple ranges are needed, they can be specified as a list (2)    |
| `routers`             |    no    | IP address of the gateway for this subnet                             |
| `server_name`         |    no    | Server name sent to the client                                        |
| `subnet_mask`         |    no    | Overrides the `netmask` of the subnet declaration                     |
| `options`             |    no    | A dict of options to add to this subnet                               |

For multiple subnet ranges, they can be specified, thus:

```Yaml
ranges:
  - { begin: 192.168.222.50, end: 192.168.222.99 }
  - { begin: 192.168.222.110, end: 192.168.222.127 }
```

#### Host declarations

You can specify hosts that should get a fixed IP address based on their MAC by setting the `dhcp_hosts` option. This is a list of dicts with the following three keys, of which `name` and `mac` are mandatory:

| Option     | Comment                                         |
| :--------- | :---------------------------------------------- |
| `name`     | The name of the host                            |
| `mac`      | The MAC address of the host                     |
| `ip`       | The IP address to be assigned to the host       |
| `hostname` | Hostname to be assigned through DHCP (optional) |

```Yaml
dhcp_hosts:
  - name: cl1
    mac: '00:11:22:33:44:55'
    ip: 192.168.222.150
  - name: cl2
    mac: '00:de:ad:be:ef:00'
    ip: 192.168.222.151
```

Выполнить команду `make provision`.
