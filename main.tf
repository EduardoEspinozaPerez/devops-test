
variable "arm_subscription_id" {}
variable "arm_client_id" {}
variable "arm_client_secret" {}
variable "arm_tenant_id" {}


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
    source_port_range = "8069"
    destination_port_range = "8069"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "ssh"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "22"
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
    name = "postgresql"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "5432"
    destination_port_range = "5432"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "ssh"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "22"
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
      private_ip_address = "20.0.0.3"
      public_ip_address_id = "${azurerm_public_ip.docker-api}"
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
      private_ip_address = "20.0.0.2"
      public_ip_address_id = "${azurerm_public_ip.postgresql}"
  }
}

resource "azurerm_virtual_machine" "docker-api" {
  name = "docker-api-vm"
  location = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  vm_size = "Standard_B1s"
  network_interface_ids = ["${azurerm_network_interface.docker-api.id}"]


  storage_image_reference {
    id = "${data.azurerm_image.ubuntusrv_docker_api}"
  }

  storage_os_disk {
    name          = "docker-api-disk"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "docker-api-vm"
    admin_username = "test-user"
    admin_password = "docker-api-vm-12345"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/user/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFaq4Kj3gqdsTm5l2mweQj2WY9PBIgaKsC3DDUE8h7EeYvQNxl393oE0l+5VaS1deun2KX79dW2ZUkCwCPzsf4fi8k7EgN2ZIwZ4HM838ResUOPoqmmbRKbaDnR+48aZpMdZ6ZMatvxk/VZYEYsg78Ux56M8wAR/9ZP976dBriLs8Ad2/aPluZHCblgTjV/rEN3sC1Dsn7iBP9VVzKlFLnkyD6hORkdhBtnBRDMIoDrjGfFE+cukVCb+Js9nhZ/c6Rt/YYQuR1Odi93j1aGJr8U0OCKw91sqBIbe9BEOOxw97xaMpWp6oDOwY4oz5EQDy8OLdOgOngXMAn/7JnWgVC9zFarqcWU6YywFrE1FyD3jJpI5LoEZB+qbOeqyqyzc7OpFEEgSfdIwvHntwGwX/tJFI5ZLv9SrKCCdReUnIFPcmgX2MNX0pqq0knDjPWucePx/M8C3vcCAxUyZ/0mVvvzCpW3rOeBtt+lIt2sFk3VQx70CKVFYQYBebEiexqdac="
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
    id = "${data.azurerm_image.ubuntusrv_postgresql}"
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
      path = "/home/user/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFaq4Kj3gqdsTm5l2mweQj2WY9PBIgaKsC3DDUE8h7EeYvQNxl393oE0l+5VaS1deun2KX79dW2ZUkCwCPzsf4fi8k7EgN2ZIwZ4HM838ResUOPoqmmbRKbaDnR+48aZpMdZ6ZMatvxk/VZYEYsg78Ux56M8wAR/9ZP976dBriLs8Ad2/aPluZHCblgTjV/rEN3sC1Dsn7iBP9VVzKlFLnkyD6hORkdhBtnBRDMIoDrjGfFE+cukVCb+Js9nhZ/c6Rt/YYQuR1Odi93j1aGJr8U0OCKw91sqBIbe9BEOOxw97xaMpWp6oDOwY4oz5EQDy8OLdOgOngXMAn/7JnWgVC9zFarqcWU6YywFrE1FyD3jJpI5LoEZB+qbOeqyqyzc7OpFEEgSfdIwvHntwGwX/tJFI5ZLv9SrKCCdReUnIFPcmgX2MNX0pqq0knDjPWucePx/M8C3vcCAxUyZ/0mVvvzCpW3rOeBtt+lIt2sFk3VQx70CKVFYQYBebEiexqdac="
    }    
  }
}

output "docker-api-vm-ip" {
  value = "${azurerm_public_ip.docker-api.ip_address}"
}

output "postgresql-vm-ip" {
  value = "${azurerm_public_ip.postgresql.ip_address}"
}




