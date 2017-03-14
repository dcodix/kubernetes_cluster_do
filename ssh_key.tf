# Create a new SSH key
resource "digitalocean_ssh_key" "terraform" {
    name = "terraform"
    public_key = "${file("~/.ssh/id_rsa_terraform.pub")}"
}