# Prior Year Access – File Your State Taxes

This repository supports **Prior Year Access** for users of **File Your State Taxes**. It allows individuals who filed their state taxes with us in **2023** or **2024** to securely retrieve their tax return PDFs.

---

## Infrastructure with OpenTofu

This project uses OpenTofu to manage infrastructure as code. It provisions and maintains various cloud resources, including:

- S3 buckets
- EC2 instances
- IAM roles

### Usage

Developers interact with OpenTofu using the following commands:

```bash
tofu init        # Initialize the working directory
tofu plan        # Preview changes
tofu apply       # Apply changes to infrastructure
```

### CI/CD Integration

OpenTofu is integrated into our CI pipeline.
---

## Deployment to AWS Staging

This project uses a GitHub Actions workflow to automatically deploy to the AWS staging environment after tests pass on the `main` branch.

### Workflow Breakdown

#### 1. Test Job

- Runs the full Rails test suite:
  ```bash
  bin/rails db:test:prepare test test:system
  ```
- Sends test status notifications to Slack, tagging the appropriate team members

#### 2. Deploy Job

- Executes only if the test job completes successfully
- Builds a Docker image and pushes it to Amazon ECR
- Updates an AWS Systems Manager (SSM) parameter with the image tag to track the deployed version
- Triggers a downstream GitHub Action in the [`tax-benefits-backend`](https://github.com/codeforamerica/tax-benefits-backend) repository using a `repository_dispatch` event, passing:

  ```json
  {
    "environment": "pya-nonprod",
    "config": "staging.pya.fileyourstatetaxes.org"
  }
  ```

### Environment Variables & Secrets

The workflow relies on the following secrets:

- `AWS_ACCESS_KEY` / `AWS_SECRET_KEY`: Credentials for accessing AWS services (ECR, SSM)
- `SLACK_WEBHOOK_URL`: Sends Slack notifications for test results
- `STAGING_DEPLOY_PAT`: GitHub Personal Access Token used to trigger the downstream deployment workflow

---

## Stylesheet Compilation

This project uses the [`dart-sass`](https://rubygems.org/gems/dart-sass) Ruby gem to compile SCSS files.

To compile stylesheets locally:

```bash
bin/rake dartsass:build
```
