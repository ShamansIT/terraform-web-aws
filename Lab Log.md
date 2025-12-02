## Lab Log

### Stage 1 - Research & Design
- Reviewed official Terraform tutorials for EKS, AKS and GKE to understand common patterns for VPC + multi-AZ + load balancer + worker nodes (Research | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Research | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Research | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  
- Reviewed the AWS EKS multi-cluster blog to understand how similar patterns are applied when applications span multiple clusters and regions (Research | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  
- Chosen a simplified target architecture: a single web “cluster” on EC2 instances spread across two Availability Zones behind an ALB, inspired by multi-AZ patterns from the Kubernetes examples.
***

### Stage 2 - GitHub Repo & Workflow
- Created a public GitHub repository `terraform-web-aws` with `main` as the stable branch and a planned set of `feature/*` branches for individual phases (project init, networking, security+EC2, ALB, modules+CI).  
- Added an initial `README.md` and a Lab Log as a living document to record design decisions and changes over time.  
- Decided to use Pull Requests for each significant change, with structured descriptions (Summary, Changes, Rationale, Testing), mirroring typical Git-based workflows in Terraform/Kubernetes projects (Process | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781); Process | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  
***

### Stage 3 - Terraform Skeleton
- Implemented the base Terraform structure: `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf` and `.gitignore`.  
- Configured the AWS provider with a parameterised `aws_region`, enabling reuse of the configuration across regions without code changes (Pattern | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  
- Ran `terraform init`, `terraform fmt` and `terraform validate` to verify configuration correctness and enforce a consistent code style, following HashiCorp’s recommendations for Terraform projects (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  
- Opened a Pull Request **"Initialize Terraform project structure"** as the first step in a fully scripted IaC pipeline, ensuring that all subsequent infrastructure changes will be tracked, discussed and reviewed via GitHub.

### Stage 4 - Network Layer (VPC, Subnets, IGW, Routing)
- Implemented the core networking layer: one VPC (`10.0.0.0/16`), two public subnets (`10.0.1.0/24`, `10.0.2.0/24`), two private subnets (`10.0.10.0/24`, `10.0.20.0/24`) across two Availability Zones, following multi-AZ patterns used in Kubernetes/Terraform examples (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  
- Added an Internet Gateway and a public route table with a correct default route `0.0.0.0/0`, explicitly improving on the weaker `0.0.0.0/24` example from the brief and aligning with standard AWS routing practice (Best practice | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  
- Associated public subnets with the public route table to enable internet access for future web and ALB resources in a way that is compatible with typical EKS-style architectures (Pattern | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781)).  
- Validated the configuration using `terraform fmt`, `terraform validate`, `terraform plan` to ensure the networking layer is consistent and ready for reuse in higher layers (Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

### Stage 5 - Security Layer, Security Groups
- Defined two Security Groups: `alb_sg` for the public Application Load Balancer and `web_sg` for the internal web EC2 instances, following a layered security model where the ALB is the only public entry point (Best practice | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  
- Allowed HTTP (80) from the internet only to the ALB, while restricting HTTP on EC2 to traffic coming from the ALB Security Group, mirroring frontend/backend separation used in many Terraform+EKS reference architectures (Pattern | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  
- Configured SSH (22) access to EC2 instances via a configurable `my_ip_cidr` variable to illustrate how administrative access can be limited to trusted sources such as a VPN or corporate IP range (Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  
- Verified the configuration with `terraform fmt`, `terraform validate` and `terraform plan` to ensure the security layer is consistent and ready for attaching EC2 instances (Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

### Stage 6 - Compute Layer (EC2 Web Cluster + user_data)
- Provisioned two Amazon Linux 2 EC2 instances (`web_a`, `web_b`) in separate public subnets across two Availability Zones to form a simple HA web cluster, using patterns similar to worker node placement in EKS-based designs (Pattern | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Pattern | [AWS EKS multi-cluster blog](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  
- Attached the previously defined `web_sg` Security Group so that HTTP traffic is only allowed from the ALB and SSH access is restricted via `my_ip_cidr`, consistent with common security recommendations for web/worker nodes (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  
- Implemented the `userdata-web.sh` script to automate instance provisioning: updating packages, installing nginx, enabling the service and rendering a custom HTML page with instance metadata (Instance ID and Availability Zone), following the idea of reproducible node bootstrapping seen in Kubernetes and Terraform examples (Pattern | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Pattern | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781)).  
- Verified the setup using `terraform fmt`, `terraform validate`, `terraform plan` and `terraform apply`, and confirmed that both instances serve the lab page over HTTP via their public IPs, which validates the end-to-end provisioning chain from IaC to running web nodes (Best practice | [Terraform Stacks blog](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

***
## Prerequisites
- Terraform >= 1.7
- AWS account with appropriate IAM permissions
- AWS CLI configured (`aws configure`)
- Git + GitHub account
***