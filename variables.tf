variable "environment" {
  type = string
  description = "Environment (dev, staging, prod)"
}

variable "location" {
  type = string
  description = "Azure region"
  default = "eastus"
}

variable "tags" {
  type = map(string)
  description = "Resource tags"
  default = {
    Environment = "development"
    Project = "Security Platform"
    ManagedBy = "Terraform"
  }
}

variable "address_space" {
  type = list(string)  
  description = "Address space for the virtual network"
  default = [ "10.0.0.0/16" ]
}

variable "subnet_prefixes" {
  type = map(string)
  default = {
    frontend = "10.0.1.0/24"
    backend = "10.0.2.0/24"
    data = "10.0.3.0/24"
  }
}

variable "aks_node_count" {
  type = map(number)
  default = {
    dev = 1
    staging = 2
    prod = 3
  }
}

variable "tenant_id" {
  type  = string
  description = "Azure AD tentant ID"
}

variable "allowed_ips" {
  type    = list(string)
  description = "List of allowed IP addresses for network rules"
  default = []
}

variable "blocked_ip_addresses" {
  type    = list(string)
  description = "List of IP addresses to block at WAF level"
  default = []
}

variable "kubernetes_version" {
  type        = string
  description = "Version of kubernetes to deploy"
  default     = "1.27"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs"
  default     = 90
}

variable "alert_email" {
  type   = string
  description = "Email address for monitoring alerts"
}

variable "key_vault_sku" {
  type        = string
  description = "SKU for Key Vault"
  default     = "premium"
}

variable "acr_sku" {
  type        = string
  description = "SKU for Azure Container Registry"
  default     = "Premium"
}

variable "storage_account_tier" {
  type        = string
  description   = "Tier for storage account"
  default       = "Premium"
}

variable "storage_replication_type" {
  type        = string
  description = "Replication type for storage account"
  default     = "ZRS"
}

variable "waf_mode" {
  type         = string
  description  = "WAF mode (Detection or Prevention)"
  default      = "Prevention"
  validation {
    condition     = contains(["Detection","Prevention"],var.waf_mode)
    error_message = "WAF mode must be either Detection or Prevention."
  }
}

variable "admin_group_object_ids" {
  type        = list(string)
  description = "List of Azure AD group object IDs for admin access"
  default = []
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for AKS cluster"
  default = "security-platform"
}

variable "system_node_pool" {
  type        = object({
    vm_size   = string
    min_count = number
    max_count = number
  })

  description = "System node pool configuration"
  default = {
    vm_size = "Standard_D4s_v3"
    min_count = 3
    max_count = 5
  }
}

variable "network_plugin" {
 type          = string
 description   = "Network plugin for AKS cluster" 
 default       = "azure"
}

variable "network_policy" {
  type        = string
  description = "Network policy for AKS cluster"
  default     = "calico"
}

variable "service_cider" {
  type         = string
  description  = "CIDR for kubernetes services"
  default      = "10.0.0.0/16"
}

variable "pod_cider" {
 type        =  string
 description = "CIDR for kubernetes pods"
 default     = "10.244.0.0/16"
}

variable "appgw_capacity" {
  type        = number
  description = "Capacity for Application Gateway"
  default     = 2
}

variable "cpu_threshold" {
  type        = number
  description = "CPU threshold percentage for alerts"
  default     = 80
}

variable "memory_threshold" {
  type        = number
  description = "Memory threshold percentage for alerts"
  default     = 80
}