#!/usr/bin/env bash

# make minecraft folder
mkdir -p /opt/minecraft

# download minecraft server
curl -o /opt/minecraft/mcserver.jar ${server_jar_url}

# agree to EULA
echo "eula=true" >> /opt/minecraft/eula.txt

# install java
apt update && apt install -y \
  openjdk-16-jre-headless \
  awscli \
  net-tools

# get the bucket name
s3_bucket=$(/usr/bin/aws s3 ls | grep ${s3_bucket_prefix} | awk '{ print $3 }')

# if there's a backup, restore it
if /usr/bin/aws s3 ls $s3_bucket | grep -q backup.tgz; then
  /usr/bin/aws s3 cp s3://$s3_bucket/mcserver/backup.tgz /tmp/
  tar xvzf /tmp/backup.tgz --directory /opt/minecraft
fi

# create minecraft server systemd service
cat << EOF > /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
After=network.target

[Service]
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar mcserver.jar --noconsole

[Install]
WantedBy=multi-user.target
EOF

# create idle monitoring service
cat << EOF > /etc/systemd/system/terminate-when-idle.service
[Unit]
Description=Terminate the instance when idle
After=minecraft.service

[Service]
ExecStart=/usr/local/bin/terminate-when-idle

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /usr/local/bin/terminate-when-idle
#!/usr/bin/env bash
set -x
IDLE=0
while [[ \$IDLE -le 30 ]]; do
  if netstat -ntp | grep ESTABLISHED.*java; then
    IDLE=0
  else
    ((IDLE++))
  fi
  sleep 60
done
shutdown now
EOF

chmod +x /usr/local/bin/terminate-when-idle

# create backup script
cat << EOF > /usr/local/bin/backup-to-s3
#!/usr/bin/env bash
set -x

# nuke and pave
rm -f /tmp/backup.tgz

# tar+gzip the minecraft data
pushd /opt/minecraft
tar -zc -f /tmp/backup.tgz --exclude *.jar *
popd

# upload data to S3
/usr/bin/aws s3 cp /tmp/backup.tgz s3://$s3_bucket/mcserver/
EOF

chmod +x /usr/local/bin/backup-to-s3

# systemd service to run on shutdown
cat << EOF > /etc/systemd/system/backup-to-s3.service
[Unit]
Description=Backup Minecraft data to S3
DefaultDependencies=no
Before=halt.target shutdown.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-to-s3
RemainAfterExit=yes

[Install]
WantedBy=halt.target shutdown.target
EOF

# reload systemd daemon to pick up service file
systemctl daemon-reload

# run the systemd service
systemctl start minecraft.service
systemctl start terminate-when-idle
