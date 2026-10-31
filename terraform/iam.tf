data "aws_iam_policy_document" "ec2_assume"{
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_ec2" {
  name               = "${var.project_name}-app-ec2-role-tf"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role" "db_ec2" {
  name               = "${var.project_name}-db-ec2-role-tf"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "ecr_pull" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = [aws_ecr_repository.todoapp.arn]
  }
}

resource "aws_iam_role_policy" "app_ecr_pull" {
  role       = aws_iam_role.app_ec2.name
  policy     = data.aws_iam_policy_document.ecr_pull.json
}

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "db_ssm" {
  role       = aws_iam_role.db_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.project_name}-ec2-app-profile"
  role = aws_iam_role.app_ec2.name
}

resource "aws_iam_instance_profile" "db_profile" {
  name = "${var.project_name}-ec2-db-profile"
  role = aws_iam_role.db_ec2.name
}