provider "azurerm" {
    version = "2.5.0"
    features {
      
    }
}

resource "azurerm_resource_group" "tf_test" {
    name = "tfmainrg"
    location = "Australia East"
}

variable "imagebuild" {
    type = string
    description = "Latest Image Build"
    default = "v1"
}

resource "azurerm_container_group" "tfcg_test" {
    name = "weatherapi"
    location = azurerm_resource_group.tf_test.location
    resource_group_name = azurerm_resource_group.tf_test.name

    ip_address_type     = "public"
    dns_name_label      = "onlylightweatherapi"
    os_type             = "Linux"

    container {
        name            = "weatherapi"
        image           = "onlylight291998/docker_dotnet:${var.imagebuild}"
        cpu             = "1"
        memory          = "1"

        ports {
            port        = 80
            protocol    = "TCP"
        }
  }
}