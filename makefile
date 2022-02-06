SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c  
.DELETE_ON_ERROR:
	
TEST_DIR = tests
	
TEST_DIR_1 = $(TEST_DIR)/1-within-az-private-ip
TEST_DIR_2 = $(TEST_DIR)/2-between-az-private-ip
TEST_DIR_3 = $(TEST_DIR)/3-within-az-public-ip
TEST_DIR_4 = $(TEST_DIR)/4-between-az-public-ip
TEST_DIR_5 = $(TEST_DIR)/5-between-region-public-ip

NUM_DOWNLOADS = 10

# Taken from environment variable
WORKSPACE = ${CURRENT_WORKSPACE}

# Init Terraform if not init already
%/.terraform.lock.hcl: 
	-terraform workspace new $(WORKSPACE)
	terraform workspace select $(WORKSPACE);\
	terraform -chdir='$(@D)' init

.PHONY: 1
1: $(TEST_DIR_1)/.terraform.lock.hcl
	-terraform -chdir='$(TEST_DIR_1)' workspace new $(WORKSPACE)
	terraform -chdir='$(TEST_DIR_1)' workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_1)' apply -auto-approve
	NUM_DOWNLOADS=$(NUM_DOWNLOADS) TEST_NAME=1 DOWNLOAD_HOSTNAMES=`terraform -chdir=$(TEST_DIR_1) output -json nginx | jq .dns -r` npm --prefix client start
	
.PHONY: 2
2: $(TEST_DIR_2)/.terraform.lock.hcl
	-terraform -chdir='$(TEST_DIR_2)' workspace new $(WORKSPACE)
	terraform -chdir='$(TEST_DIR_2)' workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_2)' apply -auto-approve
	NUM_DOWNLOADS=$(NUM_DOWNLOADS) TEST_NAME=2 DOWNLOAD_HOSTNAMES=`terraform -chdir=$(TEST_DIR_2) output -json nginx | jq .dns -r` npm --prefix client start

.PHONY: 3
3: $(TEST_DIR_3)/.terraform.lock.hcl
	-terraform -chdir='$(TEST_DIR_3)' workspace new $(WORKSPACE)
	terraform -chdir='$(TEST_DIR_3)' workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_3)' apply -auto-approve
	NUM_DOWNLOADS=$(NUM_DOWNLOADS) TEST_NAME=3 DOWNLOAD_HOSTNAMES=`terraform -chdir=$(TEST_DIR_3) output -json nginx | jq .dns -r` npm --prefix client start

.PHONY: 4
4: $(TEST_DIR_4)/.terraform.lock.hcl
	-terraform -chdir='$(TEST_DIR_4)' workspace new $(WORKSPACE)
	terraform -chdir='$(TEST_DIR_4)' workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_4)' apply -auto-approve
	NUM_DOWNLOADS=$(NUM_DOWNLOADS) TEST_NAME=4 DOWNLOAD_HOSTNAMES=`terraform -chdir=$(TEST_DIR_4) output -json nginx | jq .dns -r` npm --prefix client start

.PHONY: 5
5: $(TEST_DIR_5)/.terraform.lock.hcl
	-terraform -chdir='$(TEST_DIR_5)' workspace new $(WORKSPACE)
	terraform -chdir='$(TEST_DIR_5)' workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_5)' apply -auto-approve
#	NUM_DOWNLOADS=$(NUM_DOWNLOADS) TEST_NAME=5 DOWNLOAD_HOSTNAMES=`terraform -chdir=$(TEST_DIR_5) output -json nginx | jq .dns -r` npm --prefix client start

# An attempt to generalise the 5 rules above follows. 
# The generalisation was ultimately unsuccessful as I was unable to find a method of interpolating the '%' wildcard into a TEST_DIR_X variable name in the pre-requisites.
# The commmands operate appropriately as can be seen in the generalisation of the clean_x commands
# .PHONY: run_%
# run_%: $(TEST_DIR_$*)/.terraform.lock.hcl
# 	export AWS_PROFILE=${AWS_PROFILE}
# 	terraform -chdir='$(TEST_DIR_$*)' apply -auto-approve
# 	NUM_DOWNLOADS=$(NUM_DOWNLOADS) TEST_NAME=$* DOWNLOAD_HOSTNAMES=`terraform -chdir=$(TEST_DIR_$*) output -json nginx | jq .dns -r` npm --prefix client start


.PHONY: clean_%
clean_%:
	echo $(TEST_DIR_$*)
	-terraform workspace new $(WORKSPACE)
	terraform workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_$*)' destroy -auto-approve

.PHONY: clean
clean:
	$(MAKE) clean_1
	$(MAKE) clean_2
	$(MAKE) clean_3
	$(MAKE) clean_4
	$(MAKE) clean_5