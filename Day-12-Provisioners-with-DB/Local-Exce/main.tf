provider "aws" {
  region = "us-west-2"
}

# 1. Get default VPC details to attach the security group
data "aws_vpc" "default" {
  default = true
}

# 2. Create Security Group to allow your local machine to connect
resource "aws_security_group" "rds_sg" {
  name        = "allow_local_mysql"
  description = "Allow inbound MySQL traffic from local machine"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ For testing. Ideally, change to your specific local public IP (e.g., "X.X.X.X/32")
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Create the RDS instance
resource "aws_db_instance" "mysql_rds" {
  identifier             = "my-mysql-db"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Edwin12345!" # 👈 Kept this password
  db_name                = "dev"
  allocated_storage      = 20
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # 👈 Attaches the security group
}

# 4. Execute the local SQL script
resource "null_resource" "local_sql_exec" {
  depends_on = [aws_db_instance.mysql_rds]

  provisioner "local-exec" {
    # This automatically downloads the official MySQL shell environment line silently
    command = "winget install Oracle.MySQL -e --silent && mysql -h ${aws_db_instance.mysql_rds.address} -u ${aws_db_instance.mysql_rds.username} -p'Edwin12345!' ${aws_db_instance.mysql_rds.db_name} < test.sql"
  }



  triggers = {
    always_run = timestamp()
  }
}

output "database_endpoint" {
  value       = aws_db_instance.mysql_rds.address
  description = "Connect to this database endpoint address"
}
