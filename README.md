# Open Policy Agent AWS Lambda

This is an PoC of a Lambda endpoint, which can be used to verify policies using Open Policy Agent. The idea is to bundle OPA policies and the Lambda binary to the deployment package. You can send then query the endpoint to get results of the policy evaluation.

## How it works
The lambda is deployed using Serverless framework and contains:
- OPA policies (`opa` directory)
- AWS Lambda binary (`cmd/opa.go`)

```sh
$ make deploy
[...]
Stack Outputs
OpaLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:xxxxxxxxx:function:opa-terraform-dev-opa:21
ServiceEndpoint: https://xxx.execute-api.us-east-1.amazonaws.com/dev
ServerlessDeploymentBucketName: opa-terraform-dev-serverlessdeploymentbucket-xxx
```

The Lambda function receives the input for the policies in the POST request body and the query to evaluate in query parameter

```sh
$ terraform plan -out tfplan
$ terraform show -json tfplan > tfplan.json
$ curl -XPOST 'https://xxx.execute-api.us-east-1.amazonaws.com/dev/opa?query=data.policies.terraform.errors' -d @tfplan.json

[
  {
    "expressions": [
      {
        "value": [
          "Error in resource aws_cloudtrail.organization. Missing required tag Project",
          "Error in resource aws_elasticsearch_domain.logging. Missing required tag Environment",
        ],
        "text": "data.policies.terraform.errors",
        "location": {
          "row": 1,
          "col": 1
        }
      }
    ]
  }
]
```

This can be used to create an API endpoint, where you can send for eg. a Terraform plan for Kubernetes resource defintion for validation in your CI/CD pipeline against some team/project/company wide policies
