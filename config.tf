terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.86.0"
    }
  }
}

# provider "yandex" {
#  token                    = "YC_TOKEN"
#  cloud_id                 = "YC_CLOUD_ID"
#  folder_id                = "YC_FOLDER_ID"
#  zone                     = "yc-ru-central1-b"
#}

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
    ssh-keys = "cbrkd:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDW4oAM6dFpQXgKdyJms+C6pyiX7uC4gfL4JdgovJN+m65uMzgQGMbMCuHz4unBPI0utQQy57LxRCSEhU08pJBvClpxpNVGa6rXG2nFIStY2D0g4sKWC7iIAbWmmIgFi/zD8U8f03tfMudiLt3sKaI5kbMmKzBALqeVR7OG+eDReq9DTJkFxPK4F1S3Pz7YUjg3+t/KU7IQJQXxl5RNLYweuaiolejsT4zNbY57jvwnnNzVSfNdflkCcDku5UvtlX8O8UpgQh8Ntqyh4DVT4RyFi67tZQgvcjhxnQMLK7gjygG6Nu57RbhnHcRX5GIV56sKbGFPSOYSy/Be0L4pinAMvGGdW+kENawjpep3xkpmj9uR4rfiH6iMjjyc7C1APOMYov8KYhmyvn6D+wNdne39uOSkjgqCbOU/VgBDAbA+4mYsJ2Wh+zd2USE/K9uL5IhKp1SLBisJogrIP5WoRT6fgRXvqMlS+p9E/K4Qhsb5IeKdd48WaBm7Za8TZHY1Jo8= cbrkd@vm-118"
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
export AWS_ACCESS_KEY_ID=YCAJE0F3oZ1uGLB-9BqNNfdel
export AWS_SECRET_ACCESS_KEY=YCMUOPIwSOgAtChRB5pB5FSwegS-tadYsGPcswUC
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