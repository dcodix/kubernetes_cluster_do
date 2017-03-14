# Create a new tag
resource "digitalocean_tag" "kubernetes-master" {
    name = "kubernetes-master"
}

# Create redis droplet
resource "digitalocean_droplet" "kubernetes-master" {
    image = "centos-7-0-x64"
    name = "kubernetes-master"
    region = "nyc3"
    size = "512mb"
    tags   = ["kubernetes-master"]
    private_networking = true
    ssh_keys = ["${digitalocean_ssh_key.terraform.id}"]

 provisioner "remote-exec" {
      inline = ["ls"]
  }

 provisioner "local-exec" {
      command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key ~/.ssh/id_rsa_terraform --user=root -i \"${self.ipv4_address},\" ${path.module}/ansible/kubernetes-master.yml --vault-password-file .vaultpass"
  }

}

output "master_public_ipv4" {
    value = "${digitalocean_droplet.kubernetes-master.ipv4_address}"
}
output "master_private_ipv4" {
    value = "${digitalocean_droplet.kubernetes-master.ipv4_address_private}"
}