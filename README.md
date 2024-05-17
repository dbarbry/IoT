# Inception of Things (IoT)

## Important commands

```
vagrant up
```

to execute a Vagrantfile.

```
vagrant halt
```

to stop a machine.

```
vagrant destroy
```

to delete everything the Vagrantfile did.

```
vagrant ssh <machineName>
```

to coonnect with ssh to a machine.

```
vagrant status
```

to see a list of the actually running machines.

## Quick explainations

The same way we use a Dockerfile with docker, here we use a Vagrantfile with vagrant. This file contains all the informations about the vm itself, size, memory required, CPU, name, shared files, network protocols and params... etc. In this project I use VirtualBox with Vagrant.

### P1

Here we are gonna create 2 vm. One worker, and one server which is the main node of our kubernetes cluster. We use k3s for this first part. The difficult part is to find the precise command with the right params to install k3s as the main node, plus k3s and I guess kubernetes in general uses env variable for configuration which was special to understand at first.

To explain quickly what happens in our script, the Vagrantfile create 2 vm with the same stats, only changing the name and the IP address. It also calls two different scripts for each vm, server.sh for the main node, and worker.sh for the first worker. The server is gonna install k3s in server mode, then share the token to join its cluster in /vagrant_shared folder, which correspond to our /confs folder. Then simply adding aliases and update env variables to fit the subject we have. The worker is then gonna initiate itself, then install k3s in worker mode using the token shared by the master, to join the cluster and be a functionnal worker. Same thing with the aliases and variables and we are done.

### P2

Here we only need one vm, with k3s in server mode installed, the changes are inside the configuration file, so the server.sh script cause we need to add a lot of things to this master node server.

## Important doc

[https://docs.k3s.io/quick-start]https://docs.k3s.io/quick-start
[https://akos.ma/blog/vagrant-k3s-and-virtualbox/]https://akos.ma/blog/vagrant-k3s-and-virtualbox/
