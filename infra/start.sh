# Install AZ CLI
if ! command -v az > /dev/null; then
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# Authenticate
az login

# Move to tf
cd tf/

CMD=$1
ENV=$2

runTerraform()
{
  case $CMD in
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
  *)
    echo "Not Found Command"
  esac
}

if [ "$CMD" == "plan" -o "$CMD" == "apply" ]; then
  if [ $ENV == "staging" -o $ENV == "production" ]; then
    if grep "environment" env.tfvars; then
      grep -v "environment" env.tfvars > tmpfile && mv tmpfile env.tfvars
    fi
    echo 'environment = "'$ENV'"' >> env.tfvars
    runTerraform
  else
    echo "Please enter environment 'staging' or 'production'"
  fi
else
  runTerraform
fi
