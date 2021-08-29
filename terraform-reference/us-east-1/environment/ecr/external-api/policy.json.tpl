{
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "GrantCrossAccountPull",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "${coresvc_account_arn}"
          ]
        },
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages"
        ]
      }
    ]
  }