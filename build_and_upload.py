import os
import json
import shutil
import subprocess
import zipfile
from pathlib import Path

import boto3


print("[INFO] Initializing build and upload script...")

root = Path(__file__).resolve().parent
terraform_dir = root / "terraform"
frontend_dir = root / "frontend"
lambda_dir = terraform_dir / "scripts" / "lambda"
glue_dir = terraform_dir / "scripts" / "glue"
prompt_file = terraform_dir / "scripts" / "prompts" / "fraud_analisys.md"
alt_prompt_name = terraform_dir / "scripts" / "prompts" / "fraud_analysis.md"


def package_lambda(name: str):
    print(f"[STEP] Packaging Lambda: {name}")
    src = lambda_dir / f"{name}.py"
    if not src.exists():
        raise FileNotFoundError(f"Lambda source not found: {src}")
    print(f"[INFO] Found source file: {src}")

    staging_dir = root / ".build" / name
    if staging_dir.exists():
        print(f"[INFO] Removing old staging dir: {staging_dir}")
        shutil.rmtree(staging_dir)
    staging_dir.mkdir(parents=True, exist_ok=True)
    print(f"[INFO] Created staging dir: {staging_dir}")

    shutil.copy2(src, staging_dir / f"{name}.py")

    prompt_dir = staging_dir / "prompts"
    prompt_dir.mkdir(parents=True, exist_ok=True)

    if prompt_file.exists():
        shutil.copy2(prompt_file, prompt_dir / "fraud_analisys.md")
        print(f"[INFO] Added prompt file: {prompt_file}")
    if alt_prompt_name.exists():
        shutil.copy2(alt_prompt_name, prompt_dir / "fraud_analysis.md")
        print(f"[INFO] Added alternate prompt file: {alt_prompt_name}")

    zip_path = lambda_dir / f"{name}.zip"
    if zip_path.exists():
        zip_path.unlink()
        print(f"[INFO] Removed previous zip: {zip_path}")

    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for path in staging_dir.rglob("*"):
            if path.is_file():
                rel = path.relative_to(staging_dir)
                zf.write(path, arcname=str(rel))
                print(f"[INFO] Added to zip: {rel}")

    shutil.rmtree(staging_dir)
    print(f"[SUCCESS] Created zip: {zip_path}")


def run_terraform_command(args: list[str], step_name: str):
    cmd = ["terraform", *args]
    print(f"[STEP] {step_name}")
    print(f"[INFO] Command: {' '.join(cmd)} (cwd={terraform_dir})")
    result = subprocess.run(cmd, cwd=str(terraform_dir), capture_output=True, text=True)
    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr)
    if result.returncode != 0:
        raise RuntimeError(f"{step_name} failed with exit code {result.returncode}")
    return result


def terraform_apply():
    print("[INFO] Checking Terraform CLI availability...")
    version_check = subprocess.run(["terraform", "version"], capture_output=True, text=True)
    if version_check.returncode != 0:
        raise RuntimeError(
            "Terraform CLI is not working in this environment. "
            "The installed executable is broken or not available on PATH. "
            "Install a valid Terraform binary and retry."
        )

    run_terraform_command(["init", "-backend=false", "-input=false"], "Initializing Terraform")
    run_terraform_command([
        "apply",
        "-var-file=./envs/prd.tfvars",
        "-auto-approve",
    ], "Applying Terraform configuration")
    print("[SUCCESS] Terraform apply completed successfully.")


def get_bucket_name():
    print("[STEP] Looking for the Terraform-created S3 bucket...")
    s3 = boto3.client("s3")
    buckets = s3.list_buckets().get("Buckets", [])
    print(f"[INFO] Found {len(buckets)} bucket(s) in S3")
    for bucket in buckets:
        name = bucket["Name"]
        print(f"[INFO] Checking bucket: {name}")
        if name.startswith("my-tf-test-bucket-"):
            print(f"[SUCCESS] Found target bucket: {name}")
            return name
    raise RuntimeError("Could not find the created S3 bucket with prefix 'my-tf-test-bucket-'")


def write_frontend_config(lambda_url: str):
    if not frontend_dir.exists():
        frontend_dir.mkdir(parents=True, exist_ok=True)

    config_path = frontend_dir / "config.js"
    content = f'window.LAMBDA_FUNCTION_URL = "{lambda_url}";\n'
    config_path.write_text(content, encoding="utf-8")
    print(f"[SUCCESS] Frontend config written to: {config_path}")


def get_lambda_function_url(function_name: str):
    print(f"[STEP] Fetching Lambda Function URL for: {function_name}")
    cmd = [
        "aws",
        "lambda",
        "get-function-url-config",
        "--function-name",
        function_name,
        "--query",
        "FunctionUrl",
        "--output",
        "text",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"Could not get function URL for {function_name}.\n{result.stderr.strip()}")

    url = result.stdout.strip()
    if not url:
        raise RuntimeError(f"Function URL response empty for {function_name}")

    print(f"[SUCCESS] Lambda URL found: {url}")
    return url


def upload_glue_script(bucket_name: str):
    print("[STEP] Uploading Glue script to S3...")
    src = glue_dir / "transaction_normalization.py"
    if not src.exists():
        raise FileNotFoundError(f"Glue script not found: {src}")
    print(f"[INFO] Glue source file: {src}")

    s3 = boto3.client("s3")
    target_key = "jobs/transaction_normalization_job.py"
    s3.upload_file(str(src), bucket_name, target_key)
    print(f"[SUCCESS] Uploaded Glue script to s3://{bucket_name}/{target_key}")


def main():
    print("[INFO] Starting automation pipeline...\n")
    try:
        package_lambda("backend_service")
        package_lambda("fraud_detection")
        terraform_apply()
        bucket_name = get_bucket_name()
        upload_glue_script(bucket_name)

        lambda_url = get_lambda_function_url("backend_service")
        write_frontend_config(lambda_url)

        print("\n[SUCCESS] Build and upload pipeline finished successfully.")
        print(f"[INFO] Frontend can call: {lambda_url}")
    except Exception as exc:
        print(f"\n[ERROR] Pipeline failed: {exc}")
        raise


if __name__ == "__main__":
    main()
