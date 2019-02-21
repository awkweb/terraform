resource "aws_vpc" "instance" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.instance.id}"
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.instance.id}"
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "instance" {
  vpc_id = "${aws_vpc.instance.id}"
}

resource "aws_eip" "instance" {
  vpc        = true
  depends_on = ["aws_internet_gateway.instance"]
}

resource "aws_nat_gateway" "instance" {
  allocation_id = "${aws_eip.instance.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
  depends_on    = ["aws_internet_gateway.instance"]
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.instance.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.instance.id}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.instance.id}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.instance.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
