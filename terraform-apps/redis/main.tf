provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}

resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis-deployment"
    namespace = kubernetes_namespace.redis.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          name  = "redis"
          image = "redis:latest"
        }
      }
    }
  }
}
