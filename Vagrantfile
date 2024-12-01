#if Vagrant::VERSION < "2.0.0"
#  $stderr.puts "Must redirect to new repository for old Vagrant versions"
#  Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')
#end

NUM_WORKER_NODES=5
METRIC_NODE_ID=NUM_WORKER_NODES + 1
IP_NW="192.168.56."
IP_START=150
PUB_SSH_KEY_FILE="/Users/nareshmaharaj/.ssh/id_ed25519.pub"
REMOTE_SSH_FILENAME="/home/vagrant/id_ed25519.pub"

ALLOW_METRICS = false

Vagrant.configure("2") do |config|
  config.vm.box = "generic/centos9s"
  config.vm.box_version = "4.3.12"
  config.vm.box_check_update = false
  config.vm.synced_folder "shared/", "/shared", create: true
  config.vm.synced_folder "data/", "/data", create: true
  config.vm.provision "file", source: "#{PUB_SSH_KEY_FILE}", destination: "#{REMOTE_SSH_FILENAME}"
  config.vm.provision "shell", inline: <<-SHELL
    cat "#{REMOTE_SSH_FILENAME}" >> /home/vagrant/.ssh/authorized_keys
    rm "#{REMOTE_SSH_FILENAME}"  # Clean up after copying
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers && sudo visudo -cf /etc/sudoers
  SHELL

  (1..NUM_WORKER_NODES).each do |i|
    config.vm.define "broker0#{i}" do |node|
      node.vm.hostname = "broker0#{i}"
      node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        vb.customize ['modifyvm', :id, '--macaddress1', "08002700005" + "#{i}"]
        vb.customize ['modifyvm', :id, '--natnet1', "10.0.5" + "#{i}.0/24"]
        vb.name = "broker0#{i}"
        vb.memory = 4096
      end
    end
  end

  if ALLOW_METRICS
    config.vm.define "obs0#{METRIC_NODE_ID}" do |node|
      node.vm.hostname = "obs#{METRIC_NODE_ID}"
      node.vm.network "private_network", ip: IP_NW + "#{METRIC_NODE_ID}"
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        vb.customize ['modifyvm', :id, '--macaddress1', "08002700005" + "#{METRIC_NODE_ID}"]
        vb.customize ['modifyvm', :id, '--natnet1', "10.0.5" + "#{METRIC_NODE_ID}.0/24"]
        vb.name = "obs0#{METRIC_NODE_ID}"
        vb.memory = 4096
      end
    end
  end
end
