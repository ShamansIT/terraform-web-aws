# terraform-web-aws
Developing highly available Web infrastructure on AWS using Terraform

## Introduction
Project demonstrates the creation of a high-availability web infrastructure on AWS using Terraform.  

Architecture includes a **VPC**, public and private **subnets**, **security groups**, two **EC2 web instances** in different **Availability Zones**, and an **Application Load Balancer (ALB)** for traffic distribution.  The implementation templates approach is provide in production environments for managed Kubernetes clusters (EKS/AKS/GKE), but is implemented in a simplified form based on EC2 nodes (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  

Solution applies the principles of **Infrastructure as Code**, modular configuration structure, and Git-oriented workflow with **feature branches** and **Pull Requests**, which aligns this student project with real DevOps practices (Best practice | [AWS EKS multi-cluster explained](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/); Best practice | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).

## Tech Stack
- **Terraform** (Infrastructure as Code)
- **AWS** (VPC, EC2, ALB, Security Groups)
- **Git + GitHub** (branching, Pull Requests, code review)
- **GitHub Actions** for `terraform fmt` and `terraform validate`

## Architecture

Simplified Target Architecture:
- **VPC**: `10.0.0.0/16`
  - `public-1` (10.0.1.0/24) - AZ1
  - `public-2` (10.0.2.0/24) - AZ2
  - `private-1` (10.0.10.0/24) - AZ1
  - `private-2` (10.0.20.0/24) - AZ2
- **EC2 web cluster**:
  - 2 x Amazon Linux 2, one instance in each public subnet
  - nginx is set via 'user_data'
- **Security Groups**:
  - `alb_sg`: HTTP 80 from the Internet to ALB
  - `web_sg`: HTTP 80 only from 'alb_sg'; SSH 22 is limited to the developer's IP address
- **Application Load Balancer**:
  - 80 port listener
  - Target Group with health-check
  - round-robin balancing between EC2

The pattern corresponds to typical solutions for EKS/AKS/GKE, but is implemented on EC2 for simplicity. (Research | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)), (Research | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks)), (Research | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke))

## Repository structure
```text
terraform-web-aws/
├─ main.tf                 # Root composition: modules + SG + outputs
├─ providers.tf            # AWS provider
├─ variables.tf            # Input variables
├─ outputs.tf              # Global outputs
├─ userdata-web.sh         # user_data для web EC2 (nginx + HTML)
├─ README.md               
├─ modules/
│  ├─ vpc/
│  │  └─ main.tf          # VPC, subnets, IGW, route table + assoc
│  ├─ web/
│  │  └─ main.tf          # EC2 web cluster + user_data
│  └─ alb/
│     └─ main.tf          # ALB, Target Group, Listener, attachments
└─ .github/
   └─ workflows/
      └─ terraform.yml     # CI для fmt + validate на PR
```

## Prerequisites
- Terraform >= 1.7
- AWS account with appropriate IAM permissions
- AWS CLI configured (`aws configure`)
- Git + GitHub account

## Research & Design (Stage 1)
Initial research focused on understanding common IaC and networking patterns from official Terraform Kubernetes tutorials (Research | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); [AKS](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); [GKE](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)) and resilient multi-cluster architectures (Research | [AWS EKS multi-cluster explained](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  
Based on this, the project scope was defined as a simplified HA web stack on EC2 across two Availability Zones, with an ALB in front.

<details> <summary>AWS Configure</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_01_aws_configure.jpg?raw=true" width="900" alt="aws_configure"> </details>


## GitHub Repo & Workflow (Stage 2)
Public GitHub repository `terraform-web-aws` created with `main` as the stable branch and dedicated `feature/*` branches for each phase (project init, networking, security+EC2, ALB, modules+CI).  
A Git-based workflow with structured Pull Requests (Summary, Changes, Rationale, Testing) was adopted to mirror real-world Terraform/Kubernetes projects and to make the evolution of the infrastructure transparent (Process | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781); [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

<details> <summary>Init Terraform</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_02_init_terraform.jpg?raw=true" width="900" alt="init_terraform"> </details>

<details> <summary>Validate Terraform</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_03_validate_terraform.jpg?raw=true" width="900" alt="validate_terraform"> </details>

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
  - Maintains the minimalism of the root module and prepares it for further division into modules or stacks (Best practice | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

- `outputs.tf`  
  - Currently contains a placeholder comment.  
  - The presence of this file from the very beginning helps to determine in advance which values (e.g. 'alb_dns_name' or IP addresses of the instances) should act as a "contract" between the infrastructure and external tools (CI/CDs, scripts) (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).  

- `.gitignore`  
  - Ignores '.terraform/', 'terraform.tfstate', 'terraform.tfstate.backup', '*.tfvars' and similar artifacts.  
  - It`s critical for keeping state and potential secrets outside the repository and for ensuring a clean Git history (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

### Structure Explanation

**Compliance with real EKS projects**  
David Muñoz's article shows that even complex infrastructures can be supported with a small set of core files (`main.tf`, `providers.tf`, `variables.tf`, `outputs.tf`) and individual tfvars (Best practice | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781)).  

**Scale potential**  
The concept of Terraform Stacks clearly demonstrates the need for a clear boundary between root configurations and modular components as infrastructure grows (Best practice | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)). Skeleton is already consistent with this logic.  

**Repeatability and portability**  
Conceptually preserved common Terraform-workflow patterns (init -> format -> validate -> plan -> apply), which coincides with the approach in multi-cloud Kubernetes projects (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  

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
  - Providers, variables, outputs, and future resources are divided between files, which simplifies the readability of the root module and facilitates further modulation (Best practice | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

- **Ready for multi-cluster / multi-region templates**  
  - Skeleton is aligned with the guidelines from the AWS EKS multi-cluster blog, even if the target is currently one "web cluster" (Best practice | [AWS EKS multi-cluster explained](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  

- **Collaborative workflow with Kubernetes projects**  
  - Adherence to principles similar to EKS/AKS/GKE examples makes the transition to Kubernetes in the future easier (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).  

### Risks and limitations
- **Focus on one account or region**  
  - At this moment **skeleton** does not have a backend configuration for multi-region/multi-account scenarios (Risk | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).  

- **Local state**  
  - In the case of local 'terraform.tfstate', there is a risk of:
    - State losses,  
    - conflict changes in teamwork,  
    - more complex rollback.  
  - Remote backend (S3 + DynamoDB) eliminates these shortcomings, but on the contrary, adds complexity to the project.  

- **Pinned versions need maintenance**  
  - AWS provider requires change monitoring (Risk | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781)).  

- ** Terraform and the risk of first-stage errors**  
  - Even starting stage construction requires an understanding of state, dependency graph, and lifecycle semantics (Risk | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Risk | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)). 

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

<details> <summary>Terraform plan</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_04_terraform_plan.jpg?raw=true" width="900" alt="terraform_plan"> </details>


### Security Layer, Security Groups (Stage 5) 
Stage introduces security layer for the network by defining two dedicated Security Groups:  
**(1)** - one for public Application Load Balancer (ALB) and  
**(2)** - one for internal EC2 web instances.  
Designed by follows AWS and Terraform security best practices for tiered architectures where ALB acts as the only public entry point, while compute resources remain private.

#### Implemented components
- **ALB Security Group (`alb_sg`)**
  - Ingress: HTTP (`80/tcp`) from `0.0.0.0/0`.
  - Egress: unrestricted outbound traffic.
  - Rationale: ALB is designed to be publicly accessible and to terminate incoming client connections. This mirrors the frontend-layer pattern from multi-AZ and multi-cluster architectures (Best practice | [AWS EKS multi-cluster explained](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).

- **EC2 Security Group (`web_sg`)**
  - Ingress:  
    - HTTP (`80/tcp`) **only from the ALB Security Group**.  
    - SSH (`22/tcp`) only from trusted, configurable CIDR (`var.my_ip_cidr`).
  - Egress: unrestricted outbound traffic for updates, AMI metadata and package installs.
  - Rationale: EC2 instances should not be exposed directly to the internet.  
    Traffic flow becomes:
    **Client -> ALB -> EC2**, matching common AWS patterns for EKS/EC2 workloads (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

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
It checks align with HashiCorp IaC workflows as recomended (Best practice | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).

<details> <summary>Validate Terraform</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_05_validate_terraform.jpg?raw=true" width="900" alt="validate_terraform"> </details>

<details> <summary>Terraform plan result</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_06_terraform_plan_result.jpg?raw=true" width="900" alt="terraform_plan_result"> </details>

### Compute Layer, EC2 Web Cluster (Stage 6)
Stage adds the compute layer: small web cluster of two EC2 instances distributed across two Availability Zones.  
Both instances are configured automatically on boot via a `user_data` script that installs and configures nginx, so each node becomes a self-contained web server without manual intervention.  
This approach mirrors how worker nodes are provisioned for Kubernetes/EKS clusters, but is implemented here in a simplified form using EC2 instances (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

#### Implemented components
- **AMI selection (`data "aws_ami" "amazon_linux"`)**  
  - Uses a data source to fetch the latest Amazon Linux 2 AMI in the target region, instead of hardcoding a fixed AMI ID.  
  - Filters by name pattern `amzn2-ami-hvm-*-x86_64-gp2` and virtualization type `hvm`, which follows typical recommendations for small web loads (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

- **Bootstrap script (`userdata-web.sh`)**  
  - Updates system packages.  
  - Installs and enables nginx.  
  - Reads instance metadata (Instance ID, Availability Zone) through HTTP-endpoint `169.254.169.254`.  
  - Generates a simple HTML page from:		
    - Instance ID,
    - Availability Zone,
    - name and student ID.  
  Each instance configures itself at startup and is immediately ready to process HTTP requests.

- **Two EC2 instances (`aws_instance.web_a`, `aws_instance.web_b`)**  
  - Both use Amazon Linux 2 AMI with data source.  
  - `web_a` deployed in `public_a` subnet (First AZ), `web_b` - in `public_b` subnet (Other AZ).  
  - Both apply the 'web_sg' Security Group with which it was implemented earlier.  
  - `user_data` connected via `file("${path.module}/userdata-web.sh")`, which ensures the same setup process for each node.  
  - Enabled 'associate_public_ip_address = true' for simplified testing over public IPs.

#### Reasoning design choices
- **High availability via two AZ**  
  - Distribution of instances between the first two Availability Zones in the region follows the multi-AZ pattern described in the examples for EKS and multi-cluster solutions (Best practice | [AWS EKS multi-cluster explained](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  
  - Losing one AZ does not cause the web layer to stop altogether - the second instance remains available.

- **Automated setup via 'user_data'**  
  - The structured and consistent configuration of nginx and HTML pages occurs automatically at the stage of launching the instance, without manual steps.  
  - This approach simplifies the reproducibility of the environment: any new instance in this cluster automatically becomes a website with the same configuration (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

- **Displaying metadata on a page**  
  - Displaying the Instance ID and Availability Zone directly to the HTML page makes it easy to debug and demonstrate: it's easy to see which instance the response came from.  
  - It also shows the use of the metadata service as practical tool for diagnosing and personalising node's response.

- **Alignment with Kubernetes/EKS-based clusters**  
  - Although regular EC2 is used here, the structure is very close to the approach with worker nodes in EKS:  
    - one type of AMI,  
    - automatic configuration at the start,  
    - distribution by A-Z (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

#### Risks
- **Free Tier Cost and Limitations**  
  - Two 't3.micro' or 't2.micro' instances can go beyond the free tier if they run continuously. For a training project, it is important to disable or destroy instances after the tests are completed (Risk | Unnecessary EC2 costs).
- **Deploying to public subnets**  
  - The current implementation deploys web instances on public subnets with public IPs to simplify testing.  
  - In a more secure architecture, the web layer is hosted in private subnets behind the NAT Gateway and ALB (Trade-off | Simplified schema without NAT).
- **Using 'user_data' as the main configuration engine**  
  - `user_data' is good for initial bootstrapping, but as the complexity of configurations increases, they often move to tools like configuration managers or pre-built images (Trade-off | Limitations of imperative scripts).
- **Lack of Auto Scaling Group**  
  - Two static instances exhibit basic fault tolerance, but do not automatically scale when the load changes.  
  - The next logical step is to transfer this logic to the Auto Scaling Group from the Launch Template, which follows the typical recommendations for production architectures (Potential improvement | transition to ASG).

#### Validation
Configuration was validated and tested as follows:
- `terraform fmt`- checking and aligning configuration formatting.  
- `terraform validate`- basic syntax and consistency check.  
- `terraform plan`- analyse changes before deployment.  
- `terraform apply`- creating both instances and checking nginx availability over public IPs, including displaying the Instance ID and Availability Zone on HTML page.

<details> <summary>AWS instance check</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_07_aws_instance_check.jpg?raw=true" width="900" alt="aws_instance_check"> </details>

### Load Balancing Layer (Stage 7)
This stage adds an internet-facing **Application Load Balancer (ALB)** that distributes HTTP traffic across the two EC2 web instances, each deployed in a different Availability Zone.  
The goal is to move from direct instance access to a single, stable entry point and to mirror how load balancers are typically used in modern cloud architectures (LB -> nodes) in environments such as EKS, AKS and GKE (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks); Best practice | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).

#### Implemented components
- **Application Load Balancer (`aws_lb.web_alb`)**
  - Type: `application` (ALB), internet-facing (`internal = false`).
  - Placed in two public subnets (`public_a`, `public_b`) across different Availability Zones.
  - Uses the existing `alb_sg` Security Group, which allows HTTP (`80/tcp`) from the internet.
  - This configuration aligns with the standard pattern of placing the load balancer in public subnets while keeping application nodes behind it (Best practice | [AWS EKS multi-cluster explained](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).

- **Target Group (`aws_lb_target_group.web_tg`)**
  - Protocol: HTTP, port 80, attached to the same VPC as the web instances.
  - Health checks configured on `/` using HTTP 200 as the expected result.
  - Health check interval, timeout and thresholds are tuned for a small lab environment while still demonstrating how ALB monitors backend health and automatically removes unhealthy targets from rotation (Pattern | [AWS EKS Medium article](https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781)).

- **Target Attachments (`aws_lb_target_group_attachment`)**
  - Both EC2 web instances (`web_a`, `web_b`) are attached as targets on port 80.
  - This turns the earlier “static” web cluster into proper backend pool for the load balancer and completes the LB -> nodes flow (Pattern | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

- **HTTP Listener (`aws_lb_listener.http`)**
  - Listens on port 80 and forwards all HTTP traffic to `web_tg`.
  - This configuration models prevalent scenario in Kubernetes-style setups where an external load balancer terminates incoming requests and routes them to worker nodes or services (Best practice | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Best practice | [Terraform AKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks)).
- **Output (`alb_dns_name`)**
  - Exposes the ALB DNS name as a Terraform output so it can be used directly in testing, documentation and potential monitoring configuration.

#### Reasoning design choices
- **Single public entry point instead of direct EC2 access**  
  The ALB becomes the **only** public endpoint. End users never connect to EC2 instances directly; instead, they call `http://<alb_dns_name>`.  
  This allows:
  - decoupling client traffic from individual instance lifecycles;
  - seamless replacement or scaling of instances without changing the public URL;
  - centralised health checking and routing logic.

- **Cross-AZ load distribution**  
  Because the ALB is attached to public subnets in two Availability Zones and the target group includes instances in both AZs, traffic is distributed across zones.  
  This is consistent with high-availability guidelines described in AWS multi-cluster and multi-AZ examples (Best practice | [AWS EKS multi-cluster explained](https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/)).  

- **Health checks on `/`**  
  Using `/` as the health check path is sufficient for a simple nginx-based demo where the main page is served from the default root.  
More complex systems often use a separate '/health' endpoint with additional application checks, but for this project, a basic check gives enough signal that the node is running.

- **Alignment with EKS/AKS/GKE load balancing concepts**  
Even though the backend here is EC2 rather than containers, the architecture closely resembles Kubernetes setup: external load balancer -> target group (or service) -> nodes/pods.  
This makes it easier to extend the current design towards container-based orchestration in the future (Pattern | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks); Pattern | [Terraform GKE tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke)).

#### Risks
- **No TLS termination (HTTP only)**  
The current ALB listener operates on plain HTTP.  
For production environment, HTTPS with proper TLS certificates (ACM) would be mandatory. Here, HTTP is used to keep the lab configuration simple (Trade-off | simplified transport security).

- **Health check path and depth**  
Health checks on `/` only verify that nginx returns HTTP 200, but do not test application-level logic.  
In more advanced scenario, separate health endpoints and deeper checks should be used (Risk | limited health visibility).

- **Cost considerations**  
An ALB has an hourly cost and charges per LCU usage. While acceptable for a short-lived lab, it is important to tear down resources after testing to avoid unnecessary charges (Risk | additional ALB cost).

- **Static backend set**  
Target group currently attaches two fixed instances.  
Natural extension is to replace direct attachments with an Auto Scaling Group and a Launch Template, so the load balancer can work with dynamically scaled capacity (Potential improvement: move to ASG).

#### Validation
Configuration was validated and tested using:
- `terraform fmt` - formatting of configuration files.
- `terraform validate` - basic syntax and consistency checks.
- `terraform plan` - dry-run to preview ALB/target group changes.
- `terraform apply` - deployment of ALB and its integration with the web cluster.
- Manual tests:
  - Opening `http://<alb_dns_name>` in a browser to confirm page availability.
  - Refreshing the page multiple times and observing responses from different Availability Zones, confirming that the ALB balances traffic across both web instances.

<details> <summary>Check ALB</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_08_check_ALB.jpg?raw=true" width="900" alt="check ALB"> </details>

<details> <summary>Check ALB http</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_09_check_ALB_http.jpg?raw=true" width="900" alt="check ALB http"> </details>

### Modular Architecture & CI Integration (Stage 8)

Stage refactors the existing Terraform configuration into fully isolated modules for the VPC, EC2 web cluster, and ALB, and updates the root layer to a clean composition module following modern Terraform Stacks patterns. This improves maintainability, readability, CI integration and aligns the project with real multi-module IaC workflows seen in EKS/AKS/GKE infrastructures (Best practice | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained); Pattern | [Terraform EKS tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

#### Implemented components
- **VPC Module (`modules/vpc`)**  
  - Migrated VPC, subnets, IGW, route tables and associations into a dedicated module.  
  - Structure mirrors network-layer modularisation used in Kubernetes IaC templates  
    (Pattern | [Terraform EKS tutorial - VPC module](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)).

- **Web Module (`modules/web`)**  
  - Moved both EC2 instances, AMI lookup and user_data logic from root into a standalone module.  
  - Ensures clean separation between the compute layer and networking/load balancing  
    (Pattern | [Terraform AKS tutorial - workload modules](https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks)).

- **ALB Module (`modules/alb`)**  
  - Created a module containing ALB, Target Group, Listener, and target attachments.  
  - Follows industry patterns of extracting load balancing into its own module  
    (Pattern | [terraform-aws-alb](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest)).

- **Root Composition Layer (`main.tf`)**  
  - Root no longer contains resources; only module calls, high-level Security Groups and outputs.  
  - Aligns with Terraform “Stacks” pattern where root orchestrates submodules  
    (Best practice | [Terraform Stacks explained](https://www.hashicorp.com/en/blog/terraform-stacks-explained)).

- **Unified Tagging via `locals`**  
  - Added `Environment`, `Project`, `Owner`, `Component`, `Tier`, `Role` tags.  
  - Applied consistently across modules following cloud governance guidance  
    (Best practice | [AWS Tagging Best Practices](https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/tagging-best-practices.html)).

- **Refactor Validation via Plan/Apply Cycle**  
  - First `apply` recreated resources due to structural change.  
  - Subsequent `terraform plan` showed **No changes**, confirming architectural equivalence  
    (Best practice | [Terraform refactoring guide](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)).

<details> <summary>Terraform rebuid</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_10_terraform_rebuild.jpg?raw=true" width="900" alt="Terraform rebuid"> </details>
    

#### Reasoning design choices
- **Separation of concerns** - networking, compute and load balancing fully isolated, mirroring real-world IaC structures in Kubernetes/EKS templates.  
- **Predictability and CI readiness** - more precise module boundaries enable GitHub Actions validation and easier future testing.  
- **Improved maintainability** - root module remains minimal; scaling to ASG, NAT, or TLS listener upgrades becomes trivial.  
- **Reusable building blocks** - modules can now be reused across regions or different training projects.

#### Risks
- **Refactor triggers resource recreation**  
  Expected behaviour during modularisation; safe here but must be monitored in real production environments.  
- **Module versioning not yet implemented**  
  Future improvement: pin module versions for more controlled updates.  
- **Locals must remain consistent**  
  Misalignment of tags across modules can affect cost visibility and governance.

#### Validation
- `terraform fmt` - unified formatting  
- `terraform validate` - module-level syntax validation  
- `terraform plan` - ensured no further drifts after initial recreation  
- `terraform apply` - successful deployment of fully modular architecture  
- confirmed that ALB, EC2 cluster and VPC generated an identical final architecture with a cleaner internal structure

<details> <summary>Instances</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_11_instances.jpg?raw=true" width="900" alt="Instances"> </details>

<details> <summary>HTTP check</summary> <img src="https://github.com/ShamansIT/terraform-web-aws/blob/main/images/Terraform(IAC)_12_terraform_http_check.jpg?raw=true" width="900" alt="HTTP check"> </details>


## Conclusion




## References

1. AWS (2023) *AWS Tagging Best Practices*.  
   Available at: https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/tagging-best-practices.html  
   (Accessed: 21 November 2025).

2. AWS (2023) *Building resilient multi-cluster applications with Amazon EKS*.  
   Available at: https://aws.amazon.com/blogs/networking-and-content-delivery/building-resilient-multi-cluster-applications-with-amazon-eks/  
   (Accessed: 05 November 2025).

3. HashiCorp (2022) *Terraform Stacks Explained*.  
   Available at: https://www.hashicorp.com/blog/terraform-stacks-explained  
   (Accessed: 03 November 2025).

4. HashiCorp (2023) *Developing Terraform Modules: Module Structure and Best Practices*.  
   Available at: https://developer.hashicorp.com/terraform/language/modules/develop  
   (Accessed: 18 November 2025).

5. HashiCorp (2023) *Terraform CLI - Plan Workflow*.  
   Available at: https://developer.hashicorp.com/terraform/cli/run/plan  
   (Accessed: 26 November 2025).

6. HashiCorp (2023) *Terraform Language: Locals*.  
   Available at: https://developer.hashicorp.com/terraform/language/values/locals  
   (Accessed: 24 November 2025).

7. HashiCorp (2023) *Terraform Module Refactoring Guide*.  
   Available at: https://developer.hashicorp.com/terraform/language/modules/develop/refactoring  
   (Accessed: 29 November 2025).

8. HashiCorp (2023) *Terraform Tutorial: Amazon EKS (Kubernetes on AWS)*.  
   Available at: https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks  
   (Accessed: 06 November 2025).

9. HashiCorp (2023) *Terraform Tutorial: Azure AKS (Kubernetes on Azure)*.  
   Available at: https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks  
   (Accessed: 08 November 2025).

10. HashiCorp (2023) *Terraform Tutorial: Google GKE (Kubernetes on Google Cloud)*.  
    Available at: https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke  
    (Accessed: 09 November 2025).

11. Muñoz, D. (2022) *AWS Elastic Kubernetes Service (EKS) - Architecture and Deployment Patterns*.  
    Medium. Available at: https://medium.com/@david.e.munoz/aws-elastic-kubernetes-service-eks-e5f4c00b3781  
    (Accessed: 02 December 2025).

12. Terraform AWS Modules Community (2023) *terraform-aws-alb module*.  
    Available at: https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest  
    (Accessed: 06 December 2025).
