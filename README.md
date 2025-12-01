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
<details> <summary>AWS Configure</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/images/Terraform(IAC)_01_aws_configure.jpg?raw=true" width="900" alt="aws_configure"> </details>


## GitHub Repo & Workflow (Stage 2)
Public GitHub repository `terraform-web-aws` created with `main` as the stable branch and dedicated `feature/*` branches for each phase (project init, networking, security+EC2, ALB, modules+CI).  
A Git-based workflow with structured Pull Requests (Summary, Changes, Rationale, Testing) was adopted to mirror real-world Terraform/Kubernetes projects and to make the evolution of the infrastructure transparent (Process | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781); [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

<details> <summary>Init Terraform</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/images/Terraform(IAC)_02_init_terraform.jpg?raw=true" width="900" alt="init_terraform"> </details>

<details> <summary>Validate Terraform</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/images/Terraform(IAC)_03_validate_terraform.jpg?raw=true" width="900" alt="validate_terraform"> </details>

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

**Compliance with real EKS projects**  
David Muñoz's article shows that even complex infrastructures can be supported with a small set of core files (`main.tf`, `providers.tf`, `variables.tf`, `outputs.tf`) and individual tfvars (Best practice | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781)).  

**Scale potential**  
The concept of Terraform Stacks clearly demonstrates the need for a clear boundary between root configurations and modular components as infrastructure grows (Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)). Skeleton is already consistent with this logic.  

**Repeatability and portability**  
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

### Testing
- `terraform fmt`
- `terraform validate`
- `terraform plan`

## Adds core networking layer for Terraform-based web infrastructure on AWS (Stage 4)

### Changes
- Created a dedicated VPC with CIDR `10.0.0.0/16`, DNS support enabled and basic tagging.
- Added two public subnets (`10.0.1.0/24`, `10.0.2.0/24`) and two private subnets (`10.0.10.0/24`, `10.0.20.0/24`) distributed across the first two Availability Zones in the region.
- Provisioned an Internet Gateway and public route table with a default route `0.0.0.0/0` pointing to the IGW.
- Associated the public subnets with the public route table.

### Rationale
The networking design follows typical AWS and Terraform best practices:
- A dedicated VPC with a `/16` CIDR provides enough address space for future scaling.
- Public and private subnets are spread across two Availability Zones to support high availability.
- The route table uses a correct default route (`0.0.0.0/0`) instead of the weak `0.0.0.0/24` example from the brief, which would only route a tiny fraction of the IPv4 space.

<details> <summary>Terraform plan</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/images/Terraform(IAC)_04_terraform_plan.jpg?raw=true" width="900" alt="terraform_plan"> </details>


### Security Layer, Security Groups (Stage 5) 
Stage introduces security layer for the network by defining two dedicated Security Groups:  
**(1)** - one for public Application Load Balancer (ALB) and  
**(2)** - one for internal EC2 web instances.  
Designed by follows AWS and Terraform security best practices for tiered architectures where ALB acts as the only public entry point, while compute resources remain private.

#### Implemented components
- **ALB Security Group (`alb_sg`)**
  - Ingress: HTTP (`80/tcp`) from `0.0.0.0/0`.
  - Egress: unrestricted outbound traffic.
  - Rationale: ALB is designed to be publicly accessible and to terminate incoming client connections. This mirrors the frontend-layer pattern from multi-AZ and multi-cluster architectures (Best practice | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).

- **EC2 Security Group (`web_sg`)**
  - Ingress:  
    - HTTP (`80/tcp`) **only from the ALB Security Group**.  
    - SSH (`22/tcp`) only from trusted, configurable CIDR (`var.my_ip_cidr`).
  - Egress: unrestricted outbound traffic for updates, AMI metadata and package installs.
  - Rationale: EC2 instances should not be exposed directly to the internet.  
    Traffic flow becomes:
    **Client → ALB → EC2**, matching common AWS patterns for EKS/EC2 workloads (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

#### Reasoning structure choise
- **Layered security** - ALB receives all public traffic, while web servers stay private. This minimizes the attack surface and follows the principle of least privilege.
- **Controlled administrative access** - SSH access is limited to a configurable IP, demonstrating how admin access is locked down in production environments (e.g. VPN, bastion host, corporate IP range).
- **Provider-agnostic pattern** - same SG layout appears in Kubernetes examples on AWS, Azure and GCP when separating public load balancers from worker nodes (Best practice |  
  [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks);  
  [AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks);  
  [GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).

#### Risks
- **SSH exposure risk** - default `0.0.0.0/0` is acceptable in lab environment, but in production it must be restricted to single admin IP or VPN subnet (Risk | unrestricted SSH exposure).
- **Open outbound traffic** - allowing all outbound egress is typical for web-tier instances, but some regulated environments require more restrictive outbound policies (Trade-off | open egress).
- **Missing NAT or private-only subnets (yet)** - EC2 instances in public subnets may rely on public IP for package installation. More secure architecture would use private subnets + NAT Gateway - postponed for simplicity (Trade-off | simplified web-tier setup).

#### Validation
The configuration was validated using the standard Terraform local pipeline:
- `terraform fmt` - formatting
- `terraform validate` - syntax and consistency validation
- `terraform plan` - verification of changes before apply
It checks align with HashiCorp IaC workflows as recomended (Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).

<details> <summary>Validate Terraform</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/images/Terraform(IAC)_05_validate_terraform.jpg?raw=true" width="900" alt="validate_terraform"> </details>

<details> <summary>Terraform plan result</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/images/Terraform(IAC)_06_terraform_plan_result.jpg?raw=true" width="900" alt="terraform_plan_result"> </details>

