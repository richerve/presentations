output "vpc_cidr" {
  value = "${aws_vpc.main.cidr_block}"
}

output "image_id" {
  value = "${data.aws_ami.ubuntu_1604_latest.image_id}"
}

output "subnet_2b_cidr" {
  value = "${aws_subnet.main.1.cidr_block}"
}

output "instance_private_dns_names" {
  value = "${aws_instance.main.*.private_dns}"
}
