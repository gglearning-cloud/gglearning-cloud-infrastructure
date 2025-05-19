# 

module "core" {
    for_each = var.vpc_parameters
    source = "../../modules/core"
    common_tags = var.common_tags
    vpc_parameters = each.value
}