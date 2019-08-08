#! /bin/bash

vagrant_ssh_key_comment="freddy-linux-vagrant"
secondary_disk_dev="/dev/sdc"
secondary_disk_mountpoint="/persistent"
is_install_apps=true

# Add SSH key for vagrant user
grep "$vagrant_ssh_key_comment" /home/vagrant/.ssh/authorized_keys > /dev/null
if [ $? -ne 0  ]; then
  echo "Adding $vagrant_ssh_key_comment to vagrant ssh authorized keys"
  cat /provision/vagrant-ssh/freddy_linux_vagrant_id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
fi

# Format and Mount Secondary Disk
check_secondary_disk_fstype=$(lsblk -o FSTYPE $secondary_disk_dev)
if [[ $check_secondary_disk_fstype != *"ext4"* ]]; then
  echo "Formating $secondary_disk_dev"
  mkfs.ext4 $secondary_disk_dev
fi

check_secondary_disk_mountpoint=$(lsblk -o MOUNTPOINT $secondary_disk_dev)
if [[ $check_secondary_disk_mountpoint != *"$secondary_disk_mountpoint"* ]]; then
  echo "Mounting $secondary_disk_dev to $secondary_disk_mountpoint"
  mkdir -p $secondary_disk_mountpoint
  mount -o defaults $secondary_disk_dev $secondary_disk_mountpoint
fi

grep $secondary_disk_dev /etc/fstab > /dev/null
if [ $? -ne 0  ]; then
  echo "$secondary_disk_dev  $secondary_disk_mountpoint  ext4  defaults  0 2" >> /etc/fstab
fi

# Secondary disk file system permissions
chmod 755 ${secondary_disk_mountpoint}

# Persistent vagrant directory permissions
if [[ ! -d ${secondary_disk_mountpoint}/vagrant ]]; then
  mkdir $secondary_disk_mountpoint/vagrant
fi
chown -R vagrant: ${secondary_disk_mountpoint}/vagrant

# Apt updates
cp /provision/apt/archives/*.deb /var/cache/apt/archives/
apt-get -y update

# Symlink git
mkdir -p $secondary_disk_mountpoint/vagrant/git
chown vagrant:vagrant $secondary_disk_mountpoint/vagrant/git
if [ ! -d /home/vagrant/git ]; then
  echo "Creating symlink /home/vagrant/git"
  ln -s $secondary_disk_mountpoint/vagrant/git /home/vagrant/git
  chown -h vagrant:vagrant /home/vagrant/git
fi

# Symlink VSCode-WorkSpaces
mkdir -p $secondary_disk_mountpoint/vagrant/VSCode-Workspaces
chown vagrant:vagrant $secondary_disk_mountpoint/vagrant/VSCode-Workspaces
if [ ! -d /home/vagrant/VSCode-Workspaces ]; then
  echo "Creating symlink /home/vagrant/VSCode-Workspaces"
  ln -s $secondary_disk_mountpoint/vagrant/VSCode-Workspaces /home/vagrant/VSCode-Workspaces
  chown -h vagrant:vagrant /home/vagrant/VSCode-Workspaces
fi

# Symlink .vscode
mkdir -p $secondary_disk_mountpoint/vagrant/vscode
chown vagrant:vagrant $secondary_disk_mountpoint/vagrant/vscode
if [ ! -d /home/vagrant/.vscode ]; then
  echo "Creating symlink /home/vagrant/.vscode"
  ln -s $secondary_disk_mountpoint/vagrant/vscode /home/vagrant/.vscode
  chown -h vagrant:vagrant /home/vagrant/.vscode
fi

echo "=== Installing linux GUI..."
apt-get -y install lubuntu-core --no-install-recommends
apt-get -y install lxrandr

# Copy cached debian packages for reuse in quicker subsequent vagrant recreations
echo "Copying debian packages to /provision/apt/archives/ for faster vagrant recreations."
cp /var/cache/apt/archives/*.deb /provision/apt/archives/

# Drop .bashrc
grep "# Vagrant provisioned" /home/vagrant/.bashrc > /dev/null
if [ $? -ne 0  ]; then
  echo "Provisioning vagrant user .bashrc"
  cp /provision/vagrant-home/bashrc /home/vagrant/.bashrc
  chown vagrant:vagrant /home/vagrant/.bashrc && chmod 644 /home/vagrant/.bashrc
fi

echo "# ======================================================================"
echo '# If this was your first "vagrant up" then you may need to restart your VM to get your GUI'
echo '# Do this by running: "vagrant reload"'
echo '#'
echo '# You can provision applications by executing /vagrant/provision/vagrant-provision.bash on the virtual machine instance.'
