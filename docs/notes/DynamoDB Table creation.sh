# --------------------------
# CREATE DYNAMODB LOCK TABLE
# --------------------------

# Create a DynamoDB table called "terraform-state-lock"
# This will be used by Terraform to prevent multiple people/processes
# from changing the state file at the same time

aws dynamodb create-table \
    --table-name terraform-state-lock \
    \
    # Define the attributes (columns) in the table
    # LockID = the unique identifier for each lock
    # AttributeType=S means it will store strings
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    \
    # Define the key schema (how DynamoDB organizes data)
    # HASH = primary key
    # So LockID is the primary key (must be unique for each record)
    --key-schema AttributeName=LockID,KeyType=HASH \
    \
    # Use on-demand billing (PAY_PER_REQUEST)
    # Means you only pay when the table is actually used
    # Ideal for Terraform since locks are only written during runs
    --billing-mode PAY_PER_REQUEST \
    \
    # Region where the table should exist
    # Best practice: same region as the S3 bucket used for Terraform state
    --region eu-north-1
