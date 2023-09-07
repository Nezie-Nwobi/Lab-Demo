#Location
variable "location" {
  description = "Location of resources to be deployed"
  type        = string
  default     = "East US 2"
}

#Resource Group
variable "resource_group_name" {
  description = "Resource Group Name"
  type        = any
}


#VM Count Variable
variable "vm_count" {
  description = "Number of VMs to be created"
  type        = any
  default     = 2
}


#VM name prefix
variable "prefix" {
  description = "Name of VM"
  type        = any
}


#VM Username
variable "admin_username" {
  description = "Username of VM"
  type        = any
}

#VM password
variable "admin_password" {
  description = "Password for VM"
  type        = any
  sensitive   = true
}

#VM Size
variable "vm_size" {
  description = "Size of VM"
  default     = "Standard_D4s_v3"
}

#VNet Name
variable "virtual_network_name" {
  description = "Name of VNET"
  type        = any
}

#VNET Address Space
variable "vnet_address_space" {
  description = "Address Space of VNET"
  type        = list(any)
  default     = ["10.1.0.0/16"]
}

#Subnet Name
variable "subnet_name" {
  description = "Name of Subnet"
  type        = string
}


#Subnet Address Space
variable "subnet_address_space" {
  description = "Address Space of Subnet"
  type        = list(any)
  default     = ["10.1.0.0/24"]

}

#Storage Account Name
variable "storage_account_name" {
  description = "Name of Storage Account"
  type        = string
}

#Availability Zone
variable "zones" {
  description = "Avaialbility Zone for Resources"
  default     = "1"
}

#Image to Deploy
variable "os" {
  description = "OS image to deploy"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

#NSG Rule Priority number
variable "nsg_priority" {
  description = "NSG priority for NSG rules"
  type        = string
}