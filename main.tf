provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.aws_region
}

resource "aws_vpc" "valtix_svpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name   = "${var.prefix}_vpc"
    prefix = var.prefix
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.valtix_svpc.id

  tags = {
    Name   = "${var.prefix}_igw"
    prefix = var.prefix
  }
}

# add tags to the default route table
resource "aws_default_route_table" "valtix_svpc_default_rtable" {
  default_route_table_id = aws_vpc.valtix_svpc.default_route_table_id

  tags = {
    Name   = "${var.prefix}_default"
    prefix = var.prefix
  }
}

resource "aws_subnet" "tgw_ingress" {
  vpc_id            = aws_vpc.valtix_svpc.id
  count             = length(var.zones)
  cidr_block        = cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, count.index * 3)
  availability_zone = var.zones[count.index]

  tags = {
    Name   = "${var.prefix}_${var.zones[count.index]}_tgw_ingress"
    prefix = var.prefix
  }
}

resource "aws_subnet" "datapath" {
  vpc_id            = aws_vpc.valtix_svpc.id
  count             = length(var.zones)
  cidr_block        = cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, (count.index * 3) + 1)
  availability_zone = var.zones[count.index]

  tags = {
    Name   = "${var.prefix}_${var.zones[count.index]}_datapath"
    prefix = var.prefix
  }
}

resource "aws_subnet" "mgmt" {
  vpc_id            = aws_vpc.valtix_svpc.id
  count             = length(var.zones)
  cidr_block        = cidrsubnet(var.vpc_cidr, var.vpc_subnet_bits, (count.index * 3) + 2)
  availability_zone = var.zones[count.index]

  tags = {
    Name   = "${var.prefix}_${var.zones[count.index]}_mgmt"
    prefix = var.prefix
  }
}

resource "aws_route_table" "tgw_ingress" {
  vpc_id = aws_vpc.valtix_svpc.id
  count  = length(var.zones)

  tags = {
    Name   = "${var.prefix}_${var.zones[count.index]}_tgw_ingress"
    prefix = var.prefix
  }
}

resource "aws_route_table" "mgmt" {
  vpc_id = aws_vpc.valtix_svpc.id
  count  = length(var.zones)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name   = "${var.prefix}_${var.zones[count.index]}_mgmt"
    prefix = var.prefix
  }
}

resource "aws_route_table" "datapath" {
  vpc_id = aws_vpc.valtix_svpc.id
  count  = length(var.zones)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name   = "${var.prefix}_${var.zones[count.index]}_datapath"
    prefix = var.prefix
  }
}

resource "aws_route_table_association" "tgw_ingress" {
  count          = length(var.zones)
  subnet_id      = aws_subnet.tgw_ingress[count.index].id
  route_table_id = aws_route_table.tgw_ingress[count.index].id
}

resource "aws_route_table_association" "mgmt" {
  count          = length(var.zones)
  subnet_id      = aws_subnet.mgmt[count.index].id
  route_table_id = aws_route_table.mgmt[count.index].id
}

resource "aws_route_table_association" "datapath" {
  count          = length(var.zones)
  subnet_id      = aws_subnet.datapath[count.index].id
  route_table_id = aws_route_table.datapath[count.index].id
}

resource "aws_security_group" "datapath" {
  name   = "${var.prefix}_datapath"
  vpc_id = aws_vpc.valtix_svpc.id

  ingress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 65534
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "${var.prefix}_datapath"
    prefix = var.prefix
  }
}

resource "aws_security_group" "mgmt" {
  name   = "${var.prefix}_mgmt"
  vpc_id = aws_vpc.valtix_svpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "${var.prefix}_mgmt"
    prefix = var.prefix
  }
}