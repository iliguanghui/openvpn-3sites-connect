# 创建三个vpc
resource "aws_vpc" "site_a" {
  cidr_block = "192.168.10.0/24"
  tags       = {
    Name = "siteA"
  }
}

resource "aws_vpc" "site_b" {
  cidr_block = "192.168.20.0/24"
  tags       = {
    Name = "siteB"
  }
}

resource "aws_vpc" "site_c" {
  cidr_block = "192.168.30.0/24"
  tags       = {
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
  tags = {
    Name = "siteA"
  }
}

resource "aws_subnet" "site_b" {
  vpc_id                  = aws_vpc.site_b.id
  cidr_block              = "192.168.20.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "siteB"
  }
}

resource "aws_subnet" "site_c" {
  vpc_id                  = aws_vpc.site_c.id
  cidr_block              = "192.168.30.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "siteC"
  }
}

# 为每个子网单独分配路由表
resource "aws_route_table" "site_a" {
  vpc_id = aws_vpc.site_a.id
  tags = {
    Name = "siteA"
  }
}

resource "aws_route_table" "site_b" {
  vpc_id = aws_vpc.site_b.id
  tags = {
    Name = "siteB"
  }
}

resource "aws_route_table" "site_c" {
  vpc_id = aws_vpc.site_c.id
  tags = {
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
  tags = {
    Name = "openSG"
  }
}

resource "aws_security_group" "site_b_open_sg" {
  name        = "openSG"
  description = "open to the world"
  vpc_id      = aws_vpc.site_b.id
  tags = {
    Name = "openSG"
  }
}

resource "aws_security_group" "site_c_open_sg" {
  name        = "openSG"
  description = "open to the world"
  vpc_id      = aws_vpc.site_c.id
  tags = {
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
