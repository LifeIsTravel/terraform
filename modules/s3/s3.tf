resource "aws_s3_bucket" "airflow_log" {
  bucket = "${var.project_name}-airflow-log"
}

resource "aws_s3_object" "airflow_log_directory" {
  bucket = aws_s3_bucket.airflow_log.id
  key    = "logs/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state"
}

resource "aws_s3_object" "terraform_state_directory" {
  bucket = aws_s3_bucket.terraform_state.id
  key    = "state/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket" "airflow_dags_bucket" {
  bucket = "${var.project_name}-airflow-dags"
  
}

resource "aws_s3_object" "dags_directory" {
  bucket = aws_s3_bucket.airflow_dags_bucket.id
  key    = "dags/"
  content_type = "application/x-directory"
}


# Block public access for all buckets
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  count = 2

  bucket = [
    aws_s3_bucket.airflow_log.id,
    aws_s3_bucket.terraform_state.id,
    aws_s3_bucket.airflow_dags_bucket.id
  ][count.index]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}