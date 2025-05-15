terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.84.0"
    }
  }
  
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terraform-state-bucket"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# Создание VPC сети
resource "yandex_vpc_network" "network" {
  name = "${var.project_name}-network"
}

# Создание подсети
resource "yandex_vpc_subnet" "subnet" {
  name           = "${var.project_name}-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.2.0.0/16"]
}

# Создание группы безопасности
resource "yandex_vpc_security_group" "sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for ${var.project_name}"
  network_id  = yandex_vpc_network.network.id

  # Разрешаем входящий трафик на порты 80, 443, 22
  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Grafana"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Разрешаем весь исходящий трафик
  egress {
    protocol       = "ANY"
    description    = "All outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Создание виртуальной машины
resource "yandex_compute_instance" "vm" {
  name        = "${var.project_name}-server"
  platform_id = "standard-v1"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 30
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  }

  # Подготовка сервера после создания
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].nat_ip_address
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io docker-compose git",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ${var.vm_user}",
      "mkdir -p /home/${var.vm_user}/app"
    ]
  }

  # Копирование файлов проекта на сервер
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].nat_ip_address
    }

    source      = "../"
    destination = "/home/${var.vm_user}/app"
  }

  # Запуск приложения
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].nat_ip_address
    }

    inline = [
      "cd /home/${var.vm_user}/app",
      "sudo docker-compose up -d"
    ]
  }
}

# Создание DNS-записи
resource "yandex_dns_zone" "zone" {
  name        = "${var.project_name}-zone"
  description = "Public zone for ${var.domain}"
  zone        = "${var.domain}."
  public      = true
}

resource "yandex_dns_recordset" "rs" {
  zone_id = yandex_dns_zone.zone.id
  name    = "${var.domain}."
  type    = "A"
  ttl     = 600
  data    = [yandex_compute_instance.vm.network_interface[0].nat_ip_address]
}

resource "yandex_dns_recordset" "rs_www" {
  zone_id = yandex_dns_zone.zone.id
  name    = "www.${var.domain}."
  type    = "A"
  ttl     = 600
  data    = [yandex_compute_instance.vm.network_interface[0].nat_ip_address]
}

# Вывод IP-адреса сервера
output "server_ip" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}
