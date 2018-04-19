variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
  default     = "GAB-TF"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "eastus"
}

variable "virtualMachineName" {
  description = "VM name referenced also in storage-related names."
  default     = "GAB-TF"
}

variable "virtualMachineSize" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_A1"
}

variable "adminUsername" {
  description = "Administrator user name."
  default     = "gab-admin"
}

variable "virtualNetworkName" {
  description = "The name for the virtual network."
  default     = "GAB-TF-vnet"
}

variable "networkInterfaceName" {
  description = "Name of network interface resource."
  default     = "gab-tf-nic"
}

variable "networkSecurityGroupName" {
  description = "Name for the network security group resource."
  default     = "GAB-TF-nsg"
}

variable "adminPassword" {
  description = "Administrator password"
  default     = "<put VM admin password here>"
}

variable "addressPrefix" {
  description = "The address space that is used by the virtual network."
  default     = "12.0.0.0/24"
}

variable "subnetName" {
  description = "Subnet resource name."
  default     = "default"
}

variable "subnetPrefix" {
  description = "The address prefix to use for the subnet."
  default     = "12.0.0.0/24"
}

variable "publicIpAddressName" {
  description = "The name of public ip resource."
  default     = "GAB-TF-ip"
}

variable "publicIpAddressType" {
  default     = "Dynamic"
}