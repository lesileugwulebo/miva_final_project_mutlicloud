resource "aws_security_group" "web" {
  name        = "web-tier-sg"
  description = "Allow inbound HTTPS traffic to Web tier"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTPS from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP redirect"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web-tier-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "app-tier-sg"
  description = "Allow inbound API traffic from Web tier and Azure App tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "API traffic from Web SG"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    description = "Cross-cloud API traffic from Azure App VNet"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [var.azure_vnet_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "app-tier-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "db-tier-sg"
  description = "Allow PostgreSQL inbound traffic from App tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from App SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description = "Cross-cloud DB sync/queries from Azure App VNet"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.azure_vnet_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "db-tier-sg"
  }
}

resource "aws_security_group" "mgmt" {
  name        = "mgmt-tier-sg"
  description = "Allow SSH access from admin or bastion"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Web/bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/20"] # internal routing
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mgmt-tier-sg"
  }
}

resource "aws_kms_key" "db_key" {
  description             = "KMS Key for at-rest database encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "database-kms-key"
  }
}

resource "aws_kms_alias" "db_key_alias" {
  name          = "alias/database-kms-key"
  target_key_id = aws_kms_key.db_key.key_id
}

resource "aws_guardduty_detector" "guardduty" {
  enable = true
}

resource "aws_iam_role" "federated_workload" {
  name = "federated-azure-workload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::123456789012:oidc-provider/login.microsoftonline.com/your-tenant-id/v2.0"
        }
        Condition = {
          StringEquals = {
            "login.microsoftonline.com/your-tenant-id/v2.0:aud" = "api://azure-workload-app"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "workload_policy" {
  name        = "federated-workload-policy"
  description = "Least privilege permissions for federated workload"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::multicloud-workload-bucket/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "workload_attach" {
  role       = aws_iam_role.federated_workload.name
  policy_arn = aws_iam_policy.workload_policy.arn
}
