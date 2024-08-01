resource "local_file" "pet" {
	filename = "/Terraform/Test/pets.txt"
	content = "We love pets!"
}