output "cluster_name" {
  value = var.cluster_name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_profile" {
  value = var.aws_profile
}

output "backup_bucket_name" {
  value = aws_s3_bucket.backup_bucket.bucket
}

output "aws_region" {
  value = var.aws_region
}

output "bastion_instance_id" {
  value       = aws_instance.bastion.id
  description = "Use this with github.com/relaxdiego/ssh4realz to ssh to the bastion for the first time"
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}


locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.k8s_node_group.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.k8s.endpoint}
    certificate-authority-data: ${aws_eks_cluster.k8s.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
KUBECONFIG
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "kubeconfig" {
  value = local.kubeconfig
}