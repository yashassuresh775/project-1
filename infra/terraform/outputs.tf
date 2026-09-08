output "public_ip" {
  value = aws_instance.app.public_ip
}

output "ssh_command" {
  value = "ssh -i <your-key.pem> ubuntu@${aws_instance.app.public_ip}"
}

output "jenkins_url" {
  value = "http://${aws_instance.app.public_ip}:8080"
}

output "app_url" {
  value = "http://${aws_instance.app.public_ip}:5000"
}
