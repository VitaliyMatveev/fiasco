# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

$PROVISION_SCRIPT = <<SCRIPT
  echo "StrictHostKeyChecking no" > ~/.ssh/config
  echo "UserKnownHostsFile=/dev/null no" >> ~/.ssh/config
  apt-add-repository -y ppa:ansible/ansible
  apt-get update -q && apt-get install -y software-properties-common git ansible

  cd /home/vagrant/fiasco/provisioning/
  echo -e "\nInstall roles:"
  ansible-galaxy install -r requirements.yml --force
  echo -e "\nRun asnible playbook localy:"
  PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ansible-playbook \
  dev.yml \
  -i inventory \
  -u vagrant \
  -c local
SCRIPT

Vagrant.configure(2) do |config|

  guest_port = 3000
  host_port = 8085
  dev_ip = "192.168.33.99"
  config.vm.box = "ubuntu/trusty64"
  config.vm.network 'forwarded_port',  guest:
  guest_port, host: host_port
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.memory = 8000
  end

  config.vm.define "dev", primary: true do |dev|
    dev.vm.hostname = "fsc-dev"
    dev.vm.network "private_network", ip: dev_ip
    dev.ssh.forward_agent = true
    dev.vm.synced_folder "./", "/vagrant", disabled: true
    dev.vm.synced_folder "./", "/home/vagrant/fiasco", owner: "vagrant", group: "vagrant"
    dev.vm.post_up_message = "Ready to development. Use \'vagrant ssh\' and \'bundle install\' after.
    Virtual machine ip address: #{dev_ip}
    You can run rails on port: #{guest_port}.
    Site will be aviable on http://#{dev_ip}:#{host_port}"

    dev.vm.provision "shell", keep_color: true, inline: $PROVISION_SCRIPT
  end

end
