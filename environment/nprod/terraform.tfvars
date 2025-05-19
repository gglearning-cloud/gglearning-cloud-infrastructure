# common tags 
common_tags = {
    project = "gglearning"
    environment = "nprod"
    live = "no"
    costcenter = "CC0001"
    owner = "gglearning"
    email = "gglearning-cloud@gmail.com"
}

# VPC
vpc_parameters = {
    vpc_1 = {
        name = "app"
        cidr_block = "10.0.0.0/24"
        assign_ipv6 = true
        enable_dns_hostnames = true
        enable_dns_support = true
        subnets_per_type = 2 # Number of subnets in each type (public or private)
    }
}