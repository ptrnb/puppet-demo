This was an exercise performed a number of years ago as part of a selection test for a job. The requirement was to put together a process (ideally using puppet) to provision a new VM and deploy a simple WAR to an Apache and Tomcat stack. This code was put together over a couple of days from a standing start of no prior knowledge of VirtualBox, Vagrant or Puppet.

The solution was recently re-worked to make use of various puppetlab modules.

To demonstrate this example follow these steps:

1. Install VirtualBox on your host

2. Install vagrant on your host

3. Clone this repository
   ````sh
   git clone https://github.com/ptrnb/puppet-demo.git
   ````

4. Cd to puppet-demo and run vagrant
   ````sh
   cd puppet-demo
   vagrant up
   ````

5. Verify successful provisioning of the VM, apache and tomcat by visiting the following address in your browser.
   ````
   http:\\localhost:9080\HelloWorld
   ````

6. To clean up and remove the example VM run
   ````sh
   cd puppet-demo
   vagrant destroy -f
   ````

