output "tgw_ingress_subnet" {
    value = aws_subnet.tgw_ingress.*.id
}

output "tgw_ingress_route_table" {
    value = aws_route_table.tgw_ingress.*.id
}

output "datapath_route_table" {
    value = aws_route_table.datapath.*.id
}
