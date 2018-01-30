variable account{}

provider "google" {
	credentials = "${file(var.account)}"
	project = "proj1-175509" 
	region = "asia-northeast1"
}

data "google_compute_zones" "available"{}

resource "google_compute_instance" "dev" {
	name = "dev"
	machine_type = "g1-small"
	zone = "${data.google_compute_zones.available.names[0]}"

	boot_disk {
		initialize_params {
			image = "debian-cloud/debian-9"
		}
	}

	network_interface {
		network = "default"

		access_config {
		}
	}

	metadata {
    	sshKeys = "ca09j_nk:${file("~/.ssh/id_rsa.pub")}"
  	}

	provisioner "file" {
		connection {
    		type     = "ssh"
    		user     = "ca09j_nk"
    		private_key = "${file("~/.ssh/id_rsa")}"
  		}

		source = "./scripts/install_docker.sh"
    	destination = "/tmp/install_docker.sh"
	}

	provisioner "remote-exec" {
    	connection {
    		type     = "ssh"
    		user     = "ca09j_nk"
    		private_key = "${file("~/.ssh/id_rsa")}"
  		}
		script = "./install_docker.sh"
  	}
}

resource "google_compute_firewall" "default"{
	name = "allowforss"

	network = "default"
	allow{
		protocol = "tcp"
		ports = ["22"]
	}
}

output "access_ip"{
	value = "${google_compute_instance.dev.network_interface.0.access_config}"
}
