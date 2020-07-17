variable "auth_token" {
  description="Your Cherryservers API token"
  default=""
}

variable "team_id" {
  description = "Your team ID"
  default = ""
}

resource "cherryservers_ssh" "kontena_ssh" {
  name       = ""
  public_key = file("~/.ssh/Your_ssh.key")
}

variable "cluster_name" {
  default = "pharos"
}

variable "region" {
  default = "EU-East-1"
}

variable "master_plan" {
  default = "161"
}

variable "worker_plan" {
  default = "161"
}

variable "master_count" {
  default = 1
}

variable "worker_count" {
  default = 2
}

variable "host_os" {
  default = "CentOS 7 64bit"
  # You can choose from Ubtuntu 18_04 64bit, Debian 9 64bit, CentOS 7 64bit
}

provider "cherryservers" {
    auth_token = var.auth_token
}

resource "cherryservers_project" "Kontena_Pharos" {
  team_id = var.team_id
  name    = "Kontena_Pharos"
}
/*This will order 1 floating IP to each of the worker nodes
If You need floating IP's for your application 

resource "cherryservers_ip" "floating-ip-kontena-worker" {
    project_id = "${cherryservers_project.Kontena_Pharos.id}"
    region = "${var.region}"
    count = "${var.worker_count}"
}*/ 

resource "cherryservers_server" "pharos_master" {
  count           = var.master_count
  hostname        = "${var.cluster_name}-master-${count.index}"
  plan_id         = var.master_plan
  region          = var.region
  image           = var.host_os
  project_id      = cherryservers_project.Kontena_Pharos.id
  ssh_keys_ids    = [cherryservers_ssh.kontena_ssh.id]
  tags            = {
        Name = "master"
    }
/* Uncomment if you are installing Ubuntu 18.04 64bit
    connection {
      type        = "ssh"
      user        = "root"
      host        = self.primary_ip
      private_key = file("/home/giedriusn/.ssh/kontena_ssh")
    }
    provisioner "remote-exec" {
    inline = [
      "export DEBCONF_NONINTERACTIVE_SEEN=true",
      "export DEBIAN_FRONTEND=noninteractive",
      "export UCF_FORCE_CONFOLD=1",
      "apt update",
      "apt -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" upgrade -y",
      "sudo apt-get -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" -y install curl",
    ]
  }
  */
}
resource "cherryservers_server" "pharos_worker" {
  count        = var.worker_count
  hostname     = "${var.cluster_name}-worker-${count.index}"
  plan_id      = var.worker_plan
  region       = var.region
  image        = var.host_os
  project_id   = cherryservers_project.Kontena_Pharos.id
  ssh_keys_ids = [cherryservers_ssh.kontena_ssh.id]
  tags         = {
        Name = "worker"
   }
#  ip_addresses_ids = ["${cherryservers_ip.floating-ip-kontena-worker.*.id[count.index]}"] <<-- This line will add 1 flaoting IP per worker node

/* Uncomment if you are installing Ubuntu 18.04 64bit
    connection {
      type        = "ssh"
      user        = "root"
      host        = self.primary_ip
      private_key = file("/home/giedriusn/.ssh/kontena_ssh")
    }
    provisioner "remote-exec" {
    inline = [
     "export DEBCONF_NONINTERACTIVE_SEEN=true",
      "export DEBIAN_FRONTEND=noninteractive",
      "export UCF_FORCE_CONFOLD=1",
      "apt update",
      "apt -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" upgrade -y",
      "sudo apt-get -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" -y install curl",
    ]

  }
  */
}

/**output "pharos_hosts" {
  value = {
    masters = {
      address         = "${cherryservers_server.pharos_master.*.primary_ip}"
      private_address = "${cherryservers_server.pharos_master.*.private_ip}"
      role            = "master"
      user            = "root"
    }
    workers = {
      address         = "${cherryservers_server.pharos_worker.*.primary_ip}"
      private_address = "${cherryservers_server.pharos_worker.*.private_ip}"
      role            = "worker"
      user            = "root"
      label = {
        ingress = "nginx"

      }
    }
  }
}**/

output "pharos_cluster" {
  value = {
    hosts = [
      for host in concat(cherryservers_server.pharos_master, cherryservers_server.pharos_worker)  : {
        address           = host.primary_ip
        private_address   = host.private_ip
        role              = host.tags["Name"]
        user              = "root"
      }
    ]
  }
}



