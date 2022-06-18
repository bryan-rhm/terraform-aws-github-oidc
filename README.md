# terraform-aws-github-oidc
Module to create github oidc integration with AWS.

## Usage

### Install the module

Initialize the module and get the Role ARN from the outputs.

```hcl
provider "aws" {
  region = var.region
}

module "github_oidc" {
  source  = "bryan-rhm/github-oidc/aws"
  version = "1.0.0"

  github_organization = "YOUR ORGANIZATION/GITHUB ACCOUNT"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"] # Policies you want to attach to the github role.

}
```

Once you have installed the module you will be able authenticate from your github organization using the role created from the module.

The job or workflow run requires a permissions setting with id-token: write. You won't be able to request the OIDC JWT ID token if the permissions setting for id-token is set to read or none.

```yaml
permissions:
  id-token: write
```

The aws-actions/configure-aws-credentials action receives a JWT from the GitHub OIDC provider, and then requests an access token from AWS. For more information, see the [AWS documentation](https://github.com/aws-actions/configure-aws-credentials).

```yaml
# Sample workflow to access AWS resources when workflow is tied to branch
# The workflow Creates static website using aws s3
name: AWS example workflow
on:
  push
env:
  BUCKET_NAME : "<example-bucket-name>"
  AWS_REGION : "<example-aws-region>"
# permission can be added at job level or workflow level    
permissions:
      id-token: write
      contents: read    # This is required for actions/checkout
jobs:
  S3PackageUpload:
    runs-on: ubuntu-latest
    steps:
      - name: Git clone the repository
        uses: actions/checkout@v3
      - name: configure aws credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: arn:aws:iam::1234567890:role/example-role
          role-session-name: samplerolesession
          aws-region: ${{ env.AWS_REGION }}
      # Upload a file to AWS s3
      - name:  Copy index.html to s3
        run: |
          aws s3 cp ./index.html s3://${{ env.BUCKET_NAME }}/
```


### References
[Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.43.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.19.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy_document.asume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.certificate](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | The GitHub organization to allow access to | `string` | n/a | yes |
| <a name="input_github_repositories"></a> [github\_repositories](#input\_github\_repositories) | The GitHub repositories inside the organization you want to allow access to | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_github_url"></a> [github\_url](#input\_github\_url) | The URL of the GitHub OAuth2 provider | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | The ARNs of the managed policies to attach to the role | `list(string)` | `[]` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role | `string` | `"GithubActionsRole"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_assume_role_policy"></a> [assume\_role\_policy](#output\_assume\_role\_policy) | Assume role policy, this value can be used to create another role outside this module |
| <a name="output_oidc"></a> [oidc](#output\_oidc) | Github openid connect provider |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | Arn of the IAM role allowed to authenticate to AWS from Github actions |
