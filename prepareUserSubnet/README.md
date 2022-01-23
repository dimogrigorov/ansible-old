## README.md
A quickstart setup to run ansible-playbooks through jenkins. In our initial setup a local jenkins will regularly poll the repository and upon detected changes copy everything to the Alchemy Lab Jenkins. There, a second Jenkins will run  a job that sets the password variable and runs ansible playbook as explained below. This might look convoluted, but is a security consideration. Systems inside the Alchemy Lab do not have the possibility to initiate a connectionto the rest of the internal network.  

## How to run:
From your development workstation:

export VAULT_PASSWORD=*****InsertVaultPassword*****
ansible-playbook prepareSubnet.yml --vault-password-file ./vault_pass.py -i inventory --limit "alchemy2"
Keep in mind that the deployment through jenkins should limit to the sofia_lab group. This accounts for some access security differences between Sofia local network and Sofia Alchemy lab network.

## Motivation
We want to define a whole virtual infrastructure in code. This is supposed to grow into the boilerplate that enables this eventually.  
