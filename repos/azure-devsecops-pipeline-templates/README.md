<div align="center">

# 🔄 Azure DevSecOps Enterprise Pipeline Templates
### **Reusable, Multi-Stage CI/CD Pipeline Blueprints with Shift-Left Security**

[![Azure DevOps](https://img.shields.io/badge/Azure_Pipelines-0078D7?style=for-the-badge&logo=azure-devops&logoColor=white)](https://dev.azure.com)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com)
[![Security](https://img.shields.io/badge/DevSecOps-Trivy_%7C_Checkov-FF69B4?style=for-the-badge)](https://aquasecurity.github.io/trivy/)
[![Author](https://img.shields.io/badge/Author-Yogendra_Singh-0078D4?style=for-the-badge&logo=github&logoColor=white)](https://github.com/yogendra-singh-devops)

</div>

## 📌 Overview
This repository contains production-ready YAML pipeline templates for **Azure DevOps Pipelines** and **GitHub Actions**, enforcing:
1. **Shift-Left Security:** Automated SAST, container vulnerability scanning (`Trivy`), and IaC security audits (`Checkov`).
2. **FinOps Cost Estimation:** Shift-left cloud spend forecasting using `Infracost` during Pull Requests.
3. **Environment Gates:** Automated testing in lower tiers with mandatory multi-reviewer approval gates for production deployments.
4. **Zero-Secret Hardcoding:** Native integration with Azure Key Vault, Service Connections, and OIDC federated credentials.

---

## 📂 Repository Contents
- `azure-pipelines-iac.yml`: Multi-stage Terraform pipeline with security and manual peer approval gates.
- `azure-pipelines-app.yml`: Containerized application build, vulnerability scan, and AKS release pipeline.
- `templates/`: Modular YAML steps for linting, scanning, artifact publishing, and rollback automation.

<div align="center">
Maintained by <b><a href="https://github.com/yogendra-singh-devops">Yogendra Singh</a></b> • DevOps Engineer
</div>

