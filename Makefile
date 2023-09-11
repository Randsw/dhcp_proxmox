SSH_PR_KEY_PATH = ${SSH_PRIVATE_KEY_PATH}

#Plan VM with terraform
.PHONY: plan
plan:
	cd terraform/ && terraform plan -var-file="credential.tfvars" -var-file="terraform.tfvars"

#Build VM using terrfarom
.PHONY: apply
apply:
	cd terraform/ &&	terraform apply -auto-approve -var-file="credential.tfvars" -var-file="terraform.tfvars"

#Delete VM using terrfarom
.PHONY: destroy
destroy:
	cd terraform/ && terraform destroy -auto-approve -var-file="credential.tfvars" -var-file="terraform.tfvars"

# Test ntp role
.PHONY: ntp_test
ntp_test:
	cd ansible/roles/oefenweb.ntp && molecule test

# Test dhcp role
.PHONY: dhcp_test
dhcp_test:
	cd ansible/roles/bertvv.dhcp && molecule test

.PHONY: tests
tests: cd ansible/ && molecule test

#DNS server provision
.PHONY: provision
provision:
	cd ansible/ && ansible-playbook -i inventories/dhcp/hosts.yml -e "ansible_ssh_private_key_file=$(SSH_PR_KEY_PATH)" dhcp-deploy.yml -vvv

