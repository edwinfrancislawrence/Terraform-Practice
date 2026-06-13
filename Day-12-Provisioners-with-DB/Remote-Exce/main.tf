provider "aws" {
  region = "us-west-2"
}

# 1. Key Pair
resource "aws_key_pair" "example" {
  key_name   = "task"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# 2. VPC Network Infrastructure Layout
resource "aws_vpc" "name" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true # Required for certain VPC Endpoint connections
  enable_dns_support   = true
  tags                 = { Name = "My VPC" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.name.id
  tags   = { Name = "Dev-igw" }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.name.id
  tags   = { Name = "Dev-rt" }
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_subnet" "name" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "name2" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.name.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "main2" {
  subnet_id      = aws_subnet.name2.id
  route_table_id = aws_route_table.main.id
}

resource "aws_db_subnet_group" "name" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.name.id, aws_subnet.name2.id]
}

# 3. Unified Security Group (Fixes Circular Dependency Crash)
resource "aws_security_group" "name" {
  name        = "my-shared-security-group"
  description = "Allow SSH and MySQL traffic internally"
  vpc_id      = aws_vpc.name.id

  # Rule 1: Allows you to SSH into the EC2 Runner from your local computer
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For security, change this to your local IP (e.g. "X.X.X.X/32")
  }

  # Rule 2: Allows ALL resources inside this Security Group to talk to each other (EC2 to RDS)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. EC2 Compute Instance
resource "aws_instance" "sql_runner" {
  ami                         = "ami-09e69ca1171857250" # Amazon Linux 2 (us-west-2)
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.example.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.name.id
  vpc_security_group_ids      = [aws_security_group.name.id]

  tags = {
    Name = "SQL Runner"
  }
}

# 5. Secure RDS Database Instance (Turned Off Public Access)
resource "aws_db_instance" "name" {
  identifier             = "my-rds-instance"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.name.name
  vpc_security_group_ids = [aws_security_group.name.id]
  skip_final_snapshot    = true
  publicly_accessible    = false # 🔐 SECURE: Database is now completely private/internal
  username               = "admin"
  password               = "Edwin12345" # 👈 Aligned to match the string below
  db_name                = "dev"        # 👈 Ensured the logical database is pre-created
}

# 6. Remote Database Executor Provisioner Step
resource "null_resource" "remote_sql_exec" {
  depends_on = [aws_db_instance.name, aws_instance.sql_runner]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = aws_instance.sql_runner.public_ip
  }

  provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }

    provisioner "remote-exec" {
    inline = [
      # 1. Install client tools
      "sudo yum update -y",
      "sudo yum install -y mariadb105 || sudo yum install -y mariadb",

      # 2. Waiter Loop: Wait for the database engine to finish booting privately
      "echo 'Waiting for private RDS database port 3306 to open...'",
      "until timeout 3 bash -c 'cat < /dev/null > /dev/tcp/${aws_db_instance.name.address}/3306' 2>/dev/null; do",
      "  echo 'Database not ready yet. Retrying in 10 seconds...'",
      "  sleep 10",
      "done",
      "echo 'SUCCESS: Connection to RDS established!'",

      # 3. Allow diagnostics to show up in terminal if the query fails
      "set +e",

      # 4. Run the file import
      "mysql -h ${aws_db_instance.name.address} -u admin -p'Edwin12345' dev < /tmp/init.sql",
      "MYSQL_STATUS=$?",

      # 5. Check if the execution failed and handle error cleanly
      "if [ $MYSQL_STATUS -ne 0 ]; then",
      "  echo '❌ ERROR: MySQL script execution failed. Check credentials or SQL syntax above.'",
      "  exit $MYSQL_STATUS",
      "else",
      "  echo '✅ SUCCESS: Database tables imported successfully!'",
      "fi",

      "set -e"
    ]
  }


  triggers = {
    always_run = timestamp()
  }
}
