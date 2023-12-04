terraform {
  required_version = ">= 0.13.0"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.94.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  token = var.token
}

resource "yandex_vpc_network" "external-bastion-network" {
  name        = "external-bastion-network"
  description = "Внешняя сеть"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "bastion-external-segment" {
  name           = "bastion-external-segment"
  description    = "Подсеть для внешней сети"
  v4_cidr_blocks = ["172.16.17.0/28"]
  zone           = var.zone
  network_id     = yandex_vpc_network.external-bastion-network.id
}

resource "yandex_vpc_security_group" "secure-bastion-sg" {
  name        = "secure-bastion-sg"
  description = "Группа безопасности"
  network_id  = yandex_vpc_network.external-bastion-network.id

  ingress {
    protocol       = "TCP"
    description    = "Входящий трафик"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "rule1 description"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 8000
    to_port        = 8001
  }

  ingress {
    protocol       = "TCP"
    description    = "rule2 description"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 80
    to_port        = 8000
  }

  egress {
    protocol       = "ANY"
    description    = "rule3 description"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  egress {
    description    = "Allow any outgoing traffic to the Internet"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "gitlab_vm" {
  name = "gitlab-vm"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  metadata = {
    service_account_name = var.service_account_name
    service_account_id = var.service_account_id
    user-data = "${file("./cloud-init.yaml")}"
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      type     = "network-ssd"
      size = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.bastion-external-segment.id
    nat       = true
  }
}

resource "yandex_compute_instance" "monitoring_vm" {
  name = "monitoring-vm"
  resources {
    cores  = 2
    memory = 4
  }

  metadata = {
    service_account_name = var.service_account_name
    service_account_id = var.service_account_id
    user-data = "${file("./cloud-init.yaml")}"
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      type     = "network-ssd"
      size = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.bastion-external-segment.id
    nat       = true
  }
}

resource "yandex_compute_instance" "search_engine_vm" {
  name = "search-engine-app"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  metadata = {
    service_account_name = var.service_account_name
    service_account_id = var.service_account_id
    user-data = "${file("./cloud-init.yaml")}"
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      type     = "network-ssd"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.bastion-external-segment.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.secure-bastion-sg.id]
  }

  connection {
    type        = "ssh"
    host        = yandex_compute_instance.search_engine_vm.network_interface.0.nat_ip_address
    user        = var.service_account_name
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }
}
