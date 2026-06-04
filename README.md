# The second challenge

This spins up a basic wordpress server with database and firewalls.
Part of my personal training, trying to understand `Terraform's` full capabilities.

## Goal

Create a Wordpress Environment in Hetzner with:
* Network
* Firewall
* Server
* Volume
* DNS

## Networks, Firewalls

### Networks

Needed to create a private network, because I had a database and volume, these should **Never** be public facing and only communicate with the node, or in this case, server (I guess its the business).

### Firewalls

This I admit was straight out of the documentation, **however**, I manually added three rules, made sure that only three ports were open: `80, 22, 443`.

## Modules

I had already done a *"spin up a server"* and destroy, this time I wanted to do **more**.

Used the repo as the source: https://github.com/Makariuz/up-down/blob/main/modules/server/main.tf

Created a `module` calling that source (notice the `//`, that points to a subfolder in the repo):

```hcl
module "hcloud_server" {
    source = "github.com/Makariuz/up-down//modules/server"
    (...)
}
```

This `source` is a perfect example why modules exist. Do it one, rinse and repeat. Think about something `idempotent`, if your initial setup is good, rinse and repeat, same outcome.

But this one required a few more details than the original, so I manually added location and used `templatefile` for the first time, allowing to pass in `terraform.tfvars` values.

## Templatefile

This was key. Originally I had something like:

```hcl
user_data = <<-EOF
            #!/bin/bash
            apt update && apt upgrade -y
            apt install -y nginx
            EOF
```

But soon realized I needed more and more options, because I was going to have to install `mysql`, `php` etc, and having it all there was clunky and ugly.

### Problem with variables

For the `user_data` I needed to run commands without human interaction, and when I reached the mysql part in [source](https://www.swhosting.com/en/comunidad/manual/how-to-install-wordpress-on-ubuntu-2204-with-lemp) I had to figure out how to do do this.

I found this script that does it:

```bash
#!/bin/bash
PASS=$(pwgen -s 15 1)
USER="CDRT"
DB="drupal"

service mysqld start

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $DB;
CREATE USER '$USER'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $DB.* TO '$USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
echo "Username:   $1"
echo "Password:   $PASS"
```

But still, I shouldn't be writing up variables like that in the user_data, when I have a perfectly acceptable `terraform.tfvars` that could potentially hold this data.

`templatefile` comes in for the rescue, I am able to point to the script **and** add the necessary TF variables, crazy right? At least for me.


## Volume

I thought about just using the server's disk for data, but upon reflection, I realized the importance of a `Volume`, because the `server` might die, might change and lose stuff, so the volume will be able to `Persist` data... which made it click `PersistenVolumes`.

## DNS

yeah so I got the domain from `Netlify` and I'm not able to remove the nameservers to match `Cloudflare` so thats a pin for the future really.
