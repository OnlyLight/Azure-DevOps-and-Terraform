# Install AZ CLI
if ! command -v az > /dev/null; then
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# Authenticate
# az login

# Move to tf
cd tf/

if grep "environment" env.tfvars; then
  grep -v "environment" env.tfvars > tmpfile && mv tmpfile env.tfvars
fi
echo 'environment = "'$1'"' >> env.tfvars

case $2 in
"init")
  terraform init
  ;;
"plan")
  terraform plan -var-file="env.tfvars"
  ;;
"apply")
  terraform apply -var-file="env.tfvars" -auto-approve
  ;;
"destroy")
  terraform destroy -var-file="env.tfvars" -auto-approve
  ;;
esac

