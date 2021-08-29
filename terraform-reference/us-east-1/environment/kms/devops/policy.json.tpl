{
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${sso_administrator_role_arn_fqdn}"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
