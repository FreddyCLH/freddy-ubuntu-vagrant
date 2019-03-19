#! /bin/bash

vagrant_ssh_key_comment="freddy-linux-vagrant"
secondary_disk_dev="/dev/sdc"
secondary_disk_mountpoint="/persistent"

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

# Install Brew
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
# sudo -i -u vagrant /vagrant/provision/vagrant-provision.bash


echo "=== Installing Linux GUI..."
apt-get -y install lubuntu-core --no-install-recommends

# Copy cached debian packages for reuse in quicker subsequent vagrant recreations  
cp /var/cache/apt/archives/*.deb /provision/apt/archives/*.deb

echo "======================================================================"
echo 'If this was your first "vagrant up" then you may need to restart your VM to get your GUI'
echo 'Do this by running: "vagrant reload"'