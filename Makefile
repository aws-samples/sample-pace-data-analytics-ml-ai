SHELL := /usr/bin/env bash -euo pipefail -c

APP_NAME = nexus
ENV_NAME = mt
AWS_ACCOUNT_ID = 034149990135
AWS_DEFAULT_REGION = us-east-1
AWS_PRIMARY_REGION = us-east-1
AWS_SECONDARY_REGION = us-west-2
TF_S3_BACKEND_NAME = nexus-mt-tf-back-end

#################### Global Constants ####################

ADMIN_ROLE = Admin

#################### Init Wizard ####################

init:
	./init.sh

#################### Terraform Backend ####################

deploy-tf-backend-cf-stack:
	aws cloudformation deploy \
	--template-file ./iac/bootstrap/tf-backend-cf-stack.yml \
	--stack-name $(TF_S3_BACKEND_NAME) \
	--tags App=$(APP_NAME) Env=$(ENV_NAME) \
	--region $(AWS_PRIMARY_REGION) \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides file://iac/bootstrap/parameters.json
	aws cloudformation deploy \
	--template-file ./iac/bootstrap/tf-backend-cf-stack.yml \
	--stack-name $(TF_S3_BACKEND_NAME) \
	--tags App=$(APP_NAME) Env=$(ENV_NAME) \
	--region $(AWS_SECONDARY_REGION) \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides file://iac/bootstrap/parameters-secondary.json
	aws cloudformation deploy \
	--template-file ./iac/bootstrap/tf-backend-cf-stack.yml \
	--stack-name $(TF_S3_BACKEND_NAME) \
	--tags App=$(APP_NAME) Env=$(ENV_NAME) \
	--region $(AWS_PRIMARY_REGION) \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides file://iac/bootstrap/parameters-crr.json

destroy-tf-backend-cf-stack:
	@./build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-tf-back-end-$(AWS_ACCOUNT_ID)-$(AWS_PRIMARY_REGION)"
	aws cloudformation delete-stack \
	--stack-name $(TF_S3_BACKEND_NAME)
	aws cloudformation wait stack-delete-complete \
	--stack-name $(TF_S3_BACKEND_NAME) \
	--region $(AWS_PRIMARY_REGION)
	@./build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-tf-back-end-$(AWS_ACCOUNT_ID)-$(AWS_SECONDARY_REGION)"
	aws cloudformation delete-stack \
	--stack-name $(TF_S3_BACKEND_NAME)
	aws cloudformation wait stack-delete-complete \
	--stack-name $(TF_S3_BACKEND_NAME) \
	--region $(AWS_SECONDARY_REGION)

#################### KMS Keys ####################

deploy-kms-keys:
	@echo "Deploying KMS Keys"
	(cd iac/roots/foundation/kms-keys; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying KMS Keys"

destroy-kms-keys:
	@echo "Destroying KMS Keys"
	(cd iac/roots/foundation/kms-keys; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying KMS Keys"

#################### IAM Roles ####################

deploy-iam-roles:
	@echo "Deploying IAM Roles"
	(cd iac/roots/foundation/iam-roles; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying IAM Roles"

destroy-iam-roles:
	@echo "Destroying IAM Roles"
	(cd iac/roots/foundation/iam-roles; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying IAM Roles"

#################### Buckets ####################

deploy-buckets:
	@echo "Deploying Buckets"
	(cd iac/roots/foundation/buckets; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying Buckets"

destroy-buckets:
	@echo "Destroying Buckets"
	(cd iac/roots/foundation/buckets; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying Data Bucket"

#################### Identity Center ####################

deploy-idc-org:
	@echo "Deploying Organization-Level Identity Center"
	(cd iac/roots/idc/idc-org; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying Organization-Level Identity Center"

destroy-idc-org:
	@echo "Destroying Organization-Level Identity Center"
	(cd iac/roots/idc/idc-org; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying Organization-Level Identity Center"

deploy-idc-acc:
	@echo "Deploying Account-Level Identity Center"
	(cd iac/roots/idc/idc-acc; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying Account-Level Identity Center"

destroy-idc-acc:
	@echo "Destroying Account-Level Identity Center"
	(cd iac/roots/idc/idc-acc; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying Account-Level Identity Center"

#################### Sagemaker Domain ####################

deploy-domain-prereq:
	@echo "Deploying Pre-requisites for SageMaker Studio Domain"
	(cd iac/roots/sagemaker/domain-prereq; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying Pre-requisites for SageMaker Studio Domain"

destroy-domain-prereq:
	@echo "Destroying Pre-requisites for SageMaker Studio Domain"
	(cd iac/roots/sagemaker/domain-prereq; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying Pre-requisites for SageMaker Studio Domain"

deploy-domain:
	@echo "Deploying Sagemaker Studio Domain"
	(cd iac/roots/sagemaker/domain; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying Sagemaker Studio Domain"

destroy-domain:
	@echo "Destroying Sagemaker Studio Domain"
	(cd iac/roots/sagemaker/domain; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying Sagemaker Studio Domain"

#################### Sagemaker Project ####################

deploy-project-prereq:
	@echo "Deploying Sagemaker Studio Domain Project Prereqs"
	(cd iac/roots/sagemaker/project-prereq; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying Sagemaker Studio Domain Project Prereqs"

destroy-project-prereq:
	@echo "Destroying Sagemaker Studio Domain Project Prereqs"
	(cd iac/roots/sagemaker/project-prereq; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying Sagemaker Studio Domain Project Prereqs"

deploy-projects:
	@echo "Deploying Sagemaker Studio Domain Projects"
	(cd iac/roots/sagemaker/projects; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying Sagemaker Studio Domain Projects"

destroy-projects:
	@echo "Destroying Sagemaker Studio Domain Projects"
	(cd iac/roots/sagemaker/projects; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying Sagemaker Studio Domain Projects"

extract-producer-info:
	($(eval domain_id:=${shell aws datazone list-domains --query "items[?name=='Corporate'].id" --output text}) \
	 $(eval producer_project_id:=${shell aws datazone list-projects --domain-identifier ${domain_id} --query "items[?name=='Producer'].id" --output text}) \
	 aws ssm --region $(AWS_PRIMARY_REGION) put-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/producer/id --value ${shell aws datazone list-projects --domain-identifier ${domain_id} --query "items[?name=='Producer'].id" --output text} --type "String" --overwrite;\
	 $(eval stack_names:=${shell aws cloudformation list-stacks --no-paginate --stack-status-filter CREATE_COMPLETE --query 'StackSummaries[*].StackName' --output text}) \
	 $(eval tooling:=Tooling) \
	 $(foreach stack_name,$(stack_names), \
			$(if $(filter $(domain_id), $(shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Tags[?Key=='AmazonDataZoneDomain'].Value" --output text)),\
				$(if $(filter $(producer_project_id),$(shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Tags[?Key=='AmazonDataZoneProject'].Value" --output text)),\
					$(if $(filter $(tooling),$(shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Tags[?Key=='AmazonDataZoneBlueprint'].Value" --output text)),\
						aws ssm --region $(AWS_PRIMARY_REGION) put-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/producer/role --value ${shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Outputs[?OutputKey=='UserRole'].OutputValue" --output text} --type "String" --overwrite;\
						aws ssm --region $(AWS_PRIMARY_REGION) put-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/producer/role-name --value ${shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Outputs[?OutputKey=='UserRoleName'].OutputValue" --output text} --type "String" --overwrite;\
						exit 0; \
					)\
				)\
			)\
	 ) \
	 )

extract-consumer-info:
	($(eval domain_id:=${shell aws datazone list-domains --query "items[?name=='Corporate'].id" --output text}) \
	 $(eval consumer_project_id:=${shell aws datazone list-projects --domain-identifier ${domain_id} --query "items[?name=='Consumer'].id" --output text}) \
	 aws ssm --region $(AWS_PRIMARY_REGION) put-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/consumer/id --value ${shell aws datazone list-projects --domain-identifier ${domain_id} --query "items[?name=='Consumer'].id" --output text} --type "String" --overwrite;\
	 $(eval stack_names:=${shell  aws cloudformation list-stacks --query 'StackSummaries[*].StackName' --output text}) \
	 $(eval tooling:=Tooling) \
	 $(foreach stack_name,$(stack_names), \
			$(if $(filter $(domain_id),$(shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Tags[?Key=='AmazonDataZoneDomain'].Value" --output text)),\
				$(if $(filter $(consumer_project_id),$(shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Tags[?Key=='AmazonDataZoneProject'].Value" --output text)),\
					$(if $(filter $(tooling),$(shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Tags[?Key=='AmazonDataZoneBlueprint'].Value" --output text)),\
						aws ssm --region $(AWS_PRIMARY_REGION) put-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/consumer/role --value ${shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Outputs[?OutputKey=='UserRole'].OutputValue" --output text} --type "String" --overwrite;\
						aws ssm --region $(AWS_PRIMARY_REGION) put-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/consumer/role-name --value ${shell aws cloudformation describe-stacks --stack-name $(stack_name) --query "Stacks[0].Outputs[?OutputKey=='UserRoleName'].OutputValue" --output text} --type "String" --overwrite;\
						exit 0; \
					)\
				)\
			)\
	 ) \
	 )

#################### Glue ####################

deploy-glue-jars:
	@echo "Downloading and Deploying Required JAR File"
	mkdir -p jars
	export DYNAMIC_RESOLUTION=y; \

	curl -o jars/s3-tables-catalog-for-iceberg-runtime-0.1.5.jar \
		"https://repo1.maven.org/maven2/software/amazon/s3tables/s3-tables-catalog-for-iceberg-runtime/0.1.5/s3-tables-catalog-for-iceberg-runtime-0.1.5.jar"
	
	aws s3 cp "jars/s3-tables-catalog-for-iceberg-runtime-0.1.5.jar" \
		"s3://$(APP_NAME)-$(ENV_NAME)-glue-jars-primary/" \
		--region "$(AWS_PRIMARY_REGION)"
	
	rm -rf jars/
	@echo "Finished Downloading and Deploying Required JAR File"

#################### Lake Formation ####################

create-glue-s3tables-catalog:
	aws glue create-catalog \
        --cli-input-json '{"Name": "s3tablescatalog", "CatalogInput": { "FederatedCatalog": { "Identifier": "arn:aws:s3tables:${AWS_PRIMARY_REGION}:${AWS_ACCOUNT_ID}:bucket/*", "ConnectionName": "aws:s3tables" }, "CreateDatabaseDefaultPermissions": [], "CreateTableDefaultPermissions": [] } }' \
        --region "${AWS_PRIMARY_REGION}"

register-s3table-catalog-with-lake-formation:
	aws lakeformation register-resource \
        --resource-arn "arn:aws:s3tables:${AWS_PRIMARY_REGION}:${AWS_ACCOUNT_ID}:bucket/*" \
        --role-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${APP_NAME}-${ENV_NAME}-lakeformation-service-role" \
        --with-federation \
        --region "${AWS_PRIMARY_REGION}"

#################### Athena ####################

deploy-athena:
	@echo "Deploying Athena"
	(cd iac/roots/athena; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Athena"

destroy-athena:
	@echo "Destroying Athena"
	(cd iac/roots/athena; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Athena"

#################### Billing ####################

deploy-billing:
	@echo "Deploying Billing Infrastructure"
	(cd iac/roots/datalakes/billing; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Billing Infrastructure"

destroy-billing:

	@echo "Emptying and deleting S3 Table"
	aws s3tables delete-table \
    	--table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-billing \
    	--namespace $(APP_NAME) --name billing || true

	aws s3tables delete-namespace \
    	--table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-billing \
        --namespace $(APP_NAME) || true

	aws s3tables delete-table-bucket \
        --table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-billing || true

	@echo "Emptying S3 buckets"
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-data-primary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-data-secondary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-data-primary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-data-secondary-log" || true	
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-hive-primary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-hive-secondary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-hive-primary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-hive-secondary-log" || true	
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-iceberg-primary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-iceberg-secondary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-iceberg-primary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-billing-iceberg-secondary-log" || true

	@echo "Destroying Billing Infrastructure"
	(cd iac/roots/datalakes/billing; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Billing Infrastructure"

start-billing-hive-job:
	@echo "Starting Billing Hive Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-billing-hive)
	@echo "Started Billing Hive Job"

start-billing-iceberg-static-job:
	@echo "Starting Billing Iceberg Static Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-billing-iceberg-static)
	@echo "Started Billing Iceberg Static Job"

start-billing-s3table-create-job:
	@echo "Starting Billing S3 Table Create Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-billing-s3table-create)
	@echo "Started Billing S3 Create Job"

start-billing-s3table-delete-job:
	@echo "Starting Billing S3 Table Delete Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-billing-s3table-delete)
	@echo "Started Billing S3 Table Delete Job"	

start-billing-s3table-job:
	@echo "Starting Billing S3 Table Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-billing-s3table;)
	@echo "Started Billing S3 Table Job"

grant-lake-formation-billing-s3-table-catalog:
	aws lakeformation grant-permissions \
		--principal DataLakePrincipalIdentifier="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ADMIN_ROLE}" \
		--resource "{\"Table\": {\"CatalogId\": \"${AWS_ACCOUNT_ID}:s3tablescatalog/${APP_NAME}-${ENV_NAME}-billing\", \"DatabaseName\": \"${APP_NAME}\", \"Name\": \"billing\"}}" \
		--permissions ALL \
		--permissions-with-grant-option ALL \
		--region "$(AWS_PRIMARY_REGION)"

start-billing-hive-data-quality-ruleset:
	@echo "Starting Billing Hive Data Quality Ruleset"
	aws glue start-data-quality-ruleset-evaluation-run \
		--region $(AWS_PRIMARY_REGION) \
		--role "$(APP_NAME)-$(ENV_NAME)-glue-role"  \
		--ruleset-names "billing_hive_ruleset" \
		--data-source '{"GlueTable":{"DatabaseName":"$(APP_NAME)_$(ENV_NAME)_billing","TableName":"$(APP_NAME)_$(ENV_NAME)_billing_iceberg_static"}}'

	@echo "Started Billing Hive Data Quality Ruleset"

start-billing-iceberg-data-quality-ruleset:
	@echo "Starting Billing Iceberg Data Quality Ruleset"
	aws glue start-data-quality-ruleset-evaluation-run \
		--region $(AWS_PRIMARY_REGION) \
		--role "$(APP_NAME)-$(ENV_NAME)-glue-role"  \
		--ruleset-names "billing_iceberg_ruleset" \
		--data-source '{"GlueTable":{"DatabaseName":"$(APP_NAME)_$(ENV_NAME)_billing","TableName":"$(APP_NAME)_$(ENV_NAME)_billing_iceberg_static"}}'
	@echo "Started Billing Iceberg Data Quality Ruleset"

upload-billing-dynamic-report-1:
	@echo "Starting Upload of Billing Report 1 to trigger dynamic Glue Workflow"
	aws s3 cp \
		data/billing/dynamic/cost-and-usage-report-00002.csv.gz \
		s3://$(APP_NAME)-$(ENV_NAME)-billing-data-primary/billing/$(APP_NAME)-$(ENV_NAME)-cost-and-usage-report/manual/
	@echo "Finished Upload of Billing Report 1"

upload-billing-dynamic-report-2:
	@echo "Starting Upload of Billing Report 2 to trigger dynamic Glue Workflow"
	aws s3 cp \
		data/billing/dynamic/cost-and-usage-report-00003.csv.gz \
		s3://$(APP_NAME)-$(ENV_NAME)-billing-data-primary/billing/$(APP_NAME)-$(ENV_NAME)-cost-and-usage-report/manual/
	@echo "Finished Upload of Billing Report 2"

grant-lake-formation-billing-iceberg-dynamic:
	aws lakeformation grant-permissions \
    	--principal DataLakePrincipalIdentifier="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ADMIN_ROLE}" \
        --resource "{\"Table\": {\"DatabaseName\": \"${APP_NAME}_${ENV_NAME}_billing\", \"Name\": \"${APP_NAME}_${ENV_NAME}_billing_iceberg_dynamic\"}}" \
        --permissions ALL \
        --permissions-with-grant-option ALL \
        --region "$(AWS_PRIMARY_REGION)"

activate-cost-allocation-tags:
	@echo "Activating Cost Allocation Tags"
	aws ce update-cost-allocation-tags-status \
        --region us-east-1 \
        --cost-allocation-tags-status '[{"TagKey":"Application","Status":"Active"},{"TagKey":"Environment","Status":"Active"},{"TagKey":"Usage","Status":"Active"}]'
	@echo "Finished Activating Cost Allocation Tags"

deploy-billing-cur:
	@echo "Deploying Billing CUR Report"
	(cd iac/roots/datalakes/billing-cur; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Billing CUR Report"

destroy-billing-cur:
	@echo "Destroying Billing CUR Report"
	(cd iac/roots/datalakes/billing-cur; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished DDestroying Billing CUR Report"

#################### Inventory ####################

download-sec-reports:
	@echo "Downloading Costco SEC Reports"
	@mkdir -p /tmp/costco-sec
	
	# Format Costco's CIK with leading zeros
	$(eval COSTCO_CIK := $(shell printf "%010d" 909832))
	
	# Download Costco's submissions data
	@curl -H "User-Agent: $(APP_NAME)-$(ENV_NAME)-inventory-downloader" \
		-o /tmp/costco-sec/submissions.json \
		"https://data.sec.gov/submissions/CIK$(COSTCO_CIK).json"
	
	# Upload to S3
	@aws s3 cp "/tmp/costco-sec/submissions.json" \
		"s3://$(APP_NAME)-$(ENV_NAME)-inventory-data-source-primary/" \
		--region "$(AWS_PRIMARY_REGION)"
	
	# Download company facts
	@curl -H "User-Agent: $(APP_NAME)-$(ENV_NAME)-inventory-downloader" \
		-o /tmp/costco-sec/company_facts.json \
		"https://data.sec.gov/api/xbrl/companyfacts/CIK$(COSTCO_CIK).json"
	
	# Upload company facts to S3
	@aws s3 cp "/tmp/costco-sec/company_facts.json" \
		"s3://$(APP_NAME)-$(ENV_NAME)-inventory-data-source-primary/" \
		--region "$(AWS_PRIMARY_REGION)"

	# Download last 5 years of 10-K and 10-Q reports
	@for year in {2019..2023}; do \
		echo "Downloading reports for $$year"; \
		for form in "10-K" "10-Q"; do \
			curl -H "User-Agent: $(APP_NAME)-$(ENV_NAME)-inventory-downloader" \
				-o "/tmp/costco-sec/$$form-$$year.htm" \
				"https://www.sec.gov/Archives/edgar/data/909832/$$year/*.$$form"; \
			aws s3 cp "/tmp/costco-sec/$$form-$$year.htm" \
				"s3://$(APP_NAME)-$(ENV_NAME)-inventory-data-source-primary/" \
				--region "$(AWS_PRIMARY_REGION)"; \
			sleep 0.1; \
		done; \
	done
	
	@rm -rf /tmp/costco-sec
	@echo "Finished downloading Costco SEC Reports"

deploy-inventory:
	@echo "Deploying Inventory Infrastructure"
	(cd iac/roots/datalakes/inventory; \
		terraform init; \
		terraform apply -auto-approve;)
		@echo "Finished Deploying Inventory Infrastructure"

destroy-inventory:
	@echo "Emptying and deleting S3 Table"
	aws s3tables delete-table \
    	--table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-inventory \
    	--namespace $(APP_NAME) --name inventory || true

	aws s3tables delete-namespace \
    	--table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-inventory \
        --namespace $(APP_NAME) || true

	aws s3tables delete-table-bucket \
        --table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-inventory || true

	@echo "Emptying S3 buckets"
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-data-source-primary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-data-source-secondary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-data-destination-primary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-data-destination-secondary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-iceberg-primary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-iceberg-secondary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-iceberg-primary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-iceberg-secondary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-data-destination-primary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-data-destination-secondary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-data-source-primary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-inventory-data-source-secondary-log" || true

	@echo "Destroying Inventory Infrastructure and Job"
	(cd iac/roots/datalakes/inventory; \
		terraform init; \
		terraform destroy -auto-approve;)
		@echo "Finished Destroying Inventory Infrastructure and Job"

start-inventory-hive-job:
	@echo "Starting Inventory Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-inventory-hive)
	@echo "Started Inventory Job"

start-inventory-iceberg-static-job:
	@echo "Starting Inventory Iceberg Static Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-inventory-iceberg-static)
	@echo "Started Inventory Iceberg Static Job"

start-inventory-s3table-create-job:
	@echo "Starting Inventory S3 Table Create Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-inventory-s3table-create)
	@echo "Started Inventory S3 Table Create Job"

start-inventory-s3table-delete-job:
	@echo "Starting Inventory S3 Table Delete Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-inventory-s3table-delete)
	@echo "Started Inventory S3 Table Delete Job"

start-inventory-s3table-job:
	@echo "Starting Inventory S3 Job"
	(aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-inventory-s3table)
	@echo "Started Inventory S3 Table Job"

grant-lake-formation-inventory-s3-table-catalog:
	aws lakeformation grant-permissions \
		--principal DataLakePrincipalIdentifier="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ADMIN_ROLE}" \
		--resource "{\"Table\": {\"CatalogId\": \"${AWS_ACCOUNT_ID}:s3tablescatalog/${APP_NAME}-${ENV_NAME}-inventory\", \"DatabaseName\": \"${APP_NAME}\", \"Name\": \"inventory\"}}" \
		--permissions ALL \
		--permissions-with-grant-option ALL \
		--region "$(AWS_PRIMARY_REGION)"

start-inventory-hive-data-quality-ruleset:
	@echo "Starting Inventory Hive Data Quality Ruleset"
	aws glue start-data-quality-ruleset-evaluation-run \
		--region $(AWS_PRIMARY_REGION) \
		--role "$(APP_NAME)-$(ENV_NAME)-glue-role"  \
		--ruleset-names "inventory-hive-ruleset" \
        --data-source '{"GlueTable":{"DatabaseName":"$(APP_NAME)_$(ENV_NAME)_inventory","TableName":"$(APP_NAME)_$(ENV_NAME)_inventory_hive"}}'
	@echo "Started Inventory Hive Data Quality Ruleset"

start-inventory-iceberg-data-quality-ruleset:
	@echo "Starting Inventory Iceberg Data Quality Ruleset"
	aws glue start-data-quality-ruleset-evaluation-run \
		--region $(AWS_PRIMARY_REGION) \
		--role "$(APP_NAME)-$(ENV_NAME)-glue-role"  \
		--ruleset-names "inventory-iceberg-ruleset" \
		--data-source '{"GlueTable":{"DatabaseName":"$(APP_NAME)_$(ENV_NAME)_inventory","TableName":"$(APP_NAME)_$(ENV_NAME)_inventory_iceberg_static"}}'
	@echo "Started Inventory Iceberg Data Quality Ruleset"

upload-inventory-dynamic-report-1:
	@echo "Starting Upload of Inventory Report 1 to trigger dynamic Glue Workflow"
	aws s3 cp \
		data/inventory/dynamic/bc8bbf78-546e-4a5b-ac3d-d5dae9ffadab.csv.gz \
		s3://$(APP_NAME)-$(ENV_NAME)-inventory-data-destination-primary/$(APP_NAME)-$(ENV_NAME)-inventory-data-source-primary/InventoryConfig/data/
	@echo "Finished Upload of Billing Report 1"

upload-inventory-dynamic-report-2:
	@echo "Starting Upload of Inventory Report 2 to trigger dynamic Glue Workflow"
	aws s3 cp \
		data/inventory/dynamic/b359c3d9-b58e-4f23-aee4-4b75ab78b3bb.csv.gz \
		s3://$(APP_NAME)-$(ENV_NAME)-inventory-data-destination-primary/$(APP_NAME)-$(ENV_NAME)-inventory-data-source-primary/InventoryConfig/data/
	@echo "Finished Upload of Billing Report 2"

grant-lake-formation-inventory-iceberg-dynamic:
	aws lakeformation grant-permissions \
    	--principal DataLakePrincipalIdentifier="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ADMIN_ROLE}" \
        --resource "{\"Table\": {\"DatabaseName\": \"${APP_NAME}_${ENV_NAME}_inventory\", \"Name\": \"${APP_NAME}_${ENV_NAME}_inventory_iceberg_dynamic\"}}" \
        --permissions ALL \
        --permissions-with-grant-option ALL \
        --region "$(AWS_PRIMARY_REGION)"

#################### Network ####################

deploy-network:
	@echo "Deploying Network"
	(cd iac/roots/network; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Network"

destroy-network:
	@echo "Destroying Network"
	(cd iac/roots/network; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Network"

#################### Splunk ####################

deploy-splunk:
	@echo "Deploying Splunk"
	(cd iac/roots/datalakes/splunk; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Splunk"

destroy-splunk:
	@echo "Emptying and deleting S3 Table"
	aws s3tables delete-table \
        --table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-splunk \
        --namespace $(APP_NAME) --name inventory || true

	aws s3tables delete-namespace \
        --table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-splunk \
        --namespace $(APP_NAME) || true

	aws s3tables delete-table-bucket \
        --table-bucket-arn arn:aws:s3tables:$(AWS_PRIMARY_REGION):$(AWS_ACCOUNT_ID):bucket/$(APP_NAME)-$(ENV_NAME)-splunk || true

	@echo "Emptying S3 buckets"
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-iceberg-splunk-primary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-iceberg-splunk-secondary" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-iceberg-splunk-primary-log" || true
	$(ENV_PATH)../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-iceberg-splunk-secondary-log" || true

	@echo "Destroying Splunk"
	(cd iac/roots/datalakes/splunk; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Splunk"

start-splunk-iceberg-static-job:
	@echo "Starting Splunk ETL Job"
	aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-splunk-iceberg-static
	@echo "Started Splunk Iceberg Static Job"

start-splunk-s3table-create-job:
	@echo "Starting Splunk S3 Iceberg Create Job"
	aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-splunk-s3table-create
	@echo "Started Splunk S3 Table Create Job"	
	
start-splunk-s3table-delete-job:
	@echo "Starting Splunk S3 Table Delete Job"
	aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-splunk-s3table-delete
	@echo "Started Splunk S3 Table Delete Job"

start-splunk-s3table-job:
	@echo "Starting Splunk S3 Table Job"
	aws glue start-job-run --region $(AWS_PRIMARY_REGION) --job-name $(APP_NAME)-$(ENV_NAME)-splunk-s3table
	@echo "Started Splunk S3 Table Job"

grant-lake-formation-splunk-s3-table-catalog:
	aws lakeformation grant-permissions \
		--principal DataLakePrincipalIdentifier="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ADMIN_ROLE}" \
		--resource "{\"Table\": {\"CatalogId\": \"${AWS_ACCOUNT_ID}:s3tablescatalog/${APP_NAME}-${ENV_NAME}-splunk\", \"DatabaseName\": \"${APP_NAME}\", \"Name\": \"splunk\"}}" \
		--permissions ALL \
		--permissions-with-grant-option ALL \
		--region "$(AWS_PRIMARY_REGION)"

#################### Project Configuration ####################

deploy-project-config:
	@echo "Deploying Project Configuration"
	(cd iac/roots/sagemaker/project-config; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Project Configuration"

destroy-project-config:
	@echo "Destroying Project Configuration"
	(cd iac/roots/sagemaker/project-config; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Project Configuration"

deploy-project-user:
	@echo "Deploying Project User"
	(cd iac/roots/sagemaker/project-user; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Project User"

billing-grant-producer-s3tables-catalog-permissions:
	@echo "Grant Producer S3Tables Catalog Permissions"
	( \
		$(eval producer_role_arn:=${shell aws ssm --region $(AWS_PRIMARY_REGION) get-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/producer/role --query Parameter.Value --output text}) \
	  aws lakeformation grant-permissions \
		--cli-input-json '{ \
				"Principal": { \
						"DataLakePrincipalIdentifier": "${producer_role_arn}" \
				}, \
				"Resource": { \
						"Table": { \
								"CatalogId": "$(AWS_ACCOUNT_ID):s3tablescatalog/$(APP_NAME)-$(ENV_NAME)-billing", \
								"DatabaseName": "$(APP_NAME)", \
								"Name": "billing" \
						} \
				}, \
				"Permissions": [ \
						"ALL" \
				] \
		}')
	@echo "Finished deploying Project Configuration"

billing-grant-consumer-s3tables-catalog-permissions:
	@echo "Grant Consumer S3Tables Catalog Permissions"
	( \
		$(eval consumer_role_arn:=${shell aws ssm --region $(AWS_PRIMARY_REGION) get-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/consumer/role --query Parameter.Value --output text}) \
		aws lakeformation grant-permissions \
		--cli-input-json '{ \
				"Principal": { \
						"DataLakePrincipalIdentifier": "${consumer_role_arn}" \
				}, \
				"Resource": { \
						"Table": { \
								"CatalogId": "$(AWS_ACCOUNT_ID):s3tablescatalog/$(APP_NAME)-$(ENV_NAME)-billing", \
								"DatabaseName": "$(APP_NAME)", \
								"Name": "billing" \
						} \
				}, \
				"Permissions": [ \
						"ALL" \
				] \
		}')
	@echo "Finished Consumer Project Configuration"	

inventory-grant-producer-s3tables-catalog-permissions:
	@echo "Grant Producer S3Tables Catalog Permissions"
	( \
		$(eval producer_role_arn:=${shell aws ssm --region $(AWS_PRIMARY_REGION) get-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/producer/role --query Parameter.Value --output text}) \
		aws lakeformation grant-permissions \
		--cli-input-json '{ \
				"Principal": { \
						"DataLakePrincipalIdentifier": "${producer_role_arn}" \
				}, \
				"Resource": { \
						"Table": { \
								"CatalogId": "$(AWS_ACCOUNT_ID):s3tablescatalog/$(APP_NAME)-$(ENV_NAME)-inventory", \
								"DatabaseName": "$(APP_NAME)", \
								"Name": "inventory" \
						} \
				}, \
				"Permissions": [ \
						"ALL" \
				] \
		}')
	@echo "Finished deploying Project Configuration"

inventory-grant-consumer-s3tables-catalog-permissions:
	@echo "Grant Consumer S3Tables Catalog Permissions"
	( \
		$(eval consumer_role_arn:=${shell aws ssm --region $(AWS_PRIMARY_REGION) get-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/consumer/role --query Parameter.Value --output text}) \
		aws lakeformation grant-permissions \
		--cli-input-json '{ \
				"Principal": { \
						"DataLakePrincipalIdentifier": "${consumer_role_arn}" \
				}, \
				"Resource": { \
						"Table": { \
								"CatalogId": "$(AWS_ACCOUNT_ID):s3tablescatalog/$(APP_NAME)-$(ENV_NAME)-inventory", \
								"DatabaseName": "$(APP_NAME)", \
								"Name": "inventory" \
						} \
				}, \
				"Permissions": [ \
						"ALL" \
				] \
		}')
	@echo "Finished Consumer Project Configuration"

splunk-grant-producer-s3tables-catalog-permissions:
	@echo "Grant Producer S3Tables Catalog Permissions"
	( \
		$(eval producer_role_arn:=${shell aws ssm --region $(AWS_PRIMARY_REGION) get-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/producer/role --query Parameter.Value --output text}) \
		aws lakeformation grant-permissions \
		--cli-input-json '{ \
				"Principal": { \
						"DataLakePrincipalIdentifier": "${producer_role_arn}" \
				}, \
				"Resource": { \
						"Table": { \
								"CatalogId": "$(AWS_ACCOUNT_ID):s3tablescatalog/$(APP_NAME)-$(ENV_NAME)-splunk", \
								"DatabaseName": "$(APP_NAME)", \
								"Name": "splunk" \
						} \
				}, \
				"Permissions": [ \
						"ALL" \
				] \
		}')
	@echo "Finished deploying Project Configuration"

splunk-grant-consumer-s3tables-catalog-permissions:
	@echo "Granting Consumer S3Tables Catalog Permissions"
	($(eval consumer_role_arn:=${shell aws ssm --region $(AWS_PRIMARY_REGION) get-parameter --name /$(APP_NAME)/$(ENV_NAME)/sagemaker/consumer/role --query Parameter.Value --output text}) \
		aws lakeformation grant-permissions \
		--cli-input-json '{ \
				"Principal": { \
						"DataLakePrincipalIdentifier": "${consumer_role_arn}" \
				}, \
				"Resource": { \
						"Table": { \
								"CatalogId": "$(AWS_ACCOUNT_ID):s3tablescatalog/$(APP_NAME)-$(ENV_NAME)-splunk", \
								"DatabaseName": "$(APP_NAME)", \
								"Name": "splunk" \
						} \
				}, \
				"Permissions": [ \
						"ALL" \
				] \
		}')
	@echo "Finished Granting Consumer S3Tables Catalog Permissions"

#################### Datazone ####################

deploy-datazone-domain:
	@echo "Deploying Datazone Domain"
	(cd iac/roots/datazone/dzdomain; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Datazone Domain"

destroy-datazone-domain:
	@echo "Destroying Datazone Domain"
	(cd iac/roots/datazone/dzdomain; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Datazone Domain"

deploy-datazone-project:
	@echo "Deploying Datazone Project"
	(cd iac/roots/datazone/dzproject; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Datazone Project"

destroy-datazone-project:
	@echo "Destroying Datazone Project"
	(cd iac/roots/datazone/dzproject; \
		terraform init; \
		terraform destroy -auto-approve;)
	@echo "Finished Destroying Datazone Project"

#################### Quicksight ####################

deploy-quicksight-subscription:
	@echo "Deploying Quicksight"
	(cd iac/roots/quicksight/subscription; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Quicksight"

deploy-quicksight-dataset:
	@echo "Deploying Quicksight Dataset"
	(cd iac/roots/quicksight/dataset; \
		terraform init; \
		terraform apply -auto-approve;)
	@echo "Finished Deploying Quicksight Dataset"


#################### Deploy All ####################

# Deploy all targets in the correct order, one make target at a time
deploy-all: deploy-foundation deploy-idc deploy-domain deploy-project deploy-glue-jars deploy-lake-formation deploy-athena deploy-billing-static deploy-billing-dynamic deploy-billing-cur deploy-inventory-static deploy-billing-dynamic deploy-splunk-modules deploy-project-configuration deploy-datazone deploy-quicksight-subscription deploy-quicksight deploy-billing-cur-modules
deploy-foundation: deploy-kms-keys deploy-iam-roles deploy-buckets
deploy-idc: deploy-idc-org
deploy-domain: deploy-domain-prereq deploy-domain
deploy-project: deploy-project-prereq deploy-projects extract-producer-info extract-consumer-info
deploy-glue-jars: deploy-glue-jars
deploy-lake-formation: create-glue-s3tables-catalog register-s3table-catalog-with-lake-formation
deploy-athena: deploy-athena 
deploy-billing-static: deploy-billing start-billing-hive-job start-billing-iceberg-static-job start-billing-s3table-create-job start-billing-s3table-job grant-lake-formation-billing-s3-table-catalog start-billing-hive-data-quality-ruleset start-billing-iceberg-data-quality-ruleset
deploy-billing-dynamic: upload-billing-dynamic-report-1 upload-billing-dynamic-report-2 grant-lake-formation-billing-iceberg-dynamic
deploy-billing-cur: activate-cost-allocation-tags deploy-billing-cur 
deploy-inventory-static: deploy-inventory start-inventory-hive-job start-inventory-iceberg-static-job start-inventory-s3table-create-job start-inventory-s3table-job grant-lake-formation-inventory-s3-table-catalog start-inventory-hive-data-quality-ruleset start-inventory-iceberg-data-quality-ruleset 
deploy-inventory-dynamic: upload-inventory-dynamic-report-1 upload-inventory-dynamic-report-2 grant-lake-formation-inventory-iceberg-dynamic
deploy-splunk-modules: deploy-network deploy-splunk start-splunk-iceberg-static-job start-splunk-s3table-create-job start-splunk-s3table-job grant-lake-formation-splunk-s3-table-catalog
deploy-project-configuration: deploy-project-config billing-grant-producer-s3tables-catalog-permissions billing-grant-consumer-s3tables-catalog-permissions inventory-grant-producer-s3tables-catalog-permissions inventory-grant-consumer-s3tables-catalog-permissions splunk-grant-producer-s3tables-catalog-permissions splunk-grant-consumer-s3tables-catalog-permissions
deploy-datazone: deploy-datazone-domain deploy-datazone-project
deploy-quicksight-subscription: deploy-quicksight-subscription
deploy-quicksight: deploy-quicksight-dataset

#################### Destroy All ####################

# Destroy all targets in the correct order, one make target at a time
destroy-all: destroy-datazone destroy-project-configuration destroy-splunk-modules destroy-inventory-modules destroy-billing-cur-modules destroy-billing-modules destroy-athena destroy-project destroy-domain destroy-idc destroy-foundation
destroy-foundation: destroy-buckets destroy-iam-roles destroy-kms-keys
destroy-idc: destroy-idc-org
destroy-domain: destroy-domain destroy-domain-prereq
destroy-project: destroy-projects destroy-project-prereq
destroy-athena: destroy-athena
destroy-billing-modules: destroy-billing
destroy-billing-cur-modules: destroy-billing-cur
destroy-inventory-modules: destroy-inventory
destroy-splunk-modules: destroy-splunk
destroy-project-configuration: destroy-project-config
destroy-datazone: destroy-datazone-project destroy-datazone-domain
