# Generate SSH key pair
resource "tls_private_key" "radius" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "radius" {
  key_name   = var.instance_name
  public_key = tls_private_key.radius.public_key_openssh
}

resource "local_file" "radius_private_key" {
  content         = tls_private_key.radius.private_key_pem
  filename        = "${path.module}/${var.instance_name}.pem"
  file_permission = "0600"
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Security group with required ports
resource "aws_security_group" "radius_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow required ports"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Get available subnets in default VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ubuntu_owner_id]

  filter {
    name   = "name"
    values = [var.ubuntu_version_filter]
  }
}

# Create EC2 instance
resource "aws_instance" "radius" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = element(data.aws_subnets.default_vpc_subnets.ids, 0)
  vpc_security_group_ids = [aws_security_group.radius_sg.id]
  key_name               = aws_key_pair.radius.key_name

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = var.instance_name
  }

  # Upload Docker Compose YAML
  provisioner "file" {
    source      = "${path.module}/../compose3.yml"
    destination = "/tmp/compose3.yml"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.radius_private_key.filename)
      host        = self.public_ip
    }
  }

  # Upload .env file
  provisioner "file" {
    source      = "${path.module}/../.env"
    destination = "/tmp/.env"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.radius_private_key.filename)
      host        = self.public_ip
    }
  }

  # Upload dependency.sh
  provisioner "file" {
    source      = "${path.module}/dependency.sh"
    destination = "/tmp/dependency.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.radius_private_key.filename)
      host        = self.public_ip
    }
  }

  # Execute dependency.sh remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/dependency.sh",
      "sudo /tmp/dependency.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.radius_private_key.filename)
      host        = self.public_ip
    }
  }
}
