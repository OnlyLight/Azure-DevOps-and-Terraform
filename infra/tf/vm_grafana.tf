resource "azurerm_virtual_network" "grafana" {
  name                = "${var.environment}-${var.prefix_grafana}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "grafana" {
  name                 = "${var.environment}-${var.prefix_grafana}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.grafana.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "grafana" {
  name                         = "${var.environment}-${var.prefix_grafana}-publicIP"
  location                     = azurerm_resource_group.example.location
  resource_group_name          = azurerm_resource_group.example.name
  allocation_method            = "Dynamic"
}

data "azurerm_public_ip" "grafana" {
  name = azurerm_public_ip.grafana.name
  resource_group_name = azurerm_public_ip.grafana.resource_group_name
}

resource "azurerm_network_security_group" "grafana" {
  name                = "${var.environment}-${var.prefix_grafana}-network-security-group"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "grafana" {
  name                = "${var.environment}-${var.prefix_grafana}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.grafana.id
    public_ip_address_id          = azurerm_public_ip.grafana.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "grafana" {
  network_interface_id      = azurerm_network_interface.grafana.id
  network_security_group_id = azurerm_network_security_group.grafana.id
}

resource "azurerm_linux_virtual_machine" "grafana" {
  name                = "${var.environment}-${var.prefix_grafana}-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.grafana.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -",
  #     "sudo add-apt-repository 'deb https://packages.grafana.com/oss/deb stable main'",
  #     "sudo apt update",
  #     "sudo apt install grafana",
  #     "sudo systemctl start grafana-server",
  #     "sudo systemctl enable grafana-server"
  #   ]
  #   connection {
  #     host        = data.azurerm_public_ip.grafana.ip_address
  #     type        = "ssh"
  #     user        = "adminuser"
  #     private_key = file("~/.ssh/id_rsa")
  #   }
  # }
}
