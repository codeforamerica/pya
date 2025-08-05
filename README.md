# Prior Year Access – File Your State Taxes

This repository supports **Prior Year Access** for users of **File Your State Taxes**. It allows individuals who filed their state taxes with us in **2023** or **2024** to securely retrieve their tax return PDFs.


---

## Infrastructure with OpenTofu

This project uses OpenTofu to manage infrastructure as code. It provisions and maintains various cloud resources, including:

- S3 buckets
- EC2 instances
- IAM roles

The infrastructure for this repository is located in the [CFA Tax-Benefits-Backend repository](https://github.com/codeforamerica/tax-benefits-backend)
  [Staging](https://github.com/codeforamerica/tax-benefits-backend/tree/main/tofu/config/staging.pya.fileyourstatetaxes.org)
  [Production](https://github.com/codeforamerica/tax-benefits-backend/tree/main/tofu/config/pya.fileyourstatetaxes.org)

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
  The deploy job can be triggered manually by navigating to the github actions page and running the `Deploy to AWS Staging` action.

### Environment Variables & Secrets

The workflow relies on the following secrets:

- `AWS_ACCESS_KEY` / `AWS_SECRET_KEY`: Credentials for accessing AWS services (ECR, SSM)
- `SLACK_WEBHOOK_URL`: Sends Slack notifications for test results
- `STAGING_DEPLOY_PAT`: GitHub Personal Access Token used to trigger the downstream deployment workflow

  The staging PAT will need to be regenerated every 90 days and updated in Github and Lastpass
---

## Stylesheet Compilation

This project uses the [`dart-sass`](https://rubygems.org/gems/dart-sass) Ruby gem to compile SCSS files.

To compile stylesheets locally:

```bash
bin/rake dartsass:build
```

## Access to Database

Locally, you can use `bin/rails console`

On Heroku, you can use `heroku run rails c -a <review-app-name>`

On Staging and Production, use the `aws ecs execute-command`. You must have `awscli` isntalled on your machine already (check with `aws --version`). 
If not, `brew install awscli` on your local machine ([AWS instructions here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)). 
Please download the [AWS Session Manager as well following AWS instructions](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-macos-overview.html)

You also need `AWS_PROFILE` for Prior Year Access (for both Prod and Non-Prod AWS accounts). [Follow AWS Identity Center: Configuring SSO instructions](https://www.notion.so/cfa/AWS-Identity-Center-e8a28122b2f44595a2ef56b46788ce2c?source=copy_link#ef1c6c77703b4215bbe1953de4692054) to configure your profile correctly.
Name the Prior Year Access - Prod profile as `pya-prod` and Prior Year Access - Non-prod profile as `pya-nonprod`. You can rename your aws profile by editing your `~/.aws/config` and `~/.aws/credentials`.

### Use bin/ecs_exec script (recommended in most cases)

1. Make sure you're logged into aws: `aws sso login`. This should open up an AWS console and have you sign in (if you aren't signed in already). After verification, it'll return you to the terminal 
2. For staging, you can use `bin/ecs_exec`
3. For production, you can pass in `bin/ecs_exec --environment production`
4. You can pass in other parameters like:
   1. `--desired-status`: `RUNNING` by default, but can specify `STOPPED`. See documentation for [list-tasks](https://docs.aws.amazon.com/cli/latest/reference/ecs/list-tasks.html).
   2. `--command`: if you want to run something other than `bin/sh`
   3. There are other commands that the aws ecs can call. The options can be passed manually into the `list-tasks` ([doc](https://docs.aws.amazon.com/cli/latest/reference/ecs/list-tasks.html)) and `execute-command`([doc](https://docs.aws.amazon.com/cli/latest/reference/ecs/execute-command.html)) commands. See linked documentation.
5. Type in `bin/rails c --sandbox` (remove `--sandbox` if you must perform operations that will write/modify data in the db; please pair/try to be loud as possible when performing a write operation)
   1. When you start rails console, it will say `Loading production environment (Rails <version>)` for both staging AND production. This is because we don't explicitly set a `staging` environment for the RAILS_ENV in our app, to make sure that the environments are similar as possible (We use `REVIEW_APP` to specify heroku/staging environments against the production environment).

---

### Ssh into AWS ECS Manually (if you need to pass in more parameters than the script supports)

1. Find your `task ARN`
```
AWS_PROFILE=<aws profile name> \
    aws ecs list-tasks --cluster pya-staging-web \
    --query "taskArns[0]" --output text
```
This will return the RUNNING task. 

Note that if the newest deploy ran into trouble starting the task, it will be in the STOPPED state. In order to try to debug tasks that have not started successfully or have died/finished, you can add in `--desired-status STOPPED`
See [AWS CLI list-tasks docs for more information and options](https://docs.aws.amazon.com/cli/latest/reference/ecs/list-tasks.html#options)

2. Run the `aws ecs execute-command` ([AWS ECS Execute-Command Docs](https://docs.aws.amazon.com/cli/latest/reference/ecs/execute-command.html))
```
AWS_PROFILE=<aws profile name> \
    aws ecs execute-command --cluster pya-<environment>-web \
    --task <task ARN; from above> \
    --container pya-<environment>-web \
    --interactive \
    --command "/bin/sh"
```
then when you successfully connect, you'll see:

```
The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.


Starting session with SessionId: ecs-execute-command-<some random string>
#
```
3. `bin/rails c --sandbox` (omit the `--sandbox` if you have to perform a write operation)

---

### (Not recommended) Direct DB access via SQL Statements

You can also utilize AWS Query Editor or `aws rds-data` commands to directly access the staging/production database via psql.

```
  AWS_PROFILE=<aws profile name> \
  aws rds-data execute-statement \
    --resource-arn "arn:aws:rds:us-east-1:<account_id>:cluster:pya-<environment>-web" \
    --secret-arn "arn:aws:secretsmanager:us-east-1:<account_id>:secret:rds\!cluster-<secret>" \
    --database prior_year_access \
    --sql '<enter sql statement here>'
```

- Your `AWS_PROFILE` should match the environment (Prior Year Access - Prod vs Non-Prod) you're trying to query
- You can grab the `resource-arn` from AWS console > Aurora and RDS > Databases > pya-<environment>-web > Configuration > Amazon Resource Name (ARN).
- `secret-arn` could be found in the AWS Secrets Manager (starts with `rds!cluster` -- grab the ARN

---

## Running the Linter

To run the linter locally, run the following command: `bundle exec standardrb --fix`. If you forget to do this, the linter will run when a branch pushed up. To ignore the linter, here is a [guide](https://github.com/standardrb/standard?tab=readme-ov-file#ignoring-errors).
