# when combined these will result in mc.notsketchy.click
subdomain = "mc"
domain    = "notsketchy.click"

# the IP address range your server will allow SSH from
# you should probably set this to your home IP
allow_ssh_cidr = "8.17.92.42/32"

# SSH public key that will be injected on the server
public_key_file = "~/.ssh/id_ed25519.pub"

# if using a non-graviton instance type, be sure to change arm64 to amd64
instance_type = "t4g.medium"
architecture  = "arm64"

# this will be downloaded on launch and run via minecraft.service
server_jar_url = "https://download.getbukkit.org/spigot/spigot-1.17.1.jar"

# S3 prefix and sub-directory for backups (not necessary to change these)
bucket_prefix = "mcserver"
bucket_key    = "mcserver"
# keep 7 days worth of backups history, just in case
versioning                    = true
noncurrent_version_expiration = 7
