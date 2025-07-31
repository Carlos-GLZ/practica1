#!/bin/bash
# crear_red.sh
set -e

REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
TAG="RedExxxtasis"

echo "Creando VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$TAG --region $REGION

echo "Creando Subnet pública..."
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --region $REGION --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value=$TAG-public --region $REGION

echo "Creando y asociando Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway --region $REGION --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID --region $REGION

echo "Creando Route Table y asociando a subnet..."
RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --resources $RT_ID --tags Key=Name,Value=$TAG-rt --region $REGION
aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET_ID --region $REGION
aws ec2 create-route --route-table-id $RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION

echo "Creando Security Group abierto a HTTP y SSH..."
SG_ID=$(aws ec2 create-security-group --group-name $TAG-sg --description "SG para $TAG" --vpc-id $VPC_ID --region $REGION --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION

# Guarda IDs para otros scripts
cat > infra_ids.txt <<EOF
REGION=$REGION
VPC_ID=$VPC_ID
SUBNET_ID=$SUBNET_ID
IGW_ID=$IGW_ID
RT_ID=$RT_ID
SG_ID=$SG_ID
EOF

echo "Infraestructura de red creada y IDs guardados en infra_ids.txt"
