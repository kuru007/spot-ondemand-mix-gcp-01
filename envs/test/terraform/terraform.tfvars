project_id          = "gke-mixing-spot-ondemand-poc"
region              = "us-central1"
zone                = "us-central1-a"
env                 = "test"

subnet_cidr         = "10.0.0.0/16"
pods_cidr           = "10.1.0.0/16"
services_cidr       = "10.2.0.0/20"

ondemand_machine_type = "e2-medium"
ondemand_node_count   = 1

spot_machine_type     = "e2-micro"
spot_node_count       = 1
