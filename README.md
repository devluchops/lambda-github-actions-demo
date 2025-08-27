# Lambda GitHub Actions Demo

This project shows how to automatically deploy AWS Lambda functions using GitHub Actions. When you push code to the main branch, it automatically updates your Lambda function.

## How it works

Instead of manually deploying your Lambda function every time you make changes, this setup does it automatically. It uses GitHub Actions to build and deploy your code whenever you push to the main branch.

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

2. **Run the setup**
   ```bash
   make setup
   ```
   
   This creates all the necessary AWS resources:
   - OIDC provider for GitHub
   - IAM roles and permissions
   - Lambda function
   - Updates the workflow file

3. **Push your code**
   
   That's it. Push to main branch and watch it deploy automatically.

## Project structure

```
├── .github/workflows/deploy.yml    # GitHub Actions workflow
├── src/lambda_function.py          # Your Lambda code
├── requirements.txt                # Python dependencies
├── build.py                        # Local build script
├── Makefile                        # Setup commands
└── README.md
```

## Local development

Test your function locally:
```bash
python -c "from src.lambda_function import lambda_handler; print(lambda_handler({}, None))"
```

Build the deployment package:
```bash
python build.py
```

## Making changes

**Add Python packages:** Update `requirements.txt`

**Change function name:** Update `LAMBDA_FUNCTION_NAME` in Makefile and `function-name` in the workflow file

**Add environment variables:** Use AWS console or CLI

## What gets created in AWS

- **OIDC Provider:** Allows GitHub to authenticate with AWS
- **GitHubActionRole:** Permissions for GitHub Actions to deploy
- **LambdaExecutionRole:** Permissions for the Lambda function to run
- **Lambda Function:** Your actual function

## Troubleshooting

**"Invalid credentials" error:**
```bash
aws sts get-caller-identity  # Check AWS CLI setup
```

**"Function not found" error:**
```bash
make create-function
```

**GitHub Actions deployment fails:**
Check the Actions tab in your GitHub repository for detailed error messages.

## Manual commands

```bash
# List your Lambda functions
aws lambda list-functions

# Invoke your function
aws lambda invoke --function-name my-lambda-function output.json

# View function logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/my-lambda-function
```

This setup follows AWS documentation and uses their official GitHub Actions for Lambda deployment.