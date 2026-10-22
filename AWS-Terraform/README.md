# Highly Available Vinyl Store on AWS

An online vinyl record store — **Spin & Groove** — running on a highly available AWS
architecture and deployed entirely with **Terraform**. Built as a DevOps capstone.

![AWS architecture](architecture-diagram.png)

## Architecture

- **Region:** `us-west-2`, spread across two Availability Zones for redundancy
- **VPC** `10.0.0.0/16` with an Internet Gateway
- **Public subnets:** Application Load Balancer (HTTP :80) + NAT Gateway
- **Private subnets:** an Auto Scaling Group of EC2 web servers that serve the storefront
- **Database:** MySQL (MariaDB) on a private EC2 instance, port 3306
- **Security:** a layered chain — Internet → ALB → EC2 fleet → database — so the
  database is never reachable from the internet

> **Note on the database.** The original design used Amazon RDS (Multi-AZ). AWS Academy
> Learner Lab blocks RDS creation, so the project runs MySQL on a private EC2 instance
> instead. The network topology is identical; moving to managed RDS is the production upgrade.

## The storefront

The web fleet serves the **Spin & Groove** front page — a responsive storefront with a
hero, featured records, trust badges, and a **live audio preview** feature: each record
has a play button that synthesizes a short preview in the browser with the Web Audio API
(no audio files to host, no copyright). See `vinyl-store-frontpage-live.html`.

## Deploy

Prerequisites: Terraform ≥ 1.5 and AWS credentials for `us-west-2`.

```bash
cd AWS-Terraform
terraform init
terraform plan
terraform apply          # ~5–10 min; a rolling refresh brings the store online
terraform output wordpress_url
```

Tear it down when finished (stops incurring cost):

```bash
terraform destroy
```

## Repository contents

- `AWS-Terraform/` — the Terraform project (VPC, subnets, IGW, NAT, ALB, Auto Scaling
  Group, security groups, MySQL-on-EC2, and the storefront bootstrap)
- `architecture-diagram.png` — the AWS architecture diagram above
- `vinyl-store-frontpage-live.html` — the deployed storefront (with live audio previews)
- `E-Vinyl Store.pptx` — the final presentation

## Notes

- State and secrets are git-ignored — never commit `terraform.tfstate` or `terraform.tfvars`
  (they contain the generated database password).
- AWS lab credentials are temporary; refresh them before each deploy.
- Capstone by **Houssem**.
