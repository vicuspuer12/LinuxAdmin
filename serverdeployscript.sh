#!/bin/bash

# make sure we have the correct user
useradd -c "<user comment>" -s /bin/bash -d /mnt/data/<server user account> -g users -u 1002 <server user account>
passwd -l <server user account>

# check if these exist and upgrade them if necessary
zypper install -y python3-virtualenv python39

# check if we have our virtual enviroment set up -- this will problem only need to run once on the first instance
if [ ! -d ~<server user account>/python3.9 ]; then
  mkdir ~<server user account>/python3.9
  chown <server user account> ~<server user account>/python3.9

  # install local python environment
  su - ibot -c "virtualenv --python=python3.9 ~/python3.9"
fi

# install / update additional pip modules
su - <server user account> -c "source ~/python3.9/bin/activate && pip install <fdb pandas termcolor etc.>"

# add the system services and start them up
for s in $(ls /mnt/data/<server user account>/scripts/<server user account>.service); do
  chmod 644 $s && rsync -a $s /etc/systemd/system 
  systemctl daemon-reload 
  systemctl enable --now $s
done
