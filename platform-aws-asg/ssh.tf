resource "tls_private_key" "ssh-key-pair" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ssh-key" {
  public_key = "${tls_private_key.ssh-key-pair.public_key_openssh}"
}

resource "null_resource" "write_ssh_key" {
  triggers {
    ssh_key = "${tls_private_key.ssh-key-pair.private_key_pem}"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh-key-pair.private_key_pem}' > ${path.cwd}/generated/ssh-key.pem && chmod 0600 ${path.cwd}/generated/ssh-key.pem"
  }

  provisioner "local-exec" {
    command = "ssh-add ${path.cwd}/generated/ssh-key.pem"
  }
}
