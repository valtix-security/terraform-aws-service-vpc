# terraform-service-vpc

Create a Valtix Service VPC to deploy Valtix Gateway in manual mode. The terraform creates 3 subnets in each AZ

* datapath
* mgmt
* tgw_ingress

Use the tgw_ingress subnet to attach to the Transit Gateway.