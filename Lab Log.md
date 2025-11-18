## Lab Log

### Phase 1 - Research & Design
- Reviewed official Terraform tutorials for EKS, AKS and GKE to understand common patterns for VPC + multi-AZ + load balancer + worker nodes (Research | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Research | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Research | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  
- Reviewed the AWS EKS multi-cluster blog to understand how similar patterns are applied when applications span multiple clusters and regions (Research | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  
- Chosen a simplified target architecture: a single web “cluster” on EC2 instances spread across two Availability Zones behind an ALB, inspired by multi-AZ patterns from the Kubernetes examples.
***

### Phase 2 - GitHub Repo & Workflow
- Created a public GitHub repository `terraform-web-aws` with `main` as the stable branch and a planned set of `feature/*` branches for individual phases (project init, networking, security+EC2, ALB, modules+CI).  
- Added an initial `README.md` and a Lab Log as a living document to record design decisions and changes over time.  
- Decided to use Pull Requests for each significant change, with structured descriptions (Summary, Changes, Rationale, Testing), mirroring typical Git-based workflows in Terraform/Kubernetes projects (Process | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781); Process | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  
***

### Phase 3 - Terraform Skeleton
- Implemented the base Terraform structure: `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf` and `.gitignore`.  
- Configured the AWS provider with a parameterised `aws_region`, enabling reuse of the configuration across regions without code changes (Pattern | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  
- Ran `terraform init`, `terraform fmt` and `terraform validate` to verify configuration correctness and enforce a consistent code style, following HashiCorp’s recommendations for Terraform projects (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  
- Opened a Pull Request **"Initialize Terraform project structure"** as the first step in a fully scripted IaC pipeline, ensuring that all subsequent infrastructure changes will be tracked, discussed and reviewed via GitHub.

## Prerequisites
- Terraform >= 1.7
- AWS account with appropriate IAM permissions
- AWS CLI configured (`aws configure`)
- Git + GitHub account
***