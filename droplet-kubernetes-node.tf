# Create a new tag
resource "digitalocean_tag" "kubernetes-node" {
    name = "kubernetes-node"
}

# Create redis droplet
resource "digitalocean_droplet" "kubernetes-node" {
    image = "centos-7-0-x64"
    name = "kubernetes-node-${count.index}"
    region = "nyc3"
    size = "512mb"
    tags   = ["kubernetes-node"]
    private_networking = true
    ssh_keys = ["${digitalocean_ssh_key.terraform.id}"]
    count = "${var.n_nodes}"

 provisioner "remote-exec" {
      inline = ["ls"]
  }

 provisioner "local-exec" {
      command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key ~/.ssh/id_rsa_terraform --user=root -i \"${self.ipv4_address},\" ${path.module}/ansible/kubernetes-node.yml --extra-vars 'minion_n=${count.index}' --extra-vars 'kubernetes_master_ipv4=${digitalocean_droplet.kubernetes-master.ipv4_address_private}' --vault-password-file .vaultpass"
  }

}

output "node_public_ipv4" {
    value = "${digitalocean_droplet.kubernetes-node.ipv4_address}"
}
output "node_private_ipv4" {
    value = "${digitalocean_droplet.kubernetes-node.ipv4_address_private}"
}