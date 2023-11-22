output "instanceID" {
  description = " Instance ID: "
  value = aws_instance.myinstance.tags.Name
}

output "instanceType" {
  description = "Type of the Instance : "
  value = aws_instance.myinstance.instance_type
}

output "instanceState" {
  description = "State of the Instance : "
  value = aws_instance.myinstance.instance_state
}

output "publicIP" {
  description = "Public IP address : "
  value = aws_instance.myinstance.public_ip
}

output "privateIP" {
  description = "Private IP address : "
  value = aws_instance.myinstance.private_ip
}
