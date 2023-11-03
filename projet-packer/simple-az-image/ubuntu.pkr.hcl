source "azure-arm" "TomPacker" {
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
    dept = "training"
  }
}
// Build the image using azure-arm builder and use a shell provisioner which will execute a shell script
build {
  sources = ["sources.azure-arm.TomPacker"]
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo {{ .Path }}"
    script          = "./setup-azcli.sh"
  }
}
