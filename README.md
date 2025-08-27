# Lambda GitHub Actions Demo

This repository demonstrates how to test and use GitHub Actions to automatically deploy Lambda functions when you push code or configuration changes to your repository. The GitHub Actions workflow provides a declarative, simple YAML interface that eliminates the complexity of manual deployment steps.

This is a practical implementation for testing the automatic deployment of AWS Lambda functions using GitHub Actions with Python.

## Setup

### Prerequisites
- AWS Account with appropriate permissions
- GitHub repository with Actions enabled
- AWS IAM role configured for OIDC with GitHub Actions

### AWS IAM Role Setup

1. Create an IAM role with the following trust policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:yourusername/lambda-github-actions-demo:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

2. Attach the following policies to the role:
   - `AWSLambdaFullAccess` (or create a custom policy with minimal permissions)

### Configuration

1. Update the workflow file (`.github/workflows/deploy.yml`) with your:
   - AWS Account ID in the role ARN
   - AWS Region
   - Lambda function name

2. Create your Lambda function in AWS Console or via CLI:
```bash
aws lambda create-function \
  --function-name my-lambda-function \
  --runtime python3.11 \
  --role arn:aws:iam::123456789012:role/lambda-execution-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda-function.zip
```

## Local Development

### Test locally:
```bash
python -c "from src.lambda_function import lambda_handler; print(lambda_handler({}, None))"
```

### Build package locally:
```bash
python build.py
```

## Deployment

Push to the `main` branch to trigger automatic deployment via GitHub Actions.

## Project Structure

```
├── .github/workflows/deploy.yml  # GitHub Actions workflow
├── src/lambda_function.py        # Main Lambda function
├── requirements.txt              # Python dependencies
├── build.py                     # Local build script
└── README.md                    # This file
```