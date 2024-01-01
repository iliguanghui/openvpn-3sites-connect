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
