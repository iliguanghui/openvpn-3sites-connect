# 创建三个vpc
resource "aws_vpc" "site_a" {
  cidr_block           = "192.168.10.0/24"
  enable_dns_hostnames = true
  tags                 = {
    Name = "siteA"
  }
}

resource "aws_vpc" "site_b" {
  cidr_block           = "192.168.20.0/24"
  enable_dns_hostnames = true
  tags                 = {
    Name = "siteB"
  }
}

resource "aws_vpc" "site_c" {
  cidr_block           = "192.168.30.0/24"
  enable_dns_hostnames = true
  tags                 = {
    Name = "siteC"
  }
}

# 为每个vpc分配一个IGW
resource "aws_internet_gateway" "site_a" {
  tags = {
    Name = "siteA"
  }
}

resource "aws_internet_gateway" "site_b" {
  tags = {
    Name = "siteB"
  }
}

resource "aws_internet_gateway" "site_c" {
  tags = {
    Name = "siteC"
  }
}

resource "aws_internet_gateway_attachment" "site_a" {
  internet_gateway_id = aws_internet_gateway.site_a.id
  vpc_id              = aws_vpc.site_a.id
}

resource "aws_internet_gateway_attachment" "site_b" {
  internet_gateway_id = aws_internet_gateway.site_b.id
  vpc_id              = aws_vpc.site_b.id
}

resource "aws_internet_gateway_attachment" "site_c" {
  internet_gateway_id = aws_internet_gateway.site_c.id
  vpc_id              = aws_vpc.site_c.id
}

# 创建三个子网
resource "aws_subnet" "site_a" {
  vpc_id                  = aws_vpc.site_a.id
  cidr_block              = "192.168.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
  tags                    = {
    Name = "siteA"
  }
}

resource "aws_subnet" "site_b" {
  vpc_id                  = aws_vpc.site_b.id
  cidr_block              = "192.168.20.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
  tags                    = {
    Name = "siteB"
  }
}

resource "aws_subnet" "site_c" {
  vpc_id                  = aws_vpc.site_c.id
  cidr_block              = "192.168.30.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
  tags                    = {
    Name = "siteC"
  }
}

# 为每个子网单独分配路由表
resource "aws_route_table" "site_a" {
  vpc_id = aws_vpc.site_a.id
  tags   = {
    Name = "siteA"
  }
}

resource "aws_route_table" "site_b" {
  vpc_id = aws_vpc.site_b.id
  tags   = {
    Name = "siteB"
  }
}

resource "aws_route_table" "site_c" {
  vpc_id = aws_vpc.site_c.id
  tags   = {
    Name = "siteC"
  }
}

resource "aws_route" "site_a_gw" {
  route_table_id         = aws_route_table.site_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.site_a.id
  depends_on             = [aws_internet_gateway.site_a]
}

resource "aws_route" "site_b_gw" {
  route_table_id         = aws_route_table.site_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.site_b.id
  depends_on             = [aws_internet_gateway.site_b]
}

resource "aws_route" "site_c_gw" {
  route_table_id         = aws_route_table.site_c.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.site_c.id
  depends_on             = [aws_internet_gateway.site_c]
}

resource "aws_route_table_association" "site_a" {
  subnet_id      = aws_subnet.site_a.id
  route_table_id = aws_route_table.site_a.id
}

resource "aws_route_table_association" "site_b" {
  subnet_id      = aws_subnet.site_b.id
  route_table_id = aws_route_table.site_b.id
}

resource "aws_route_table_association" "site_c" {
  subnet_id      = aws_subnet.site_c.id
  route_table_id = aws_route_table.site_c.id
}

resource "aws_security_group" "site_a_open_sg" {
  name        = "openSG"
  description = "open to the world"
  vpc_id      = aws_vpc.site_a.id
  tags        = {
    Name = "openSG"
  }
}

resource "aws_security_group" "site_b_open_sg" {
  name        = "openSG"
  description = "open to the world"
  vpc_id      = aws_vpc.site_b.id
  tags        = {
    Name = "openSG"
  }
}

resource "aws_security_group" "site_c_open_sg" {
  name        = "openSG"
  description = "open to the world"
  vpc_id      = aws_vpc.site_c.id
  tags        = {
    Name = "openSG"
  }
}

resource "aws_vpc_security_group_egress_rule" "site_a_open_sg" {
  security_group_id = aws_security_group.site_a_open_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "site_b_open_sg" {
  security_group_id = aws_security_group.site_b_open_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "site_c_open_sg" {
  security_group_id = aws_security_group.site_c_open_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "site_a_open_sg" {
  security_group_id = aws_security_group.site_a_open_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "site_b_open_sg" {
  security_group_id = aws_security_group.site_b_open_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "site_c_open_sg" {
  security_group_id = aws_security_group.site_c_open_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "work_mac_pro" {
  key_name = "work-mac-pro"
}

resource "aws_instance" "vpn1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.site_a.id
  iam_instance_profile   = "admin"
  source_dest_check      = false
  vpc_security_group_ids = [
    aws_security_group.site_a_open_sg.id
  ]
  key_name   = data.aws_key_pair.work_mac_pro.key_name
  private_ip = "192.168.10.4"
  credit_specification {
    cpu_credits = "unlimited"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
    }
  }
  private_dns_name_options {
    hostname_type = "resource-name"
  }
  user_data = "#!/bin/bash\nhostnamectl set-hostname vpn1\n"
  tags      = {
    Name = "vpn1"
  }
}

resource "aws_instance" "vpn2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.site_b.id
  iam_instance_profile   = "admin"
  source_dest_check      = false
  vpc_security_group_ids = [
    aws_security_group.site_b_open_sg.id
  ]
  key_name   = data.aws_key_pair.work_mac_pro.key_name
  private_ip = "192.168.20.4"
  credit_specification {
    cpu_credits = "unlimited"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
    }
  }
  private_dns_name_options {
    hostname_type = "resource-name"
  }
  user_data = "#!/bin/bash\nhostnamectl set-hostname vpn2\n"
  tags      = {
    Name = "vpn2"
  }
}

resource "aws_instance" "vpn3" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.site_c.id
  iam_instance_profile   = "admin"
  source_dest_check      = false
  vpc_security_group_ids = [
    aws_security_group.site_c_open_sg.id
  ]
  key_name   = data.aws_key_pair.work_mac_pro.key_name
  private_ip = "192.168.30.4"
  credit_specification {
    cpu_credits = "unlimited"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
    }
  }
  private_dns_name_options {
    hostname_type = "resource-name"
  }
  user_data = "#!/bin/bash\nhostnamectl set-hostname vpn3\n"
  tags      = {
    Name = "vpn3"
  }
}

data "aws_route53_zone" "main" {
  name = "lgypro.com"
}

resource "aws_route53_record" "record1" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "openvpn1"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.vpn1.public_dns]
}

resource "aws_route53_record" "record2" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "openvpn2"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.vpn2.public_dns]
}

resource "aws_route53_record" "record3" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "openvpn3"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_instance.vpn3.public_dns]
}

# 添加到其他网段的路由
resource "aws_route" "site_a_to_site_b" {
  route_table_id         = aws_route_table.site_a.id
  destination_cidr_block = "192.168.20.0/24"
  network_interface_id = aws_instance.vpn1.primary_network_interface_id
}

resource "aws_route" "site_a_to_site_c" {
  route_table_id         = aws_route_table.site_a.id
  destination_cidr_block = "192.168.30.0/24"
  network_interface_id = aws_instance.vpn1.primary_network_interface_id
}

resource "aws_route" "site_b_to_site_a" {
  route_table_id         = aws_route_table.site_b.id
  destination_cidr_block = "192.168.10.0/24"
  network_interface_id = aws_instance.vpn2.primary_network_interface_id
}

resource "aws_route" "site_b_to_site_c" {
  route_table_id         = aws_route_table.site_b.id
  destination_cidr_block = "192.168.30.0/24"
  network_interface_id = aws_instance.vpn2.primary_network_interface_id
}

resource "aws_route" "site_c_to_site_a" {
  route_table_id         = aws_route_table.site_c.id
  destination_cidr_block = "192.168.10.0/24"
  network_interface_id = aws_instance.vpn3.primary_network_interface_id
}

resource "aws_route" "site_c_to_site_b" {
  route_table_id         = aws_route_table.site_c.id
  destination_cidr_block = "192.168.20.0/24"
  network_interface_id = aws_instance.vpn3.primary_network_interface_id
}

# 每个子网创建一台机器扮演应用服务器角色，验证网络连通性
resource "aws_instance" "app1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.site_a.id
  iam_instance_profile   = "admin"
  source_dest_check      = true
  vpc_security_group_ids = [
    aws_security_group.site_a_open_sg.id
  ]
  key_name   = data.aws_key_pair.work_mac_pro.key_name
  private_ip = "192.168.10.100"
  credit_specification {
    cpu_credits = "unlimited"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
    }
  }
  private_dns_name_options {
    hostname_type = "resource-name"
  }
  user_data = "#!/bin/bash\nhostnamectl set-hostname app1\n"
  tags      = {
    Name = "app1"
  }
}

resource "aws_instance" "app2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.site_b.id
  iam_instance_profile   = "admin"
  source_dest_check      = true
  vpc_security_group_ids = [
    aws_security_group.site_b_open_sg.id
  ]
  key_name   = data.aws_key_pair.work_mac_pro.key_name
  private_ip = "192.168.20.100"
  credit_specification {
    cpu_credits = "unlimited"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
    }
  }
  private_dns_name_options {
    hostname_type = "resource-name"
  }
  user_data = "#!/bin/bash\nhostnamectl set-hostname app2\n"
  tags      = {
    Name = "app2"
  }
}

resource "aws_instance" "app3" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.site_c.id
  iam_instance_profile   = "admin"
  source_dest_check      = true
  vpc_security_group_ids = [
    aws_security_group.site_c_open_sg.id
  ]
  key_name   = data.aws_key_pair.work_mac_pro.key_name
  private_ip = "192.168.30.100"
  credit_specification {
    cpu_credits = "unlimited"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
    }
  }
  private_dns_name_options {
    hostname_type = "resource-name"
  }
  user_data = "#!/bin/bash\nhostnamectl set-hostname app3\n"
  tags      = {
    Name = "app3"
  }
}
