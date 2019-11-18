# AWS infrastructure with terraform and  github actions

Structure of repository:
* .github - workflow of github. Prepare dynamodb table, s3 bucket, ecr, docker image and execute terraform 
* docker - store Dockerfile and dependencies files
* terraform - description aws infrastructure

### Build and run docker image
```
docker build -t graphic-counter:lastest ./docker
docker run -d -p 8080:80 graphic-counter:lastest
curl -sI 127.0.0.1:8080?showinfo
```

### Terraform init
Before run terraform export environment variables:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_DEFAULT_REGION
- AWS_REGION
- STATE_NAME (name of s3 bucket and dynamodb table)
- TF_VAR_db_pass (password for database in rds)
- TF_VAR_tag (tag for image from repository in ecr)

#### How to use it:

For initialization modules can use variables declared in the previous step. Conveniently

```
terraform init -backend-config="dynamodb_table=${STATE_NAME}" -backend-config="bucket=${STATE_NAME}" -backend-config="region=${AWS_REGION}"
```

View the current changes

```
terraform plan
```

And deploy configuration
```
terraform apply
```

### GitHub action

All these actions will be executed automatically when you push commits to the repository. To work correctly you need to add the secrets in the repository settings:
- AWS_ACCESS_KEY_ID	
- AWS_SECRET_ACCESS_KEY	
- AWS_REGION	
- DB_PASS	(name of s3 bucket and dynamodb table)
- STATE_NAME (password for database in rds)
