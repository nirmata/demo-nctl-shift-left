#!/bin/bash

# Function to install Terraform
install_terraform() {
    echo "Installing Terraform..."
    # Download Terraform binary
    wget https://releases.hashicorp.com/terraform/0.15.0/terraform_0.15.0_linux_amd64.zip
    # Unzip the downloaded file
    unzip terraform_0.15.0_linux_amd64.zip
    # Move Terraform binary to /usr/local/bin
    sudo mv terraform /usr/local/bin/
    echo "Terraform installed successfully."
}

# Function to run Terraform commands
run_terraform_commands() {
    cd config-files/terraform/eks
    echo "Running Terraform commands..."
    # Initialize Terraform in the directory where your configuration files are located
    terraform init
    # Plan the changes Terraform will make
    terraform plan -out tfplan.binary
    # Store in JSON
    terraform show -json tfplan.binary | jq > payload.json
    echo "Terraform commands executed successfully."
}

# Check if Terraform is already installed
if command -v terraform &> /dev/null; then
    echo "Terraform is already installed."
    run_terraform_commands
else
    install_terraform
    run_terraform_commands
fi

