AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query Account --output text)
GITHUB_REPO ?= devluchops/lambda-github-actions-demo
LAMBDA_FUNCTION_NAME ?= my-lambda-function

.PHONY: help setup create-oidc create-role create-function update-workflow

help: ## Show available commands
	@echo "make setup - Setup everything for GitHub Actions"

setup: create-oidc create-role create-function update-workflow

create-oidc:
	@aws iam create-open-id-connect-provider \
		--url https://token.actions.githubusercontent.com \
		--client-id-list sts.amazonaws.com \
		--thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 2>/dev/null || echo "OIDC provider exists"

create-role:
	@echo '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Federated":"arn:aws:iam::$(AWS_ACCOUNT_ID):oidc-provider/token.actions.githubusercontent.com"},"Action":"sts:AssumeRoleWithWebIdentity","Condition":{"StringEquals":{"token.actions.githubusercontent.com:aud":"sts.amazonaws.com","token.actions.githubusercontent.com:sub":"repo:$(GITHUB_REPO):ref:refs/heads/main"}}}]}' > trust-policy.json
	@aws iam create-role --role-name GitHubActionRole --assume-role-policy-document file://trust-policy.json 2>/dev/null || echo "Role exists"
	@aws iam attach-role-policy --role-name GitHubActionRole --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess 2>/dev/null || echo "Policy already attached"
	@rm -f trust-policy.json
	@echo "Role ARN: arn:aws:iam::$(AWS_ACCOUNT_ID):role/GitHubActionRole"

create-function:
	@python build.py
	@aws lambda create-function \
		--function-name $(LAMBDA_FUNCTION_NAME) \
		--runtime python3.11 \
		--role arn:aws:iam::$(AWS_ACCOUNT_ID):role/GitHubActionRole \
		--handler lambda_function.lambda_handler \
		--zip-file fileb://lambda-function.zip 2>/dev/null || echo "Function exists"
	@rm -f lambda-function.zip

update-workflow:
	@sed -i.bak 's/123456789012/$(AWS_ACCOUNT_ID)/g' .github/workflows/deploy.yml 2>/dev/null || true
	@rm -f .github/workflows/deploy.yml.bak

.DEFAULT_GOAL := help