provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Backend for State file
terraform {
  backend "s3" {
    bucket         = "aws-flask-bucket-epam-12342073"
    key            = "stage/flask-app/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

# Beanstalk instance profile
resource "aws_iam_instance_profile" "beanstalk" {
  name  = "beanstalk-ec2-userprofile1-epam"
  role = "${aws_iam_role.beanstalk.name}"
}

resource "aws_iam_role" "beanstalk" {
  name = "beanstalk-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Beanstalk EC2 Policy
# Overriding because by default Beanstalk does not have a permission to Read ECR
resource "aws_iam_role_policy" "beanstalk" {
  name = "beanstalk-policy"
  role = "${aws_iam_role.beanstalk.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData",
        "ds:CreateComputer",
        "ds:DescribeDirectories",
        "ec2:DescribeInstanceStatus",
        "logs:*",
        "ssm:*",
        "ec2messages:*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "s3:*",
        "rds:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Find default vpc, subnets & new beanstalk security groups
data "aws_vpc" "flask" {
  default = true
}

data "aws_subnet_ids" "flask" {
  vpc_id = data.aws_vpc.flask.id
}

# Create Server
resource "aws_db_instance" "postgres" {
  depends_on           = [aws_security_group.postgres]     
  name                 = var.server_name
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  instance_class       = "db.t2.micro"
  publicly_accessible  = true # Set to false after deployment
  skip_final_snapshot  = true
  username             = var.admin_name
  password             = var.admin_pass
  db_subnet_group_name = "${aws_db_subnet_group.postgres.name}"
  vpc_security_group_ids = ["${aws_security_group.postgres.id}"]
}

resource "aws_db_subnet_group" "postgres" {
  name       = "postgres_db_sub_group"
  subnet_ids = data.aws_subnet_ids.flask.ids
}

resource "aws_security_group" "postgres" {
  depends_on  = [aws_elastic_beanstalk_environment.flask]
  name        = "postgres_inbound"
  description = "Allow inbound traffic from instances within VPC"
  vpc_id      =  data.aws_vpc.flask.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# Create Web Application
resource "aws_elastic_beanstalk_application" "flask" {
  name        = var.application_name
  description = "Beanstalk Application for flask api"
}

resource "aws_elastic_beanstalk_environment" "flask" {
  depends_on           = [aws_elastic_beanstalk_application.flask]
  name                = "${var.application_name}-environment1"
  application         = "${aws_elastic_beanstalk_application.flask.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.12.14 running Docker 18.06.1-ce"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value = "3"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value = "1"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.beanstalk.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = var.port
  }
}