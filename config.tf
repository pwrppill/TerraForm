terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.86.0"
    }
  }
}

resource "yandex_compute_instance" "build" {
  name = "build"
  platform_id = "standard-v3"
  zone = "ru-central1-b"

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

   scheduling_policy {
    preemptible = "true"
  }

  boot_disk {
    initialize_params {
        image_id = "fd8c3dv7t6prd7j4n162"
        size = 8
    }
  }

 network_interface {
    subnet_id = "e2ls0jo68rhkjcrtkntj"
    nat = "true"
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys = "cbrkd:${file("/home/cbrkd/.ssh/id_rsa.pub")}"
#    user-data = "${file("/home/cbrkd/hw12/user-conf.yaml")}"
    user-data = <<EOF
#!/bin/bash
sudo apt update && sudo apt install maven openjdk-8-jdk git curl unzip -y
git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
cd boxfuse-sample-java-war-hello
mvn package
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
export AWS_ACCESS_KEY_ID=*****
export AWS_SECRET_ACCESS_KEY=*****
aws --endpoint-url=https://storage.yandexcloud.net s3 cp target/hello-1.0.war s3://new-one/
EOF
 }
}

resource "yandex_vpc_address" "addr" {
  name = "external_ip"

  external_ipv4_address {
    zone_id = "ru-central1-b"
  }
}

resource "yandex_compute_instance" "deploy" {
  name = "deploy"
  platform_id = "standard-v3"
  zone = "ru-central1-b"

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

   scheduling_policy {
    preemptible = "true"
  }

  boot_disk {
    initialize_params {
        image_id = "fd8c3dv7t6prd7j4n162"
        size = 8
    }
  }

 network_interface {
    subnet_id = "e2ls0jo68rhkjcrtkntj"
    nat = "true"
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys = "cbrkd:${file("/home/cbrkd/.ssh/id_rsa.pub")}"
#    user-data = "${file("/home/cbrkd/hw12/user-conf.yaml")}"
    user-data = <<EOF
#!/bin/bash
sleep 300
sudo apt update && sudo apt install tomcat9 awscli -y
export AWS_ACCESS_KEY_ID=*****
export AWS_SECRET_ACCESS_KEY=*****
aws --endpoint-url=https://storage.yandexcloud.net s3 cp s3://new-one/hello-1.0.war /var/lib/tomcat9/webapps
EOF
 }
}

resource "yandex_vpc_address" "addr1" {
  name = "external_ip"

  external_ipv4_address {
    zone_id = "ru-central1-b"
  }
}