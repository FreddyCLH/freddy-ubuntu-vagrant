#! /bin/bash

#####
# Home Folder Personalisation
#####
personal_files=$(find /vagrant/provision/vagrant-home/personal/ -type f ! -name README.md)
for f in ${personal_files}
do
  target=${HOME}/`basename ${f}`
  if ! cmp --silent ${f} ${target}; then
    echo "Copying ${f} to ${target}"
    cp ${f} ${HOME}/
    chmod 644 ${target}
  fi
done

#####
# Secrets
#####
# AWS
aws_home=${HOME}/.aws
mkdir -p ${aws_home} && chmod 775 ${aws_home}
aws_secrets=$(find /vagrant/provision/secrets/aws/ -type f ! -name README.md)
for f in ${aws_secrets}
do
  target=${aws_home}/`basename ${f}`
  if ! cmp --silent ${f} ${target}; then
    echo "Copying ${f} to ${target}"
    cp ${f} ${aws_home}/
    chmod 600 ${target}
  fi
done

# GPG
gpg_secrets=$(find /vagrant/provision/secrets/gpg/ -type f ! -name README.md)
for f in ${gpg_secrets}
do
  if grep -Fq 'BEGIN PGP PRIVATE KEY BLOCK' ${f}; then
    gpg_import=$(gpg --allow-secret-key-import --import ${f} 2>&1)
    if [[ ${gpg_import} == *"secret keys imported"* ]]; then
      echo "Imported gpg private key: ${f}"
      echo ${gpg_import}
    elif [[ ! ${gpg_import} == *"secret keys unchanged"* ]]; then
      echo "ERROR importing private gpg key ${f}"
    fi
  fi
done

# Home
home_secrets=$(find /vagrant/provision/secrets/home/ -type f ! -name README.md)
for f in ${home_secrets}
do
  target=${HOME}/`basename ${f}`
  if ! cmp --silent ${f} ${target}; then
    echo "Copying ${f} to ${target}"
    cp ${f} ${HOME}/
    chmod 600 ${target}
  fi
done

# SSH
ssh_home=${HOME}/.ssh
ssh_secrets=$(find /vagrant/provision/secrets/ssh/ -type f ! -name README.md)
for f in ${ssh_secrets}
do
  target=${ssh_home}/`basename ${f}`
  if ! cmp --silent ${f} ${target}; then
    echo "Copying ${f} to ${target}"
    cp ${f} ${ssh_home}/
    chmod 600 ${target}
  fi
done

##### 
# Apt Installations
#####
# Install development tools
sudo apt-get -y install build-essential libssl-dev libffi-dev 

# Install the pythons
sudo apt-get -y install python python3 python3-pip python-dev

# Install Applications
sudo apt-get -y install curl file git meld tree

#####
# Brew packages
#####
# Install brew
command -v brew > /dev/null
if [ $? -ne 0  ]; then
  echo "Installing brew"
  linuxbrew_home="$HOME"
  mkdir -p $linuxbrew_home
  git clone https://github.com/Homebrew/brew $linuxbrew_home/.linuxbrew/Homebrew
  mkdir $linuxbrew_home/.linuxbrew/bin
  ln -s ../Homebrew/bin/brew $linuxbrew_home/.linuxbrew/bin
fi

# Terragrunt
command -v terragrunt > /dev/null
if [ $? -ne 0  ]; then
  echo "Installing terragrunt"
  brew install terragrunt
fi

#####
# Python packages
#####
# AWS
command -v aws > /dev/null
if [ $? -ne 0  ]; then
  echo "Installing aws"
  pip3 install awscli
fi

# Ansible
command -v ansible > /dev/null
if [ $? -ne 0  ]; then
  echo "Installing ansible"
  pip3 install ansible
fi

#####
# Others
#####
# Visual Studio Code
command -v code > /dev/null
if [ $? -ne 0  ]; then
  echo "Installing VSCode"
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

  sudo apt-get -y install apt-transport-https
  sudo apt-get update
  sudo apt-get -y install code # or code-insiders
fi

#####
# Cache Deb Packages
#####
echo "Copying debian packages to /provision/apt/archives/ for faster vagrant recreations."
cp /var/cache/apt/archives/*.deb /provision/apt/archives/
