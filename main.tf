terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region     = var.region
}

# Google Cloud Provider
provider "google" {
  credentials = var.gcp_key_file
  project     = var.gcp_project
  region      = var.region
}

# Azure Provider
provider "azurerm" {
  features {}
  client_id     = var.azure_client_id
  client_secret = var.azure_secret
}

# Generate SSH Key (if needed)
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  count      = var.use_existing_key_pair ? 0 : 1
  key_name   = "generated-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

# Security Group Module (AWS only for now)
module "security_group" {
  source          = "./modules/security_group"
  project_name    = var.project_name
  aws_region      = var.region
  vpc_id          = var.vpc_id
  ssh_ip_address  = var.ssh_ip_address
}

# --------------------
# AWS Instance
# --------------------
resource "aws_instance" "vm" {
  count         = var.cloud_provider == "AWS" ? 1 : 0
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.vm_size
  key_name      = var.use_existing_key_pair ? var.existing_key_pair_name : aws_key_pair.key_pair[0].key_name
  vpc_security_group_ids = [module.security_group.security_group_id]

  user_data = templatefile("${path.module}/user_data.sh.tmpl", {
    deployment_mode   = var.deployment_mode,
    setup_demo_clone  = var.setup_demo_clone,
    ssh_password      = var.ssh_password,
    clone_target_url  = var.clone_target_url
  })

  tags = {
    Name = var.vm_name
  }
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# --------------------
# GCP Instance
# --------------------
resource "google_compute_instance" "vm" {
  count        = var.cloud_provider == "GCP" ? 1 : 0
  name         = var.vm_name
  machine_type = var.vm_size
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata_startup_script = templatefile("${path.module}/user_data.sh.tmpl", {
    deployment_mode   = var.deployment_mode,
    setup_demo_clone  = var.setup_demo_clone,
    ssh_password      = var.ssh_password,
    clone_target_url  = var.clone_target_url
  })
}

# --------------------
# Azure Instance
# --------------------
resource "azurerm_resource_group" "rg" {
  count    = var.cloud_provider == "Azure" ? 1 : 0
  name     = "${var.vm_name}-rg"
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.cloud_provider == "Azure" ? 1 : 0
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg[0].name
}

resource "azurerm_subnet" "subnet" {
  count                = var.cloud_provider == "Azure" ? 1 : 0
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg[0].name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  count               = var.cloud_provider == "Azure" ? 1 : 0
  name                = "${var.vm_name}-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg[0].name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count               = var.cloud_provider == "Azure" ? 1 : 0
  name                = "${var.vm_name}-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg[0].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[0].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.cloud_provider == "Azure" ? 1 : 0
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.rg[0].name
  location            = var.region
  size                = var.vm_size
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.nic[0].id,
  ]

  admin_password = var.ssh_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/user_data.sh.tmpl", {
    deployment_mode   = var.deployment_mode,
    setup_demo_clone  = var.setup_demo_clone,
    ssh_password      = var.ssh_password,
    clone_target_url  = var.clone_target_url
  }))
}

# Output IP
output "vm_ip" {
  value = (
    var.cloud_provider == "AWS"   ? aws_instance.vm[0].public_ip :
    var.cloud_provider == "GCP"   ? google_compute_instance.vm[0].network_interface[0].access_config[0].nat_ip :
    var.cloud_provider == "Azure" ? azurerm_public_ip.public_ip[0].ip_address :
    null
  )
  description = "Public IP of the deployed instance"
}

# Save SSH Key
resource "local_file" "private_key" {
  count           = var.use_existing_key_pair ? 0 : 1
  filename        = "${path.module}/generated-key.pem"
  content         = tls_private_key.generated_key.private_key_pem
  file_permission = "0600"
}
