

# VPC ID used for builds
BUILD_VPC_ID ?=

# VPC subnet used for builds
BUILD_SUBNET_ID ?=

# Default build region
AWS_REGION ?= us-west-2

# Teleport version
TELEPORT_VERSION ?= 2.6.0-alpha.5

# Teleport UID is a UID of a non-privileged user ID of a teleport
TELEPORT_UID ?= 1007

# Instance type is a single value, sorry
INSTANCE_TYPE ?= t2.micro

# Use comma-separated values without spaces for multiple regions
DESTINATION_REGIONS ?= us-west-2,us-east-1

# Cloudformation stack name to create, e.g. test1
STACK ?=

# Stack parameters, e.g ParameterKey=KeyName,ParameterValue=KeyName ParameterKey=DomainName,ParameterValue=teleport.example.com ParameterKey=DomainAdminEmail,ParameterValue=admin@example.com ParameterKey=HostedZoneID,ParameterValue=AWSZONEID
STACK_PARAMS ?=
export

.PHONY: oss
oss: TELEPORT_TYPE=oss
oss:
	@echo "Building image $(TELEPORT_VERSION) $(TELEPORT_TYPE)"
	packer build -force template.json

.PHONY: validate-template
validate-template:
	aws cloudformation validate-template --template-body file://./oss.yaml

.PHONY: create-stack
create-stack:
	$(MAKE) validate-template
	aws --region=$(AWS_REGION) cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name $(STACK) --template-body file://./oss.yaml --parameters $(STACK_PARAMS) 

.PHONY: update-stack
update-stack:
	$(MAKE) validate-template
	aws --region=$(AWS_REGION) cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $(STACK) --template-body file://./oss.yaml --parameters $(STACK_PARAMS)

.PHONY: describe-stack
describe-stack:
	aws --region=$(AWS_REGION) cloudformation describe-stacks --stack-name $(STACK)

.PHONY: delete-stack
delete-stack:
	aws --region=$(AWS_REGION) cloudformation delete-stack --stack-name $(STACK)
