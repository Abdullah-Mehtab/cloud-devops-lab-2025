# --------------------------
# VARIABLES
# --------------------------

# Store your AWS account ID in a variable (replace with your actual ID)
AWS_ACCOUNT_ID="554930853385"

# Build a unique bucket name using account ID
# (S3 bucket names must be globally unique across all AWS accounts)
TF_BUCKET_NAME="tf-state-${AWS_ACCOUNT_ID}-devops-project"

# --------------------------
# CREATE S3 BUCKET
# --------------------------

# Create an S3 bucket in region eu-north-1 (Stockholm)
# "--create-bucket-configuration" is required for most regions except us-east-1
aws s3api create-bucket \
    --bucket $TF_BUCKET_NAME \
    --region eu-north-1 \
    --create-bucket-configuration LocationConstraint=eu-north-1

# --------------------------
# ENABLE VERSIONING
# --------------------------

# Turn on versioning for the bucket
# This ensures all previous versions of files (like Terraform state) are kept
# Protects you from accidental overwrite or deletion
aws s3api put-bucket-versioning \
    --bucket $TF_BUCKET_NAME \
    --versioning-configuration Status=Enabled

# --------------------------
# ENABLE ENCRYPTION
# --------------------------

# Turn on server-side encryption (SSE) for the bucket
# "AES256" = use AWS-managed encryption keys (default option)
# Ensures all data is automatically encrypted when stored ("at rest")
aws s3api put-bucket-encryption \
    --bucket $TF_BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
