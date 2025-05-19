# VPC Variables

variable "vpc_parameters" {
    description = "VPC parameters. Please provide the input in the following format"
    /* vpc_parameters = {
            vpc_name_1 = {
                name = "appname"
                cidr_block = "10.0.0.0/25" #example
                assign_ipv6 = true/false
                enable_dns_hostnames = true/false
                enable_dns_support = true/false
            }
            vpc_name_2 = {...}
            ....
        } 
    */
}

# Common Tags

variable "common_tags" {
    description = "Provide all the common tags for the resources. Ex: live, costcenter, environment, project, owner, email.."
}