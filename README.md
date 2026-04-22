# Secure Azure DevSecOps Platform for Regulated Cloud Environments

## Overview
This project demonstrates how I designed and implemented a secure, scalable cloud environment on Microsoft Azure using DevSecOps principles.

My focus was not just on deploying infrastructure, but on building a system where security, automation, and reliability are integrated from the start. The platform is designed to reflect real-world requirements where systems must be secure by design and easy to manage at scale.

---

## Use Case
I built this platform with regulated environments in mind, such as healthcare and financial systems, where there are strict requirements around:

Data protection
Access control
System resilience

The goal was to show how DevSecOps practices can be used to:

Standardise infrastructure deployments
Reduce configuration drift
Improve overall cloud security posture

---

## Architecture
The platform is built using the following core components:

Azure Virtual Network with segmented subnets for traffic isolation
Azure Kubernetes Service (AKS) for container orchestration
Azure Container Registry for secure image management
Terraform for Infrastructure as Code (IaC)
CI/CD pipelines for automated deployment

This architecture allows for scalable and repeatable deployments while maintaining strong security controls.

---

## Security Features
Security was a core part of the design. Key controls include:

Identity and Access Management using RBAC and least privilege principles
Azure Key Vault for secure secrets storage
Network segmentation to limit unnecessary access between components
Azure Monitor for logging, monitoring, and threat detection

These controls help ensure that the environment is both secure and observable.

---

## Technology Stack
Microsoft Azure
Terraform
Kubernetes (AKS)
Azure DevOps / CI/CD pipelines
Azure Monitor

---

## Outcome
This project demonstrates how secure cloud environments can be built using a DevSecOps approach.

It reflects my ability to design and implement cloud infrastructure that is:

Secure by design
Automated and repeatable
Scalable and resilient
