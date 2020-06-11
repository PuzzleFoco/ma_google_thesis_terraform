provider "google" {
    credentials = file("${path.module}/${var.credential_file_name}")
    region  = var.location
    zone    = "${var.location}-${var.zone}"
}

module "gke" {
    source = "git::git@gitlab.hrz.tu-chemnitz.de:faeng--tu-chemnitz.de/terraform-google-kubernetes.git"

    gke_cluster_name    = "googleexamplecluster"
    location            = var.location
    project             = var.project_id
    min_master_version  = "1.15.9-gke.24"

}

provider "kubernetes" {
  version                = "1.11.1"

  load_config_file = false

  host                   = module.gke.host
  client_certificate     = base64decode(module.gke.client_certificate)
  client_key             = base64decode(module.gke.client_key)
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  username = module.gke.cluster_username
  password = module.gke.cluster_password
}

provider "helm" {
    version = "~>1.0.0"

    kubernetes {
      host                   = module.gke.host

      client_certificate     = base64decode(module.gke.client_certificate)
      client_key             = base64decode(module.gke.client_key)
      cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
      load_config_file       = false
      username = module.gke.cluster_username
      password = module.gke.cluster_password
  }
}

module "google_dns_zone" {
    source  = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/terraform_google_dns_zone.git"

    name            = "masterthesis-dns-zone"
    dns_name        = "${var.root_domain}."
    description     = "DNS Zone for masterthesis.online"
    project         = var.project_id
    public_ip_name  = "masterthesisonlineipaddress"
    location        = var.location
}

module "nginx" {
    source         = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/terraform_nginx_helm.git"

    controller_service = {
      "enabled"        : "true",
      "loadBalancerIP" : module.google_dns_zone.ip_address,
    }

    annotations    = [
        {
          "annotation_key" : "kubernetes.io/ingress.global-static-ip-name",
          "annotation_value" : "masterthesisonlineipaddress"
        }
      ]
}

module "jenkins" {
  source  = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/jenkins_terraform_module.git"

  credentials = var.credentials
  host_name   = "jenkins.${var.root_domain}"
}

module "cert-manager" {
  source  = "git::https://gitlab.hrz.tu-chemnitz.de/faeng--tu-chemnitz.de/terraform_cert_manger_google.git"

  cluster_name            = module.gke.cluster_name
  root_domain             = var.root_domain
  lets_encrypt_email      = var.email
  project_id              = var.project_id
  account_id              = var.account_id
  location                = var.location
  acme_server_url         = "https://acme-staging-v02.api.letsencrypt.org/directory"
}