output "instanceID" {
  description = " Instance ID: "
  value = aws_instance.myinstance.tags.Name
}

output "instanceType" {
  description = "Type of the Instance : "
  value = aws_instance.myinstance.instance_type
}
