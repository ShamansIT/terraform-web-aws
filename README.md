# terraform-web-aws
Developing highly available Web infrastructure on AWS using Terraform

## Introduction
Project demonstrates the creation of a high-availability web infrastructure on AWS using Terraform.  

Architecture includes a **VPC**, public and private **subnets**, **security groups**, two **EC2 web instances** in different **Availability Zones**, and an **Application Load Balancer (ALB)** for traffic distribution.  The implementation templates approach is provide in production environments for managed Kubernetes clusters (EKS/AKS/GKE), but is implemented in a simplified form based on EC2 nodes (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  

Solution applies the principles of **Infrastructure as Code**, modular configuration structure, and Git-oriented workflow with **feature branches** and **Pull Requests**, which aligns this student project with real DevOps practices (Best practice | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/); Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).

## Tech Stack
- **Terraform** (Infrastructure as Code)
- **AWS** (VPC, EC2, ALB, Security Groups)
- **Git + GitHub** (branching, Pull Requests, code review)
- **GitHub Actions** for `terraform fmt` and `terraform validate`

## Prerequisites
- Terraform >= 1.7
- AWS account with appropriate IAM permissions
- AWS CLI configured (`aws configure`)
- Git + GitHub account

## Research & Design (Stage 1)
Initial research focused on understanding common IaC and networking patterns from official Terraform Kubernetes tutorials (Research | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); [AKS](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); [GKE](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)) and resilient multi-cluster architectures (Research | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  
Based on this, the project scope was defined as a simplified HA web stack on EC2 across two Availability Zones, with an ALB in front.

## GitHub Repo & Workflow (Stage 2)
Public GitHub repository `terraform-web-aws` created with `main` as the stable branch and dedicated `feature/*` branches for each phase (project init, networking, security+EC2, ALB, modules+CI).  
A Git-based workflow with structured Pull Requests (Summary, Changes, Rationale, Testing) was adopted to mirror real-world Terraform/Kubernetes projects and to make the evolution of the infrastructure transparent (Process | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781); [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

## Terraform project skeleton (Stage 3)
In the initial stage - Terraform skeleton, the focus is on building a **clean, extensible IaC structure** that can be safely developed in subsequent phases.

### File structure
Terraform skeleton includes:
- `providers.tf`  
  - Contains the block 'terraform {}' with the Terraform version committed and 'required_providers'.  
  - Configures 'provider 'aws' with a parameterized region ('var.aws_region').  
  - Separation of the provider's configuration from resources follows HashiCorp's recommendations and common patterns in the EKS/AKS/GKE examples (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  

- `variables.tf`  
  - Specifies a variable `aws_region` (`string`, default `eu-west-1`).  
  - Region parameterization allows you to reuse the configuration between regions without changing the code, which corresponds to the concept of "unified workflow" from Kubernetes tutorials (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  

- `main.tf`  
  - Contains only comments and serves as a root input for future resources (VPC, subnets, EC2, ALB).  
  - Maintains the minimalism of the root module and prepares it for further division into modules or stacks (Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

- `outputs.tf`  
  - Currently contains a placeholder comment.  
  - The presence of this file from the very beginning helps to determine in advance which values (e.g. 'alb_dns_name' or IP addresses of the instances) should act as a "contract" between the infrastructure and external tools (CI/CDs, scripts) (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  

- `.gitignore`  
  - Ignores '.terraform/', 'terraform.tfstate', 'terraform.tfstate.backup', '*.tfvars' and similar artifacts.  
  - It`s critical for keeping state and potential secrets outside the repository and for ensuring a clean Git history (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

### Structure Explanation

1. **Compliance with real EKS projects**  
David Muñoz's article shows that even complex infrastructures can be supported with a small set of core files (`main.tf`, `providers.tf`, `variables.tf`, `outputs.tf`) and individual tfvars (Best practice | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781)).  

2. **Scale potential**  
The concept of Terraform Stacks clearly demonstrates the need for a clear boundary between root configurations and modular components as infrastructure grows (Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)). Skeleton is already consistent with this logic.  

3. **Repeatability and portability**  
Conceptually preserved common Terraform-workflow patterns (init → format → validate → plan → apply), which coincides with the approach in multi-cloud Kubernetes projects (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  

### `terraform init`, `terraform fmt`, `terraform validate` are part of the routine
Each local change is accompanied by:
- `terraform init` -> loads and blocks ISP versions.  
- `terraform fmt` -> formats '.tf' files with a single style.  
- `terraform validate` -> checks syntax and basic consistency.  
It`s a small local pipeline that meets HashiCorp's recommendations and is the first step towards CI integration (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

## Design considerations, trade-offs and risks
Even at the **skeleton level**, design solutions have advantages and disadvantages.

### Advantages of the chosen approach
- **Clear separation of responsibilities**  
  - Providers, variables, outputs, and future resources are divided between files, which simplifies the readability of the root module and facilitates further modulation (Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

- **Ready for multi-cluster / multi-region templates**  
  - Skeleton is aligned with the guidelines from the AWS EKS multi-cluster blog, even if the target is currently one "web cluster" (Best practice | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  

- **Collaborative workflow with Kubernetes projects**  
  - Adherence to principles similar to EKS/AKS/GKE examples makes the transition to Kubernetes in the future easier (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  

### Risks and limitations
- **Focus on one account or region**  
  - At this moment **skeleton** does not have a backend configuration for multi-region/multi-account scenarios (Risk | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

- **Local state**  
  - In the case of local 'terraform.tfstate', there is a risk of:
    - State losses,  
    - conflict changes in teamwork,  
    - more complex rollback.  
  - Remote backend (S3 + DynamoDB) eliminates these shortcomings, but on the contrary, adds complexity to the project.  

- **Pinned versions need maintenance**  
  - AWS provider requires change monitoring (Risk | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781)).  

- ** Terraform and the risk of first-stage errors**  
  - Even starting stage construction requires an understanding of state, dependency graph, and lifecycle semantics (Risk | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Risk | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  


## Lab Log 
TODO

<<<<<<< HEAD


=======
## Prerequisites

- Terraform >= 1.7
- AWS account with appropriate IAM permissions
- AWS CLI configured (`aws configure`)
- Git + GitHub account
>>>>>>> 2ef1d09b11c5317fd55b580cda495684acac7238
