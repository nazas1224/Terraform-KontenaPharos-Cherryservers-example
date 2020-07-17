# Terraform-KontenaPharos-Cherryservers-example
Terraform Example for Kontena Pharos on Cherryservers

# Prerequisities:
* Kontena Pharos toolchain installed locally
* Terraform v12.x installed locally
* Terraform Provider Cherryservers (http://downloads.cherryservers.com/other/terraform/)
* Cherryservers.com credentials (api key, Team ID)

# Setup Kontena Pharos CLI Toolchain:

```
$ curl -s https://get.k8spharos.dev | bash

$ chpharos install latest --use
```
# Prepare Nodes for Kubernetes Cluster:

Note: Works with CentOS 7 64bit, Ubuntu 18_04 64bit and Debain 9 64bit images.

Update variables in main.tf file

Note: If you are using Ubuntu 18_04 64bit please uncomment the following lines in main.tf file for both master and worker configurations:
```
 connection {
      type        = "ssh"
      user        = "root"
      host        = self.primary_ip
      private_key = file("~/.ssh/Your_ssh.key")
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
```

```
$ ./terraform apply
```
after its complete update cluster.yml file:
add additional addons or other configurations depending on your needs.

# Bootstrap your First Pharos Kubernetes Cluster using Terraform

```
$ ./terraform output -json > tf.json

$ pharos up -c cluster.yml --tf-json tf.json
```
