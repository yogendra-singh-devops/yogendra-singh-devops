<div align="center">

# 🏗️ Azure Enterprise Terraform Modular Suite
### **Production-Grade Infrastructure as Code (IaC) Framework for Microsoft Azure**

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D_1.5.0-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![Azure Provider](https://img.shields.io/badge/AzureRM-v3.90+-0089D6?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![Security Scan](https://img.shields.io/badge/Checkov-Passing-brightgreen?style=for-the-badge)](https://checkov.io)
[![Author](https://img.shields.io/badge/Author-Yogendra_Singh-0078D4?style=for-the-badge&logo=github&logoColor=white)](https://github.com/yogendra-singh-devops)

<br/>

> *"Engineered to demonstrate enterprise-grade Terraform practices: advanced `for_each` iteration, parameterized `map(object)` schemas, `dynamic` HCL blocks, zero-trust network segregation, and automated CI/CD gating."*

---

</div>

## 📌 Architectural Overview

This repository provides an enterprise blueprint for deploying end-to-end Microsoft Azure infrastructure with zero out-of-band portal changes.

```
+-----------------------------------------------------------------------------------------+
|                                PRODUCTION SUITE MODULES                                 |
|                                                                                         |
|  [ Networking Module ]      [ Storage Module ]      [ Key Vault ]      [ AKS Cluster ]  |
|  - Dynamic Subnets          - Dynamic Firewall      - Dynamic ACLs     - System Pool    |
|  - Dynamic NSG Rules        - Soft Delete Retention - for_each Secrets - Dynamic Pools  |
|  - Dynamic Route Table      - for_each Containers   - Access Policies  - CSI Driver     |
+-----------------------------------------------------------------------------------------+
```

---

## 💡 Advanced Terraform HCL Patterns Demonstrated

### 1. Dynamic Blocks Iteration
Instead of hardcoding repetitive resources, security rules, and delegations, the modules leverage `dynamic` blocks with nested iterators:
```hcl
dynamic "security_rule" {
  for_each = var.nsg_rules
  content {
    name                   = security_rule.key
    priority               = security_rule.value.priority
    direction              = security_rule.value.direction
    access                 = security_rule.value.access
    protocol               = security_rule.value.protocol
    source_port_range      = security_rule.value.source_port_range
    destination_port_range = security_rule.value.destination_port_range
  }
}
```

### 2. Parameterized `map(object({...}))` Schema
Strict type validation enforcing predictable configuration while allowing clean overrides:
```hcl
variable "additional_node_pools" {
  type = map(object({
    vm_size             = string
    node_count          = optional(number, 2)
    enable_auto_scaling = optional(bool, true)
    min_count           = optional(number, 1)
    max_count           = optional(number, 10)
    vnet_subnet_id      = string
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
  }))
}
```

### 3. Defensive Terraform Functions
Utilizes built-in functions (`can()`, `try()`, `lookup()`, `flatten()`, and conditional filtering) to safely handle optional attributes and avoid deployment halts.

---

## 📂 Repository Directory Layout

```
.
├── .github/
│   └── workflows/
│       └── terraform-ci-cd.yml      # Automated linting, Checkov scan & Plan
├── modules/
│   ├── networking/                  # Hub-and-Spoke VNet, dynamic Subnets, NSG & UDR
│   ├── compute_vm/                  # Linux VMs with dynamic SSH keys & Managed Identities
│   ├── storage_account/             # GRS Storage with dynamic network rules & containers
│   ├── key_vault/                   # Key Vault with dynamic network ACLs & access policies
│   └── aks_cluster/                 # Production AKS with dynamic user node pools & CSI
├── environments/
│   └── production/                  # Root orchestration assembling all modules
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars.example
│       ├── outputs.tf
│       ├── provider.tf
│       └── versions.tf
└── README.md
```

---

## 🚀 Quick Start Guide

### Prerequisites
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) logged in (`az login`)

### Deployment Steps
```bash
# 1. Clone repository
git clone https://github.com/yogendra-singh-devops/terraform-azure-enterprise-suite.git
cd terraform-azure-enterprise-suite/environments/production

# 2. Configure variables
cp terraform.tfvars.example terraform.tfvars
# Update tenant_id and ssh_public_key

# 3. Initialize working directory
terraform init

# 4. Generate & inspect execution plan
terraform plan

# 5. Apply infrastructure
terraform apply
```

---

## 🛡️ Security & DevSecOps Controls
- **Zero-Trust Network Access:** All PaaS services restricted via Private Endpoints and dynamic subnet ACLs.
- **Automated Scanning:** Static code analysis via `Checkov` and `TFLint` integrated into GitHub Actions.
- **State File Isolation:** Remote state locking backed by geo-redundant Azure Blob Storage with customer-managed keys.

---

<div align="center">
Developed by <b><a href="https://github.com/yogendra-singh-devops">Yogendra Singh</a></b> • DevOps Engineer
</div>

