# vpc
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_parameters.cidr_block
    assign_generated_ipv6_cidr_block = var.vpc_parameters.assign_ipv6
    enable_dns_hostnames = var.vpc_parameters.enable_dns_hostnames
    enable_dns_support = var.vpc_parameters.enable_dns_support
    tags = merge(
        var.common_tags,
        tomap({Name = "${var.common_tags.project}-${var.common_tags.environment}-${var.vpc_parameters.name}-vpc"})
    )
}

# subnets

resource "aws_subnet" "public_subnets" {
    count = var.vpc_parameters.subnets_per_type
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index)
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    map_public_ip_on_launch = true
    ipv6_cidr_block = aws_vpc.vpc.assign_generated_ipv6_cidr_block ? cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 4, count.index) : null
    assign_ipv6_address_on_creation = aws_vpc.vpc.assign_generated_ipv6_cidr_block ? true : false

    tags = merge(
        var.common_tags,
        tomap({Name = "${var.common_tags.project}-${var.common_tags.environment}-${var.vpc_parameters.name}-public-subnet-${data.aws_availability_zones.azs.names[count.index]}"})
    )
}

resource "aws_subnet" "private_subnets" {
    count = var.vpc_parameters.subnets_per_type
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index + 2)
    availability_zone = data.aws_availability_zones.azs.names[count.index]

    tags = merge(
        var.common_tags,
        tomap({Name = "${var.common_tags.project}-${var.common_tags.environment}-${var.vpc_parameters.name}-private-subnet-${data.aws_availability_zones.azs.names[count.index]}"})
    )
}

# IGW

resource "aws_internet_gateway" "igw" {
    tags = merge(
        var.common_tags,
        tomap({Name = "${var.common_tags.project}-${var.common_tags.environment}-${var.vpc_parameters.name}-igw"})
    )
}

resource "aws_internet_gateway_attachment" "igw_attachment" {
    vpc_id = aws_vpc.vpc.id
    internet_gateway_id = aws_internet_gateway.igw.id
}

# NAT
# uncomment the below if you want the NAT gateway

/*resource "aws_nat_gateway" "nat" {
    count = var.vpc_parameters.subnets_per_type
    connectivity_type = "public"
    subnet_id = aws_subnet.public_subnets[count.index].id
}*/

# Route Table
# Public Route Table
resource "aws_route_table" "rt_public" {
    vpc_id = aws_vpc.vpc.id
    tags = merge(
        var.common_tags,
        tomap({Name = "${var.common_tags.project}-${var.common_tags.environment}-${var.vpc_parameters.name}-rt-public"})
    )
}

# Private Route Table
resource "aws_route_table" "rt_private" {
    count = var.vpc_parameters.subnets_per_type
    vpc_id = aws_vpc.vpc.id
    tags = merge(
        var.common_tags,
        tomap({Name = "${var.common_tags.project}-${var.common_tags.environment}-${var.vpc_parameters.name}-rt-private-${count.index}"})
    )
}

# Public Route Table Association
resource "aws_route_table_association" "rt_public_association" {
    count = var.vpc_parameters.subnets_per_type
    route_table_id = aws_route_table.rt_public.id
    subnet_id = aws_subnet.public_subnets[count.index].id
}

# Private Route Table Association
resource "aws_route_table_association" "rt_private_association" {
    count = var.vpc_parameters.subnets_per_type
    route_table_id = aws_route_table.rt_private[count.index].id
    subnet_id = aws_subnet.private_subnets[count.index].id
}

# Routes
# uncomment the below if you want routes for private route table

resource "aws_route" "rt_public_route" {
    count = aws_vpc.vpc.assign_generated_ipv6_cidr_block ? 2 : 1 # 2 routes - one for public_ipv4 - one for public_ipv6
    route_table_id = aws_route_table.rt_public.id
    gateway_id = aws_internet_gateway.igw.id
    destination_cidr_block = count.index == 0 ? "0.0.0.0/0" : null
    destination_ipv6_cidr_block = count.index != 0 ? "::/0" : null
}

/*resource "aws_route" "rt_private_route" {
    count = length(aws_route_table.rt_private)
    route_table_id = aws_route_table.rt_private[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
}*/