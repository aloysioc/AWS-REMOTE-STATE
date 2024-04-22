# Criar vpc para esta infra-estrutura
resource "aws_vpc" "ce_vpc" {
  cidr_block           = "10.0.0.0/16" # Bloco CIDR da VPC
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CE-Mapfre-VPC"
  }
}

# Criar sub-redes em 3 zonas de disponibilidade
resource "aws_subnet" "ce_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.ce_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "CE-Mapfre-subnet-${count.index}"
  }
}

# Criar um gateway de internet
resource "aws_internet_gateway" "ce_igw" {
  vpc_id = aws_vpc.ce_vpc.id

  tags = {
    Name = "CE-Mapfre-Igw"
  }
}

# Criar tabela de rotas
resource "aws_route_table" "ce_route" {
  vpc_id = aws_vpc.ce_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ce_igw.id
  }

  tags = {
    Name = "CE-Mapfre-route-tables"
  }

}

# Associar rota do gateway de internet para cada subnet criada
resource "aws_route_table_association" "ce_route_associations" {
  count          = 3
  subnet_id      = tolist(aws_subnet.ce_subnets.*.id)[count.index]
  route_table_id = aws_route_table.ce_route.id
}

#Criação do SG para esta infra-estrutura
resource "aws_security_group" "ce_sg" {
  name        = "CE-Mapfre-SG"
  description = "Security group para instancias EC2"

  vpc_id = aws_vpc.ce_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acesso SSH de qualquer lugar (não recomendado para produção)
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acesso RDP de qualquer lugar (não recomendado para produção)
  }

  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acesso WinRM de qualquer lugar (não recomendado para produção)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acesso à internet para baixar arquivos (atualizações ou novas instalações)
  }
}

