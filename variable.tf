variable "TAG" {
    description = "Customer Prefix TAG of the created ressources"
    type= string
} 

variable "project" {
    description = "project Prefix TAG of the created ressources"
    type= string
}

variable "azsubscriptionid"{
description = "Azure Subscription id"
}

//--------------------------------

variable "ResourceGroup"{
description = "Resource Group where resources will be deployed"
}

variable "VNET"{
description = "VNET name resources will be deployed"
}



//--------------------------------

variable "fmg_vmsize" {
  description = "FMG VM size"
}

variable "faz_vmsize" {
  description = "FAZ VM size"
}

//-----------------------------
variable "fmg1ip" {
    description = "FMG nic IP"
    type = list(string)

}
variable "fmg2ip" {
    description = "FMG nic IP"
    type = list(string)

}
variable "fmg1subnets" {
    description = "FMG Subnets"
    type = list(string)

}
variable "fmg2subnets" {
    description = "FMG Subnets"
    type = list(string)

}




//-----------------------------

variable "faz1ip" {
    description = "FAZ nic IP"
    type = list(string)

}
variable "faz2ip" {
    description = "FAZ nic IP"
    type = list(string)

}
variable "faz1subnets" {
    description = "FAZ Subnets"
    type = list(string)

}
variable "faz2subnets" {
    description = "FAZ Subnets"
    type = list(string)

}
//------------------------------

variable "username" {
}
variable "password" {
}

//--------------------------------

variable "FMG_IMAGE_SKU" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_20190624') or byol (Bring your own license 'fortinet_fg-vm')"
}
variable "FMG_VERSION" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
}
variable "FMG_PRODUCT" {
  description = "FAZ Product code"
}


variable "FAZ_IMAGE_SKU" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_20190624') or byol (Bring your own license 'fortinet_fg-vm')"
}
variable "FAZ_VERSION" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
}
variable "FAZ_PRODUCT" {
  description = "FAZ Product code"
}






