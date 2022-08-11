resource "aws_vpc" "valtix_svpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name   = "${var.prefix}"
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
