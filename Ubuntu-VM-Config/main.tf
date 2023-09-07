#Terraform code to deploy Multiple Ubuntu Linux VMs on Azure


#Reference Existing Resource Group
data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

/*
#You can also add the resource group block if you want to create a new Resource Group.
resource "azurerm_resource_group" "example" {
  name = var.resource_group_name
  location = var.location

  tags = {
    Team = "IT Dept"
    Environment = "Demo"
  }
}
*/


/*
#Create a Resource Group Lock
resource "azurerm_management_lock" "example" {
  name       = "Terraform-RG-Lock"
  scope      = azurerm_resource_group.example.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group cannot be deleted"
}
*/


#Create Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.example.name
  address_space       = var.vnet_address_space
}


#Create Subnet
resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.subnet_address_space
}


#Create Public IP Address
resource "azurerm_public_ip" "example" {
  count               = var.vm_count
  name                = "${var.prefix}-IP${count.index + 1}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.example.name
  allocation_method   = "Static"
  zones               = [var.zones]
  sku                 = "Standard"
}


#Create Network Interface
resource "azurerm_network_interface" "example" {
  count               = var.vm_count
  name                = "${var.prefix}-NIC${count.index + 1}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "${var.prefix}-NIC-Config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example[count.index].id
  }
}


#Create Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = "${var.prefix}-NSG"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.example.name
}


#Create NSG Rules
resource "azurerm_network_security_rule" "example" {
  name                        = "SSH-RDP"
  priority                    = var.nsg_priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}


#NSG Association with Subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}


#Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = data.azurerm_resource_group.example.name
  }

  byte_length = 2
}


#Create storage account for boot diagnostics
resource "azurerm_storage_account" "example" {
  name                     = "${var.storage_account_name}${random_id.random_id.hex}"
  location                 = var.location
  resource_group_name      = data.azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}


#Create Virtual Machine
resource "azurerm_virtual_machine" "example" {
  count                         = var.vm_count
  name                          = "${var.prefix}${count.index + 1}"
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.example.name
  vm_size                       = var.vm_size
  network_interface_ids         = [azurerm_network_interface.example[count.index].id]
  delete_os_disk_on_termination = true


  storage_os_disk {
    name              = "${var.prefix}-OSDisk${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    disk_size_gb      = "35"
  }


  storage_image_reference {
    publisher = var.os.publisher
    offer     = var.os.offer
    sku       = var.os.sku
    version   = var.os.version
  }


  #zones = [var.zones]  #To deploy VM into availability zone.

  os_profile {
    computer_name  = "${var.prefix}${count.index + 1}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      #Path to the directory where the SSH Key will be stored for the user created during VM Creation
      path = "/home/${var.admin_username}/.ssh/authorized_keys"

      #Location of Public Key in the local system when the SSH Key was generated. In this Lab, the public SSH key is named VMSSHpublickey.pub 
      key_data = file("${path.module}/VMSSHpublickey.pub")
    }
  }

#Tag for VMs
  /*
  tags = {
    environment = "Terraform-Demo"
  }
  */

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.example.primary_blob_endpoint
  }
}


#VM Auto Shutdown
resource "azurerm_dev_test_global_vm_shutdown_schedule" "example" {
  count                 = var.vm_count
  virtual_machine_id    = azurerm_virtual_machine.example[count.index].id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "0015"
  timezone              = "W. Central Africa Standard Time"

  notification_settings {
    enabled = false
  }
}


#IP address collection for Ansible Inventory
output "public_ip_addresses" {
    value       = [for vm in azurerm_public_ip.example : vm.ip_address]
}


#If VM is deployed to a Zone, the VM public IP address must also be assigned to the same zone.