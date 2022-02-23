SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c  
.DELETE_ON_ERROR:

# Taken from environment variable
WORKSPACE = ${CURRENT_WORKSPACE}
NUM_DOWNLOADS = 10
TEST_DIR = tests

TEST_DIR_1 = $(TEST_DIR)/1-within-az-private-ip
TEST_DIR_2 = $(TEST_DIR)/2-between-az-private-ip
TEST_DIR_3 = $(TEST_DIR)/3-within-az-public-ip
TEST_DIR_4 = $(TEST_DIR)/4-between-az-public-ip
TEST_DIR_5 = $(TEST_DIR)/5-between-region-public-ip

# Run tests 1 through 5
.PHONY: test_%
test_%:
	-terraform -chdir='$(TEST_DIR_$*)' workspace new $(WORKSPACE)
	terraform workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_$*)' init
	terraform -chdir='$(TEST_DIR_$*)' workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_$*)' apply -auto-approve
	NUM_DOWNLOADS=$(NUM_DOWNLOADS) TEST_NAME=$* DOWNLOAD_HOSTNAMES=`terraform -chdir=$(TEST_DIR_$*) output -json nginx | jq .dns -r` npm --prefix client start

.PHONY: clean_%
clean_%:
	echo $(TEST_DIR_$*)
	-terraform workspace new $(WORKSPACE)
	terraform workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_$*)' init
	terraform workspace select $(WORKSPACE);\
	terraform -chdir='$(TEST_DIR_$*)' destroy -auto-approve

.PHONY: clean
clean:
	$(MAKE) clean_1
	$(MAKE) clean_2
	$(MAKE) clean_3
	$(MAKE) clean_4
	$(MAKE) clean_5