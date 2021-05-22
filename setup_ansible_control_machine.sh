### https://www.howtoforge.com/tutorial/setup-new-user-and-ssh-key-authentication-using-ansible/
## Step 1 - Setup Ansible control machine
# We will install python and ansible on the ansible 'control machine' by running the following command.
sudo apt install python ansible -y

# Add new user 'provision' and give the user a password.
useradd -m -s /bin/bash provision
passwd provision

# Now add the 'provision' user for sudo without the password by creating new configuration file under the '/etc/sudoers.d/' using the command below.
echo  -e 'provision\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/provision
# A new user has been created, and now it can use sudo without a password.

## Step 2 - Define User and SSH Key
# Make sure the 'whois' package is installed on the system, or you can install using the following command.
sudo apt install whois -y
# And you will get the SHA-512 encrypted password.

# Encrypt the 'Provision01!' password using the command below.
mkpasswd --method=SHA-512
Password: Provision01!
$6$2nZ5CA..Oz$nO27UjmxuGErdQZFHvo2OIGmJYfD7rzPaRNeOeQQRqmZtz5A1hIv7tMhuHbNYJH1XIUIxzKK2NQHsDlq/ojdJ1

# Next, we will generate a new ssh-key.
# Login to the 'provision' user and generate the ssh key using the ssh-keygen command.
su - provision # if not already logged in as provision
ssh-keygen -t rsa -b 4096 -C "j.derix@johnderix.nl"
# Now the user and password have been defined, and the ssh key has been created l(ocated at the '.ssh' directory).

## Step 3 - Create new inventory
# Login as the 'provision' user and create a new directory for the project.
su - provision
mkdir -p ansible/

# Go to the 'ansible' directory and create a new inventory file 'inventory.ini' using vim.
cd ansible/
nano inventory.ini
# Paste the following configuration there. After 1st run of playbook change the user to provision
[pi]
stark02 ansible_host=192.168.3.12 ansible_user=pirate
# Save and exit.

# Now create a new ansible configuration file 'ansible.cfg'.
nano ansible.cfg
# Paste the following configuration there.
[defaults]
inventory = /home/provision/ansible/inventory.ini
# Save and exit.

## Step 4 - Create Ansible Playbook
# Ansible Playbook is set of instructions that you send to run on a single or group of server hosts. It represents the ansible-provisioning, where the automation is defined as tasks, and all jobs like installing packages, editing files, will be done by ansible modules.
# In this step, we will create a new ansible playbook to deploy a new user, deploy the ssh key, and configure the ssh service.
# Before we create a new ansible playbook, we will scan all server fingerprint using the ssh-keyscan command as below.

ssh-keyscan stark02 >> ~/.ssh/known_hosts
# ssh-keyscan 10.0.15.22 >> ~/.ssh/known_hosts
# Those servers fingerprint will be stored at the '.ssh/known_hosts' file.

# Note:
# If you have a lot of server nodes, you can save your host list and then manually scan the ssh key fingerprint using bash script as shown below.
for i in $(cat list-hosts.txt)
do
ssh-keyscan $i >> ~/.ssh/known_hosts
done

# Next, create the ansible playbook named 'deploy-ssh.yml' using nano.
nano deploy-ssh.yml

# Paste following the ansible playbook there.
---
 - hosts: all
   vars:
     - provision_password: '$6$2nZ5CA..Oz$nO27UjmxuGErdQZFHvo2OIGmJYfD7rzPaRNeOeQQRqmZtz5A1hIv7tMhuHbNYJH1XIUIxzKK2NQHsDlq/ojdJ1'
   gather_facts: no
   remote_user: root

   tasks:

   - name: Add a new user named provision
     user:
          name=provision
          password={{ provision_password }}

   - name: Add provision user to the sudoers
     copy:
          dest: "/etc/sudoers.d/provision"
          content: "provision  ALL=(ALL)  NOPASSWD: ALL"

   - name: Deploy SSH Key
     authorized_key: user=provision
                     key="{{ lookup('file', '/home/provision/.ssh/id_rsa.pub') }}"
                     state=present

   - name: Disable Password Authentication
     lineinfile:
           dest=/etc/ssh/sshd_config
           regexp='^PasswordAuthentication'
           line="PasswordAuthentication no"
           state=present
           backup=yes
     notify:
       - restart ssh

   - name: Disable Root Login
     lineinfile:
           dest=/etc/ssh/sshd_config
           regexp='^PermitRootLogin'
           line="PermitRootLogin no"
           state=present
           backup=yes
     notify:
       - restart ssh

   handlers:
   - name: restart ssh
     service:
       name=sshd
       state=restarted
# Save and exit.

# On the playbook script:
#- we create the 'deploy-ssh.yml' playbook script to be applied on all servers defined in the 'inventory.ini' file.
#- we create the ansible variable 'provision_password', containing the encrypted password for the new user.
#- Set the Ansible facts to 'no'.
#- Define the 'root' user as a remote user to perform tasks automation.
#- We create new tasks for adding a new user, add the user to the sudoers, and upload the ssh key.
#- We create new tasks for configuring the ssh services, disabling the root login, and disable password authentication. Tasks for configuring the ssh will trigger the 'restart ssh' handlers.
#- We create a handler to restart the ssh service.

## Step 5 - Run the Playbook
# Login to the 'provision' user and go to the 'ansible01' directory.
su - provision
cd ansible/

# Now run the the 'deploy-ssh.yml' playbook using the command as shown below.
ansible-playbook deploy-ssh.yml --become --ask-pass
# Type your root password, and you will get the result as below.
# All tasks for deploying a new user and ssh key have been completed successfully.
# Change ansible_user in inventory to provision like mentioned in the beginning.

## Step 6 - Testing
# Test using ansible command.
ansible pi -m ping
ansible pi -m shell -a id
# Now you will get the green messages as below.

# Now we can manage those 'ansi01' and 'ansi02' servers using Ansible, and the 'provision' user will be default user for Ansible.
# Testing connection to the servers
ssh stark02
# And you will be connected to each server using the default key '.ssh/id_rsa' file, and using the user 'provision'.
