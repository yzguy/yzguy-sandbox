###### Provider Settings ######
provider "azure" {
    settings_file = "${file("credentials.publishsettings")}"
}

###### Virtual Network ######
resource "azure_virtual_network" "default" {
    name = "${var.vnet.name}"
    address_space = ["${var.vnet.address_space}"]
    location = "${var.location}"
    subnet {
        name = "${var.vnet.app_sub_name}"
        address_prefix = "${var.vnet.app_sub_address}"
    }
    subnet {
        name = "${var.vnet.db_sub_name}"
        address_prefix = "${var.vnet.db_sub_address}"
    }
}

###### Storage Account ######
resource "azure_storage_service" "tfstorageyzguy" {
    name = "${var.storage_svc.name}"
    location = "${var.location}"
    account_type = "${var.storage_svc.account_type}"
}

###### Cloud Service ######
resource "azure_hosted_service" "yzguy-iisvm-labs2" {
    name = "${var.cloudsvc.name}"
    location = "${var.location}"
    ephemeral_contents = "${var.cloudsvc.ephemeral_contents}"    
}

###### Virtual Machine ######
resource "azure_instance" "iisvm1" {
    name = "${var.iisvm1.name}"
    hosted_service_name = "${azure_hosted_service.yzguy-iisvm-labs2.id}"
    image = "${var.iisvm1.image}"
    size = "${var.iisvm1.size}"
    subnet = "${var.vnet.app_sub_name}"
    virtual_network = "${azure_virtual_network.default.name}"
    storage_service_name = "${azure_storage_service.tfstorageyzguy.id}"
    time_zone = "${var.time_zone}"
    location = "${var.location}"
    username = "${var.username}"
    password = "${var.password}"
    endpoint {
        name = "Remote Desktop"
        protocol = "tcp"
        public_port = 50001
        private_port = 3389
    }
    endpoint {
        name = "Powershell"
        protocol = "tcp"
        public_port = 5986
        private_port = 5986
    }
}

resource "azure_instance" "iisvm2" {
    name = "${var.iisvm2.name}"
    hosted_service_name = "${azure_hosted_service.yzguy-iisvm-labs2.id}"
    image = "${var.iisvm2.image}"
    size = "${var.iisvm2.size}"
    subnet = "${var.vnet.app_sub_name}"
    virtual_network = "${azure_virtual_network.default.id}"
    storage_service_name = "${azure_storage_service.tfstorageyzguy.name}"
    time_zone = "${var.time_zone}"
    location = "${var.location}"
    username = "${var.username}"
    password = "${var.password}"
    endpoint {
        name = "Remote Desktop"
        protocol = "tcp"
        public_port = 50002
        private_port = 3389
    }
    endpoint {
        name = "Powershell"
        protocol = "tcp"
        public_port = 5986
        private_port = 5986
    }
}
