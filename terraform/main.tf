terraform {
  # Tested with Terraform 0.14.x.
  required_version = ">= 0.12.26"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "all" {}

# CREATE AUTO SCALING GROUP

resource "aws_autoscaling_group" "retail" {
  launch_configuration = aws_launch_configuration.retail.id
  availability_zones   = data.aws_availability_zones.all.names

  min_size = 6
  max_size = 10

  load_balancers    = [aws_elb.retail.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-retail"
    propagate_at_launch = true
  }
}

# CREATE A LAUNCH CONFIGURATION 

resource "aws_launch_configuration" "retail" {
  # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type in us-east-1
  image_id        = "ami-042e8287309f5df03"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              curl -sSL https://get.docker.com | sh
              usermod -aG docker ubuntu
              curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose 
              docker pull tsivabe/retail_django:retail_dj_final
              docker run -p 8000:8000 --name retail1 tsivabe/retail_django:retail_dj_final gunicorn RetailCom.wsgi:application --bind 0.0.0.0:8000
              EOF

             ## echo "Hello, World" > index.html
             ## nohup busybox httpd -f -p "${var.server_port}" &

  # set create_before_destroy = true, before creating LC with Autoscaling  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html

  lifecycle {
    create_before_destroy = true
  }
}

# CREATE THE SECURITY GROUP 

resource "aws_security_group" "instance" {
  name = "terraform-retail-instance"

  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   # SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
   # Python web traffic
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    # Outbout traffic
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# CREATE ELB 

resource "aws_elb" "retail" {
  name               = "terraform-elb-retail"
  security_groups    = [aws_security_group.elb.id]
  availability_zones = data.aws_availability_zones.all.names

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

# CREATE A SECURITY GROUP FOR  ELB

resource "aws_security_group" "elb" {
  name = "terraform-retail-elb"

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound Python from anywhere
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound Postgres DB port anywhere
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
