# ---------------------------------------------------------------------------
# Database password (generated; view with `terraform output -raw db_password`)
# ---------------------------------------------------------------------------
resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#%*+-=?^_"
}

# ---------------------------------------------------------------------------
# Self-managed MySQL (MariaDB) on a private EC2 instance.
#
# NOTE: AWS Academy Learner Lab blocks managed RDS (rds:CreateDBInstance is
# denied), so this project runs MySQL on an EC2 instance in a private subnet
# instead. The network topology is identical to the RDS design: the database
# lives in a private subnet and only the WordPress fleet's security group can
# reach it on port 3306. Trade-off vs. RDS: no managed Multi-AZ failover,
# automated backups, or patching.
# ---------------------------------------------------------------------------
resource "aws_instance" "db" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.rds.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  user_data = base64encode(templatefile("${path.module}/db_user_data.sh.tftpl", {
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = random_password.db.result
  }))

  tags = {
    Name = "${var.project_name}-db"
  }
}
