provider "azurerm" {
  subscription_id = "<put your subscription id here>"
  client_id       = "<put your service principal id here>"
  client_secret   = "<put your service principal key here>"
  tenant_id       = "<put your tenant id here>"
}

# Create a Resource Group for the new Virtual Machine.
resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "main" {
  name                = "${var.virtualNetworkName}"
  address_space       = ["${var.addressPrefix}"]
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "${var.subnetName}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "${var.subnetPrefix}"
}

# Create a Public IP for the Virtual Machine
resource "azurerm_public_ip" "main" {
  name                         = "${var.publicIpAddressName}"
  location                     = "${azurerm_resource_group.main.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  public_ip_address_allocation = "${var.publicIpAddressType}"
}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "${var.networkSecurityGroupName}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network interface for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "main" {
  name                      = "${var.networkInterfaceName}"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

# Create a new Virtual Machine based on the Golden Image
resource "azurerm_virtual_machine" "vm" {
  name                             = "${var.virtualMachineName}"
  location                         = "${azurerm_resource_group.main.location}"
  resource_group_name              = "${azurerm_resource_group.main.name}"
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = "${var.virtualMachineSize}"
  delete_os_disk_on_termination    = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.virtualMachineName}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "40"
  }

  os_profile {
    computer_name  = "${var.virtualMachineName}"
    admin_username = "${var.adminUsername}"
    admin_password = "${var.adminPassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

data "azurerm_public_ip" "main" {
  name                = "${azurerm_public_ip.main.name}"
  resource_group_name = "${azurerm_virtual_machine.vm.resource_group_name}"
}

output "PublicIP" {
  value = "${data.azurerm_public_ip.main.ip_address}"
}