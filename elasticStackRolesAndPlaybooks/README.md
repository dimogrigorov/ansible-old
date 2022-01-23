## Ansible Commands Used
#

Before start executing these commands make sure your public key is copied and password is set:
* ssh-copy-id -i ~/.ssh/id_rsa.pub root@host
* export VAULT_PASSWOD="..."

Ansible playbooks for Elasticsearch, Logstash and Filebeat:
* ansible-playbook logstashApplyRole.yml --vault-password-file ../vault_pass.py -i hosts --user=root
* ansible-playbook elasticSearchApplyRole.yml --vault-password-file ../vault_pass.py -i hosts --user=root
* ansible-playbook startFilebeat.yml -i hosts --ask-become-pass --user=$USER --ask-pass
* ansible-playbook stopFilebeat.yml -i hosts --ask-become-pass --user=$USER --ask-pass
