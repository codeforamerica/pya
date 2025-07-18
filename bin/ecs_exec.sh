#!/bin/bash

# Script to connect to the first running task in the pya-staging-web cluster

# --- Default Configuration ---
DEFAULT_ENV="staging"
DESIRED_STATUS="RUNNING"
COMMAND="/bin/sh" # Default shell

# --- Function to display usage ---
usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo "Connects to the first running ECS task in a specified environment."
    echo ""
    echo "Options:"
    echo "  --env <environment>      Specify the environment (e.g., staging, production). Determines cluster and container names. Defaults to '$DEFAULT_ENV'"
    echo "                           Required if CLUSTER_NAME/CONTAINER_NAME are not hardcoded."
    echo "  --profile <profile_name> AWS profile to use (e.g., pya-nonprod). Required."
    echo "  --desired-status <status> Task status to search for (e.g., RUNNING, STOPPED). Defaults to '$DESIRED_STATUS'."
    echo "  --command <command>      Command to execute on the container (e.g., \"/bin/bash\", \"ls -la\")."
    echo "                           Defaults to \"$COMMAND\"."
    echo "  -h, --help               Display this help message."
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") --env staging --profile pya-nonprod"
    echo "  $(basename "$0") --env production --command \"/bin/bash\""
    echo "  $(basename "$0") --env staging --desired-status STOPPED"
    exit 1
}

# --- Parse Command Line Arguments ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --env)
            ENVIRONMENT="$2"
            shift # past argument
            shift # past value
            ;;
        --profile)
            PROFILE="$2"
            shift
            shift
            ;;
        --desired-status)
            DESIRED_STATUS="$2"
            shift
            shift
            ;;
        --command)
            COMMAND="$2"
            shift
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown parameter passed: $1"
            usage
            ;;
    esac
done

# --- Validate and Set Cluster/Container Names based on AWS_PROFILE ---
if [ -z "$PROFILE" ]; then
    echo "Error: --profile parameter is required."
    usage
fi

case "$ENVIRONMENT" in
    staging)
        CLUSTER_NAME="pya-staging-web"
        CONTAINER_NAME="pya-staging-web"
        ;;
    production)
        CLUSTER_NAME="pya-production-web"
        CONTAINER_NAME="pya-production-web"
        ;;
    # Add more environments here as needed
    *)
        echo "Error: Unknown environment '$ENVIRONMENT'. Please specify 'staging' or 'production'."
        usage
        ;;
esac

echo "Attempting to connect to an ECS task in cluster: $CLUSTER_NAME (Env: $ENVIRONMENT) using profile: $(echo $PROFILE | cut -d' ' -f2)"

# --- Find the first running task ---
TASK_ARN=$(aws ecs list-tasks \
    --cluster "$CLUSTER_NAME" \
    --desired-status "$DESIRED_STATUS" \
    --query "taskArns[0]" \
    --output text \
    --profile "$PROFILE")

if [ -z "$TASK_ARN" ]; then
    echo "Error: No tasks found in cluster '$CLUSTER_NAME' with status '$DESIRED_STATUS' using the specified profile."
    exit 1
fi

echo "Found task: $TASK_ARN (Status: $DESIRED_STATUS)"

# --- Execute the command ---
echo "Executing command '$COMMAND' on container: $CONTAINER_NAME..."
aws ecs execute-command \
    --cluster "$CLUSTER_NAME" \
    --task "$TASK_ARN" \
    --container "$CONTAINER_NAME" \
    --interactive \
    --command "$COMMAND" \
    --profile "$PROFILE"

if [ $? -ne 0 ]; then
    echo "Error: Failed to execute command on the task."
    echo "Please check:"
    echo "  - Your AWS CLI credentials for profile $(echo $PROFILE_ARG | cut -d' ' -f2)"
    echo "  - Network connectivity from your machine"
    echo "  - ECS Exec permissions for your task's IAM role"
    echo "  - That the container has the specified command available (e.g., /bin/sh, /bin/bash)"
    echo "  - That the task itself is healthy and not restarting."
    exit 1
fi

echo "Session ended."
