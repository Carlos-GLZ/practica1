#!/bin/bash
# eliminar_red.sh
set -e

if [ ! -f infra_ids.txt ]; then
  echo "No se encontró infra_ids.txt. Ejecuta primero el script de creación."
  exit 1
fi

source infra_ids.txt

echo "Eliminando recursos..."

aws ec2 disassociate-route-table --association-id $(aws ec2 describe-route-tables --route-table-ids $RT_ID --region $REGION --query 'RouteTables[0].Associations[0].RouteTableAssociationId' --output text) --region $REGION || true

aws ec2 delete-route-table --route-table-id $RT_ID --region $REGION || true
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION || true
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region $REGION || true
aws ec2 delete-subnet --subnet-id $SUBNET_ID --region $REGION || true
aws ec2 delete-security-group --group-id $SG_ID --region $REGION || true
aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION || true

echo "Red eliminada."
rm -f infra_ids.txt
