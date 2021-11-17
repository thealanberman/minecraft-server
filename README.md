# Minecraft Server

This project attempts to make an easy to use Minecraft server on demand using Terraform and AWS.

When applied, it will create a modest (but can be configured to be more powerful) EC2 instance within minutes which you can then use
to host a multiplayer Minecraft server.

In order to keep costs down, the server will automatically self-terminate after 30 minutes of inactivity.
("Inactivity" meaning no players are connected to the server.)

To further reduce costs, the world data is backed up to S3 just prior to termination... and restored from S3 when the Terraform is reapplied.
(Just re-apply the Terraform to spin the server back up.)

Downtime costs for the server should be _very_ low, since you're only paying for a few megabytes of S3 storage space.

Uptime costs really just depend on how long your server runs and what size EC2 instance you choose.

# Prerequisites

- An AWS account.
- A usable domain registered via Route53.
- Terraform v1.0 or higher
- Properly configured `~/.aws/config` and `~/.aws/credentials` files.

Usage of AWS + Terraform is beyond the scope of this README.

Usage of SSH is also beyond the scope of this README.

# Instructions

1. Clone this repo.
1. Use `notsketchy.auto.tfvars` as an example and make your own `something.auto.tfvars` with your own preferences.
1. `terraform init`
1. `terraform plan -var-file=something.auto.tfvars`
1. `terraform apply`

This should create the following:

1. EC2 instance running Ubuntu + Minecraft server
1. S3 bucket for storing your Minecraft server world data backups
1. Route53 record for your server.
1. The default username when ssh'ing into your server is **ubuntu**

# More Blathering

Using the `notsketchy.auto.tfvars` example:

1. It creates a server at mc.notsketchy.click
1. It is only ssh accessible from the `allow_ssh_cidr` IP address
1. It is only ssh accessible with the private key that matches `public_key_file`
1. SSH via `ssh -i ~/.ssh/id_ed25519 ubuntu@mc.notsketchy.click`
1. Backup will be at `s3://mcserver{random suffix}/mcserver/backup.tgz`
1. S3 bucket is set to use versioning, in case of corrupted backup.
