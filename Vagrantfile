
NODES = {
    "linux-vm" => {
        "box" => "ubuntu/focal64",
        "cpus" => 2,
        "memory" => 2048,
        "ip" => "192.168.56.11",
    }
}

Vagrant.configure("2") do |config|
    NODES.each do |(name, params)|
        config.vm.define "#{name}" do |c|
            c.vm.box = "#{params['box']}"
            c.vm.hostname = "#{name}"
            c.vm.network "private_network", ip: "#{params['ip']}", netmask: "255.255.255.0", name: "vboxnet0"
            c.vm.provider "virtualbox" do |vb|
                vb.memory = params['memory']
                vb.cpus = params['cpus']
                vb.customize ["modifyvm", :id, "--audiocontroller", "sb16"]
            end
        end
    end
end