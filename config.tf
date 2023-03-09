terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.86.0"
    }
  }
}

provider "yandex" {
  token                    = "t1.9euelZqNiZaTnJfIncuLx4mVi8-Zz-3rnpWakJCLk5WRis2Xm8mMzsbHkJfl8_ckZVhf-e9-KSBn_N3z92QTVl_5734pIGf8.UtNjvvX3pC_78zi_InCg57Z4Mjhhxj0s9BkHwKjsBvD_mYKn_WbTgvcAAvuuufMXcSQIR7_tmCDxp1Hgb6ZnCQ"
  cloud_id                 = "b1ghohej84dqkjrp3q5c"
  folder_id                = "b1g7go6choequ3len90f"
  zone                     = "yc-ru-central1-b"
}

resource "yandex_compute_instance" "test_vm" {
  name = "test_vm"
  platform_id = "standard-v3"
  zone = "ru-central1-b"

  resources {
    core_fraction = 20
    cores = 2
    memory = 2
  }

  boot_disk {
    initialyze_params {
        image_id = "fd8emvfmfoaordspe1jr"
    }
  }
   
  network_interface {
    subnet_id = "${yandex_vpc_subnet.foo.id}" 
  }

  metadata = {
    foo = "root"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

  resource "yandex_vpc_network" "foo" {}

  resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.foo.id}"
  v4_cidr_blocks = ["10.5.0.0/24"]
}
