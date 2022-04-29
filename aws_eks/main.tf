locals {
  # Prior to Kubernetes 1.19, the usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  name = "ex-${replace(basename(path.cwd), "_", "-")}"
  tags = { "kubernetes.io/cluster/${module.label.id}" = "shared" }
}

module "label" {
  source = "cloudposse/label/null"
  # Cloud Posse recommends pinning every module to a specific version
  # version  = "x.x.x"

  name       = var.name
  stage      = var.stage
  attributes = ["cluster"]
}

module "vpc" {
  source = "cloudposse/vpc/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  cidr_block = "172.16.0.0/16"

  tags    = local.tags
  context = module.label.context
}

module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  availability_zones   = ["${var.region}a", "${var.region}b"]
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  tags    = local.tags
  context = module.label.context
}


module "eks_node_group" {
  source = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  instance_types                     = ["t2.medium"]
  subnet_ids                         = module.subnets.public_subnet_ids
  min_size                           = 1
  max_size                           = 5
  desired_size                       = 2
  cluster_name                       = module.eks_cluster.eks_cluster_id

  # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
  cluster_autoscaler_enabled = true

  context = module.label.context

  # Ensure the cluster is fully created before trying to add the node group
  module_depends_on = module.eks_cluster.kubernetes_config_map_id
}

module "eks_cluster" {
  source = "cloudposse/eks-cluster/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  region = var.region

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids

  kubernetes_version    = var.kubernetes_version
  oidc_provider_enabled = true

  context = module.label.context
}