###### Global Variables ######
variable "username" { }
variable "password" { }
variable "location" {
    default = "East US"
}
variable "time_zone" {
    default = "America/New_York"
}

###### Virtual Network ######
variable "vnet" {
    default = {
        name = "Dev VNET"
        address_space = "10.0.0.0/8"
        app_sub_name = "AppSubnet"
        app_sub_address = "10.0.0.0/11"
        db_sub_name = "DBSubnet"
        db_sub_address = "10.32.0.0/11"
    }
}

###### Storage Account ######
variable "storage_svc" {
    default = {
        name = "tfstorageyzguy"
        description = "Yzguy Storage Account made by Terraform"
        account_type = "Standard_LRS"
    }
}

###### Cloud Service ######
variable "cloudsvc" {
    default = {
        name = "yzguy-iisvm-labs2"
        ephemeral_contents = "true" 
        descrption = "Hosted Service created by Terraform."
    }
}

###### Virtual Machine ######
variable "iisvm1" {
    default = {
        name = "iisvm1"
        image = "Windows Server 2012 Datacenter, July 2015"
        size = "Basic_A1"
    }
}

variable "iisvm2" {
    default = {
        name = "iisvm2"
        image = "Windows Server 2012 Datacenter, July 2015"
        size = "Basic_A1"
    }
}
