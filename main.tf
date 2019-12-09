
variable "arm_subscription_id" {}
variable "arm_client_id" {}
variable "arm_client_secret" {}
variable "arm_tenant_id" {}
variable "ssh_public_key" {}


provider "azurerm" {
    subscription_id = "${var.arm_subscription_id}"
    client_id = "${var.arm_client_id}"
    client_secret = "${var.arm_client_secret}"
    tenant_id = "${var.arm_tenant_id}"
}

data "azurerm_image" "ubuntusrv_docker_api" {
    name = "ubuntusrv-docker-api-image"
    resource_group_name = "eespinoza-devopstest-images"
}

data "azurerm_image" "ubuntusrv_postgresql" {
    name = "ubuntusrv-postgresql-image"
    resource_group_name = "eespinoza-devopstest-images"
}

resource "azurerm_resource_group" "default" {
  name = "eespinoza-devopstest"
  location = "eastus"
}

resource "azurerm_virtual_network" "default" {
  name = "default-network"
  address_space = ["20.0.0.0/24"]
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
}

resource "azurerm_subnet" "default" {
  name = "default-subnet"
  resource_group_name = "${azurerm_resource_group.default.name}"
  virtual_network_name = "${azurerm_virtual_network.default.name}"
  address_prefix = "20.0.0.0/24"
}

resource "azurerm_public_ip" "docker-api" {
  name = "docker-api-publicip"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_public_ip" "postgresql" {
  name = "postgresql-publicip"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_security_group" "docker-api" {
  name = "docker-api-nsg"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"

  security_rule {
    name = "api-http"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "8069"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "ssh"
    priority = 150
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "postgresql" {
  name = "postgresql-nsg"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"

  security_rule {
    name = "ssh"
    priority = 150
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "docker-api" {
  name = "docker-api-nic"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  network_security_group_id = "${azurerm_network_security_group.docker-api.id}"

  ip_configuration {
      name = "docker-api-nic-configuration"
      subnet_id = "${azurerm_subnet.default.id}"
      private_ip_address_allocation = "static"
      private_ip_address = "20.0.0.10"
      public_ip_address_id = "${azurerm_public_ip.docker-api.id}"
  }
}

resource "azurerm_network_interface" "postgresql" {
  name = "postgresql-nic"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  network_security_group_id = "${azurerm_network_security_group.postgresql.id}"

  ip_configuration {
      name = "postgresql-nic-configuration"
      subnet_id = "${azurerm_subnet.default.id}"
      private_ip_address_allocation = "static"
      private_ip_address = "20.0.0.11"
      public_ip_address_id = "${azurerm_public_ip.postgresql.id}"
  }
}

resource "azurerm_virtual_machine" "docker-api" {
  name = "docker-api-vm"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  vm_size = "Standard_B1s"
  network_interface_ids = ["${azurerm_network_interface.docker-api.id}"]


  storage_image_reference {
    id = "${data.azurerm_image.ubuntusrv_docker_api.id}"
  }

  storage_os_disk {
    name          = "docker-api-disk"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "docker-api-vm"
    admin_username = "testuser"
    admin_password = "docker-api-vm-12345"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testuser/.ssh/authorized_keys"
      key_data = "${var.ssh_public_key}"
    }
  }
}

resource "azurerm_virtual_machine" "postgresql" {
  name = "postgresql-vm"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  vm_size = "Standard_B1ms"
  network_interface_ids = ["${azurerm_network_interface.postgresql.id}"]

  storage_image_reference {
    id = "${data.azurerm_image.ubuntusrv_postgresql.id}"
  }

  storage_os_disk {
    name          = "postgresql-disk"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "postgresql-vm"
    admin_username = "testuser"
    admin_password = "postgresql-vm-12345"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testuser/.ssh/authorized_keys"
      key_data = "${var.ssh_public_key}"
    }    
  }
}

output "docker-api-vm-ip" {
  value = "${azurerm_public_ip.docker-api.ip_address}"
}

output "postgresql-vm-ip" {
  value = "${azurerm_public_ip.postgresql.ip_address}"
}




