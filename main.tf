resource "hcloud_network" "skyNet" {
  name     = "sky-net"
  ip_range = "10.0.0.0/16"
}
resource "hcloud_network_subnet" "skySubnet" {
  network_id   = hcloud_network.skyNet.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_firewall" "skyFirewall" {
  name = "sky-firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
    rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
    rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

module "hcloud_server" {
    source = "github.com/Makariuz/up-down//modules/server"

    hcloud_server = {
        name = "sky-server"
        image = "ubuntu-22.04"
        server_type = "cx23"
        owner = "makariuz"
        location = "hl1"
        user_data = templatefile("scripts/cloud-init.sh", {
            DB_PASSWORD = var.DB_PASSWORD
            DB_USER = var.DB_USER
            DB_NAME = var.DB_NAME
        })
    }

    ssh_key = {
    name    = "skynet-ssh-key"
    ssh_key = file("~/.ssh/id_ed25519.pub")

  }
}

resource "hcloud_volume" "skyVolume" {
  name        = "sky-volume"
  size        = 10
  format      = "ext4"
  server_id   = module.hcloud_server.instance_id
  automount   = true
}