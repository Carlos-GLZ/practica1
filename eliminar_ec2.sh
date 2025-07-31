#!/bin/bash
# eliminar_ec2.sh
set -e

if [ ! -f ec2_id.txt ]; then
  echo "No se encontró ec2_id.txt. Ejecuta primero crear_ec2.sh."
  exit 1
fi

INSTANCE_ID=$(cat ec2_id.txt)
REGION=$(grep REGION infra_ids.txt | cut -d= -f2)

echo "Eliminando instancia $INSTANCE_ID..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID --region $REGION
rm -f ec2_id.txt
echo "EC2 eliminada."
