## Ansible Commands Used
#
* ansible-playbook logstashApplyRole.yml --vault-password-file ../vault_pass.py -i hosts
* ansible-playbook elasticSearchApplyRole.yml --vault-password-file ../vault_pass.py -i hosts
* ansible-playbook startFilebeat.yml -i hosts --ask-become-pass --user=$USER --ask-pass
* ansible-playbook stopFilebeat.yml -i hosts --ask-become-pass --user=$USER --ask-pass
