provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_secret" "argocd_repo_credentials" {
  metadata {
    name      = "repo-creds"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    "url" = "your-repo-url" # Replace with your Git repository URL
    "sshPrivateKey" = file("path/to/your/private/key") # Your SSH private key
  }
}

resource "kubernetes_config_map" "argocd_cm" {
  metadata {
    name      = "argocd-cm"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    "configManagementPlugins" = <<EOT
    - name: terraform
      init:
        command: ["/usr/local/bin/terraform", "init"]
      generate:
        command: ["/usr/local/bin/terraform", "plan", "-out=tfplan"]
      apply:
        command: ["/usr/local/bin/terraform", "apply", "tfplan"]
    EOT
  }
}

resource "kubernetes_custom_resource" "argocd_applicationset" {
  metadata {
    name      = "sample-applicationset"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  spec = <<EOT
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: sample-applicationset
spec:
  generators:
    - git:
        repoURL: "your-repo-url"
        revision: "main"
        directories:
          - path: "nginx"
          - path: "redis"
          - path: "postgres"
  template:
    metadata:
      name: "{{path}}-app"
    spec:
      project: default
      source:
        repoURL: "your-repo-url"
        path: "{{path}}"
        targetRevision: main
      destination:
        server: "https://kubernetes.default.svc"
        namespace: "{{path}}-namespace"
      syncPolicy:
        automated: {}
EOT
}
