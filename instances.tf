//############################ Create NSG ##################

resource "azurerm_network_security_group" "fmg_nsg" {
  name                          = "${var.project}-${var.TAG}-fmg-nsg"
  location                      = data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name           = var.ResourceGroup
}
  
resource "azurerm_network_security_rule" "fmg_nsg_rule_egress" {
  name                        = "AllOutbound"
  resource_group_name           = var.ResourceGroup
  network_security_group_name = azurerm_network_security_group.fmg_nsg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}


resource "azurerm_network_security_rule" "fmg_nsg_rule_ingress_1" {
  name                        = "TCP_ALL"
  resource_group_name           = var.ResourceGroup
  network_security_group_name = azurerm_network_security_group.fmg_nsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}

resource "azurerm_network_security_rule" "fmg_nsg_rule_ingress_2" {
  name                        = "UDP_ALL"
  resource_group_name           = var.ResourceGroup
  network_security_group_name = azurerm_network_security_group.fmg_nsg.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
}



//##############################################


data "azurerm_virtual_network" "vnettodeployinstances" {
  name                = var.VNET
  resource_group_name = var.ResourceGroup
}

data "azurerm_subnet" "subnettodeployfmg1" {
  count = length(var.fmg1subnets)
  name                 = var.fmg1subnets [count.index]
  virtual_network_name = var.VNET
  resource_group_name  = var.ResourceGroup
}

data "azurerm_subnet" "subnettodeployfmg2" {
  count = length(var.fmg2subnets)
  name                 = var.fmg2subnets [count.index]
  virtual_network_name = var.VNET
  resource_group_name  = var.ResourceGroup
}

data "azurerm_subnet" "subnettodeployfaz1" {
  count = length(var.faz1subnets)
  name                 = var.faz1subnets [count.index]
  virtual_network_name = var.VNET
  resource_group_name  = var.ResourceGroup
}

data "azurerm_subnet" "subnettodeployfaz2" {
  count = length(var.faz2subnets)
  name                 = var.faz2subnets [count.index]
  virtual_network_name = var.VNET
  resource_group_name  = var.ResourceGroup
}

//############################ Create FMG ##################

resource "azurerm_network_interface" "fmg1nics" {
  count = length(var.fmg1ip)
  name                          = "${var.project}-${var.TAG}-fmg1-port${count.index+1}"
  location                      = data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name           = var.ResourceGroup
  enable_ip_forwarding           = false
  enable_accelerated_networking   = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(data.azurerm_subnet.subnettodeployfmg1.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fmg1ip[count.index]
  }

    lifecycle {
          ignore_changes = all
    }
}

resource "azurerm_network_interface_security_group_association" "fmg1nics_nsg" {
  count = length(var.fmg1ip)
  network_interface_id      = element(azurerm_network_interface.fmg1nics.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.fmg_nsg.id
}



resource "azurerm_network_interface" "fmg2nics" {
  count = length(var.fmg2ip)
  name                          = "${var.project}-${var.TAG}-fmg2-port${count.index+1}"
  location                      = data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name           = var.ResourceGroup
  enable_ip_forwarding           = false
  enable_accelerated_networking   = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(data.azurerm_subnet.subnettodeployfmg2.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.fmg2ip[count.index]
  }

    lifecycle {
          ignore_changes = all
    }
}


resource "azurerm_network_interface_security_group_association" "fmg2nics_nsg" {
  count = length(var.fmg2ip)
  network_interface_id      = element(azurerm_network_interface.fmg2nics.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.fmg_nsg.id
}




//############################ FMG VM ##################

data "template_file" "fmg1_customdata" {
  template = file ("./assets/fmg.tpl")
  vars = {
    fmg_id              = "mre-az-nocsoc-useast-fmg1"
    fmg_license_file    = "./assets/fmg1.lic"

    Port1IP             = var.fmg1ip[0]
    public_subnet_mask  = cidrnetmask(element(data.azurerm_subnet.subnettodeployfmg1.*.address_prefix , 0))

    gateway             = cidrhost(element(data.azurerm_subnet.subnettodeployfmg1.*.address_prefix , 0), 1)

  }
}

data "template_file" "fmg2_customdata" {
  template = file ("./assets/fmg.tpl")
  vars = {
    fmg_id              = "mre-az-nocsoc-useast-fmg2"
    fmg_license_file    = "./assets/fmg2.lic"

    Port1IP             = var.fmg2ip[0]
    public_subnet_mask  = cidrnetmask(element(data.azurerm_subnet.subnettodeployfmg2.*.address_prefix , 0))

    gateway             = cidrhost(element(data.azurerm_subnet.subnettodeployfmg2.*.address_prefix , 0), 1)

  }
}

resource "azurerm_virtual_machine" "fmg1" {
  name                         = "mre-az-nocsoc-useast-fmg1"
  location                     =  data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name           = var.ResourceGroup
  network_interface_ids        = [azurerm_network_interface.fmg1nics.0.id ]
  primary_network_interface_id = element (azurerm_network_interface.fmg1nics.*.id , 0)
  vm_size                      = var.fmg_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = var.FMG_PRODUCT
    sku       = var.FMG_IMAGE_SKU
    version   = var.FMG_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = var.FMG_PRODUCT
    name      = var.FMG_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_fmg1_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_fmg1_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "80"
  }
  os_profile {
    computer_name  = "mre-az-nocsoc-useast-fmg1"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fmg1_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://facserial.blob.core.windows.net/"
  } 

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

  zones = [1]

} 


resource "azurerm_virtual_machine" "fmg2" {
  name                         = "mre-az-nocsoc-useast-fmg2"
  location                     =  data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name           = var.ResourceGroup
  network_interface_ids        = [azurerm_network_interface.fmg2nics.0.id ]
  primary_network_interface_id = element (azurerm_network_interface.fmg2nics.*.id , 0)
  vm_size                      = var.fmg_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = var.FMG_PRODUCT
    sku       = var.FMG_IMAGE_SKU
    version   = var.FMG_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = var.FMG_PRODUCT
    name      = var.FMG_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_fmg2_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_fmg2_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "80"
  }
  os_profile {
    computer_name  = "mre-az-nocsoc-useast-fmg2"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fmg2_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://facserial.blob.core.windows.net/"
  } 

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

  zones = [2]

} 


//############################ FAZ VM ##################

resource "azurerm_network_interface" "faz1nics" {
  count = length(var.faz1ip)
  name                            = "${var.project}-${var.TAG}-faz1-port${count.index+1}"
  location                        = data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name             = var.ResourceGroup
  enable_ip_forwarding            = false
  enable_accelerated_networking   = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(data.azurerm_subnet.subnettodeployfaz1.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.faz1ip[count.index]
  }

    lifecycle {
          ignore_changes = all
    }
}

resource "azurerm_network_interface" "faz2nics" {
  count = length(var.faz2ip)
  name                            = "${var.project}-${var.TAG}-faz2-port${count.index+1}"
  location                        = data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name             = var.ResourceGroup
  enable_ip_forwarding            = false
  enable_accelerated_networking   = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = element(data.azurerm_subnet.subnettodeployfaz2.*.id , count.index)
    private_ip_address_allocation           = "static"
    private_ip_address                      = var.faz2ip[count.index]
  }

    lifecycle {
          ignore_changes = all
    }
}




data "template_file" "faz1_customdata" {
  template = file ("./assets/faz.tpl")
    vars = {
      hostname              = "mre-az-nocsoc-useast-faz1"
      vm_license_file    = "./assets/faz1.lic"

      Port1IP             = var.faz1ip[0]
      public_subnet_mask  = cidrnetmask(element(data.azurerm_subnet.subnettodeployfaz1.*.address_prefix , 0))

      gateway             = cidrhost(element(data.azurerm_subnet.subnettodeployfaz1.*.address_prefix , 0), 1)
      vm_type             = "faz"

    }
}

data "template_file" "faz2_customdata" {
  template = file ("./assets/faz.tpl")
  vars = {
    hostname              = "mre-az-nocsoc-useast-faz2"
    vm_license_file    = "./assets/faz2.lic"

    Port1IP             = var.faz2ip[0]
    public_subnet_mask  = cidrnetmask(element(data.azurerm_subnet.subnettodeployfaz2.*.address_prefix , 0))

    gateway             = cidrhost(element(data.azurerm_subnet.subnettodeployfaz2.*.address_prefix , 0), 1)

    vm_type             = "faz"

  }
}

resource "azurerm_virtual_machine" "faz1" {
  name                         = "mre-az-nocsoc-useast-faz1"
  location                     =  data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name           = var.ResourceGroup
  network_interface_ids        = [azurerm_network_interface.faz1nics.0.id ]
  primary_network_interface_id = element (azurerm_network_interface.faz1nics.*.id , 0)
  vm_size                      = var.faz_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = var.FAZ_PRODUCT
    sku       = var.FAZ_IMAGE_SKU
    version   = var.FAZ_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = var.FAZ_PRODUCT
    name      = var.FAZ_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_faz1_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_faz1_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "500"
  }
  os_profile {
    computer_name  = "mre-az-nocsoc-useast-faz1"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.faz1_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://facserial.blob.core.windows.net/"
  } 

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

  zones = [1]

} 


resource "azurerm_virtual_machine" "faz2" {
  name                         = "mre-az-nocsoc-useast-faz2"
  location                     =  data.azurerm_virtual_network.vnettodeployinstances.location
  resource_group_name           = var.ResourceGroup
  network_interface_ids        = [azurerm_network_interface.faz2nics.0.id ]
  primary_network_interface_id = element (azurerm_network_interface.faz2nics.*.id , 0)
  vm_size                      = var.faz_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = var.FAZ_PRODUCT
    sku       = var.FAZ_IMAGE_SKU
    version   = var.FAZ_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = var.FAZ_PRODUCT
    name      = var.FAZ_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.project}_${var.TAG}_faz2_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.project}_${var.TAG}_faz2_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "500"
  }
  os_profile {
    computer_name  = "mre-az-nocsoc-useast-faz2"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.faz2_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://facserial.blob.core.windows.net/"
  } 

  tags = {
    Project = "${var.project}"
    Role = "FTNT"
  }

  zones = [2]

} 



