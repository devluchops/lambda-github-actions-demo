# Lambda GitHub Actions Demo

This project shows how to automatically deploy AWS Lambda functions using GitHub Actions. When you push code to the main branch, it automatically creates or updates your Lambda function.

## How it works

The first time you push to main, GitHub Actions will create your Lambda function. On subsequent pushes, it will update the existing function with your new code.

The deployment uses OIDC (OpenID Connect) to securely connect GitHub to AWS without storing AWS credentials in your repository.

## Prerequisites

- AWS account with admin access
- GitHub repository
- AWS CLI configured locally
- `make` command available

## Setup

1. **Configure your repository name**
   
   Edit the `Makefile` and update line 2 with your actual GitHub repository:
   ```
   GITHUB_REPO ?= your-username/your-repo-name
   ```

2. **Set up AWS infrastructure**
   ```bash
   make setup
   ```
   
   This creates the AWS infrastructure needed for deployment:
   - OIDC provider for GitHub
   - IAM roles and permissions
   - Updates the workflow file with your account ID

3. **Push your code**
   
   Push to main branch. GitHub Actions will create your Lambda function automatically on the first deploy.

## Project structure

```
├── .github/workflows/deploy.yml    # GitHub Actions workflow
├── src/lambda_function.py          # Your Lambda code
├── requirements.txt                # Python dependencies
├── Makefile                        # Setup commands
└── README.md
```

## Local development

Test your function locally:
```bash
python -c "from src.lambda_function import lambda_handler; print(lambda_handler({}, None))"
```

## Making changes

**Add Python packages:** Update `requirements.txt`

**Change function name:** Update `LAMBDA_FUNCTION_NAME` in Makefile and `function-name` in the workflow file

**Add environment variables:** Use AWS console or CLI after the function is created

## What gets created

**By `make setup`:**
- OIDC Provider for GitHub authentication
- GitHubActionRole with Lambda deployment permissions
- LambdaExecutionRole for the function runtime

**By GitHub Actions (on first push):**
- Lambda function with your code

## Troubleshooting

**"Invalid credentials" error:**
```bash
aws sts get-caller-identity  # Check AWS CLI setup
```

**GitHub Actions deployment fails:**
Check the Actions tab in your GitHub repository for detailed error messages.

**Need to delete everything:**
```bash
# Delete Lambda function
aws lambda delete-function --function-name my-lambda-function

# Delete roles (optional)
aws iam delete-role --role-name GitHubActionRole
aws iam delete-role --role-name LambdaExecutionRole
```

## Manual commands

```bash
# List your Lambda functions
aws lambda list-functions

# Invoke your function
aws lambda invoke --function-name my-lambda-function output.json

# View function logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/my-lambda-function
```

This setup follows AWS best practices where infrastructure setup is separate from application deployment.