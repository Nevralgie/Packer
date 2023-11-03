source "azure-arm" "Ubuntu" {
  client_id     = "${var.client_id}"
  client_secret = "${var.client_secret}"
  # resource_group_name = var.resource_group_name
  # storage_account = var.storage_account
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  //----------------------------
  //Destination image
  // Either a VHD or a managed image can be built, but not both. Please specify either capture_container_name and capture_name_prefix or managed_image_resource_group_name and managed_image_name.
  # capture_container_name = var.capture_container_name
  # capture_name_prefix = var.capture_name_prefix
  managed_image_resource_group_name = "${var.resource_group_name}"
  managed_image_name                = "${var.image_name_ubuntu}-${var.image_version_ubuntu}"
  // Managed Image configuration will not need the storage account. It will store the image under resource group
  //----------------------------
  // Source image
  os_type         = "Linux"
  image_publisher = "${var.source_image_publisher}"
  image_offer     = "${var.source_image_offer}"
  image_sku       = "${var.source_image_sku}"
  // Either location or build_resource_group_name, but not both
  # location = "France Central"
  build_resource_group_name = var.resource_group_name
  vm_size                   = var.vm_size
  azure_tags = {
    dept = "linux"
  }
}

source "azure-arm" "Windows" {
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  communicator    = "winrm"
  winrm_insecure  = true
  winrm_timeout   = "5m"
  winrm_use_ssl   = true
  winrm_username  = "packer"
  managed_image_resource_group_name = "${var.resource_group_name}"
  managed_image_name                = "${var.image_name_windows}-${var.image_version_windows}"
  os_type         = "Windows"
  image_publisher = "${var.source_image_publisher_w}"
  image_offer     = "${var.source_image_offer_w}"
  image_sku       = "${var.source_image_sku_w}"
  build_resource_group_name = var.resource_group_name
  vm_size                   = var.vm_size_w
  azure_tags = {
    dept = "Windows"
  }
}

source "azure-arm" "RedHat" {
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  managed_image_resource_group_name = "${var.resource_group_name}"
  managed_image_name                = "${var.image_name_rhel}-${var.image_version_rhel}"
  os_type         = "Linux"
  image_publisher = "${var.source_image_publisher_r}"
  image_offer     = "${var.source_image_offer_r}"
  image_sku       = "${var.source_image_sku_r}"
  build_resource_group_name = var.resource_group_name
  vm_size                   = var.vm_size_r
  azure_tags = {
    dept = "Rhel"
  }
}

build {
  sources = ["sources.azure-arm.Ubuntu",] 
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo {{ .Path }}"
    script          = "./setup-azcli.sh"
    }
  }


build {
  sources = ["sources.azure-arm.Windows"]
  provisioner "powershell" {
    inline = [
      "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile .\\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\\AzureCLI.msi"
    ]
  }
}

build {
  sources = ["sources.azure-arm.RedHat"] 
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo {{ .Path }}"
    script          = "./setup_rhelazcli.sh"
    }
  }

