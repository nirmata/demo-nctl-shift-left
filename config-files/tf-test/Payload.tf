# Converted from payload.json (Terraform plan JSON)

resource "aws_instance" "invalid_type" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "r5.24xlarge"

  tags = {
    Environment = "storage-prod"
    Name        = "invalid-instance"
  }
}
