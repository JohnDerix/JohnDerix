# Udemy Ansible course
# Dive Into Ansible - From Beginner to Expert in Ansible
## Installing the Ansible lab
https://github.com/spurin/diveintoansible-lab

## Sectie 1: Course Overview and Introduction to Ansible
1. about intructor James Spurin, founder of diveinto
2. Introduction to Ansible
Modules: https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html

## Sectie 2: Setup of the Lab Environment and Course Resources
3. Precursor: Installing Docker
```bash
April 12th 2021 Update

In the next video, 'Installing Docker', when Installing 'Docker Desktop' for either Mac or Windows, please use v3.2.2 as per the following links and not v3.3.0 -

https://docs.docker.com/docker-for-mac/release-notes/
https://docs.docker.com/docker-for-windows/release-notes/

The v3.3.0 release causes an issue in the course lab images where devices in /dev such as /dev/null, have incorrect permissions, causing issues for non-root users.  These issues relate to an updated Kernel in the latest Docker Desktop release.

There is an updated version of the lab environment that resolves this issue and during the video 'Installing the Ansible Lab' you can use the 'release-candidate' branch from github at the time should you wish to try this.  As this is tested further, I will make the new images the default and will remove this message.

In summary.  If you're looking for consistency when running the course, please use v3.2.2 of Docker Desktop, otherwise, when using v3.3.0 use the release-candidate branch for the lab in 'Installing the Ansible Lab'

Best Regards

James Spurin
```
4. Installing Docker
- Docker Desktop installation for Mac or Windows
- Docker installation for Linux
```bash
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker <username> (e.g. provision user)
sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
/user/local/bin/docker-compose
/user/local/bin/docker-compose version
```
5. Installing the Ansible Lab
Source material: https://github.com/spurin/diveintoansible-lab
  From user directory do:
```bash
git clone https://github.com/spurin/diveintoansible-lab.git
cd ~ 
cd diveintoansible-lab
change CONFIG and ANSIBLE_HOME directories which fits your user folder, check with pwd
```
6. Configuring SSH connectivity between hosts
Check in ~/.ssh/known_hosts for existing accepted keys
```bash
  ssh-keygen -H -F ubunutu1 # ubuntu1 is the server name and check the name with a key in known_hosts
```
or
```bash
  ssh-keygen -H -F 192.168.3.1
```

Create private and public key
```bash
ssh-keygen -t rsa -b 4096 -C "j.derix@johnderix.nl"
cat ~/.ssh/id_rsa.pub 
```

Copy public key to sa erver to login passwordless
```bash
ssh-copy-id <username>@<servername>
```

From Ansible Master
```bash
sudo apt update
sudo apt install sshpass
echo password > password.txt

for user in ansible root
do
  for os in ubuntu centos
  do
    for instance 1 2 3
    do
      sshpass -f password.txt ssh-copy-id -o StrictHostKeyChecking=no ${user}@${os}${instance}
    done
  done
done
```

Remove password file
```bash
rm password.txt
```

Test access by executing ping:
```bash
ansible -i,ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3 all -m ping

rm .ssh/known_hosts
```

7. Setting up the Course Repository
Course Code Repository: https://github.com/spurin/diveintoansible
git clone https://github.com/spurin/diveintoansible.git # on Ansible Master ubuntu-c in user directory ~
ls 

8. Section 1 & 2 Quiz

## Sectie 3: Ansible Architecture and Design
9. Ansible Configuration

10. Ansible Configuration - Supplementary
11. 
