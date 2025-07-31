#!/bin/bash
# crear_ec2.sh
set -e

if [ ! -f infra_ids.txt ]; then
  echo "No se encontró infra_ids.txt. Ejecuta primero crear_red.sh."
  exit 1
fi

source infra_ids.txt
AMI_ID=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" --region $REGION --query 'Images|sort_by(@, &CreationDate)[-1].ImageId' --output text)
KEY_NAME="exxxtasis"

# Si la llave no existe, crea una nueva:
if ! aws ec2 describe-key-pairs --key-names $KEY_NAME --region $REGION >/dev/null 2>&1; then
  aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > ${KEY_NAME}.pem
  chmod 400 ${KEY_NAME}.pem
  echo "Llave $KEY_NAME.pem creada."
fi

echo "Lanzando EC2..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type t2.micro \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --region $REGION \
  --query 'Instances[0].InstanceId' --output text)

aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value="EC2Exxxtasis" --region $REGION

echo "Esperando a que inicie la instancia..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

IP_PUBLICA=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "EC2 lanzada: $INSTANCE_ID"
echo "IP pública: $IP_PUBLICA"

echo $INSTANCE_ID > ec2_id.txt
