resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "SG for ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }

}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "SG for Todo App"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app-sg"
  }

}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "SG for MongoDB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-sg"
  }

}

resource "aws_vpc_security_group_ingress_rule" "http"{
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "HTTP from internet"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "https"{
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS from internet"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "public-to-app"{
  security_group_id = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  from_port         = 8000
  to_port           = 8000
  ip_protocol       = "tcp"
  description       = "ALB to App"
}

resource "aws_vpc_security_group_ingress_rule" "public-to-app"{
  security_group_id = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port         = 8000
  to_port           = 8000
  ip_protocol       = "tcp"
  description       = "ALB to App"
}

resource "aws_vpc_security_group_egress_rule" "app-to-db"{
  security_group_id = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.db.id
  from_port         = 27017
  to_port           = 27017
  ip_protocol       = "tcp"
  description       = "App to DB"
}  

resource "aws_vpc_security_group_egress_rule" "app-to-http"{
  security_group_id = aws_security_group.app.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "App to NAT HTTP"
}  

resource "aws_vpc_security_group_egress_rule" "app-to-https"{
  security_group_id = aws_security_group.app.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "App to NAT HTTPS"
}  

resource "aws_vpc_security_group_ingress_rule" "app-to-db"{
    security_group_id = aws_security_group.db.id
    referenced_security_group_id = aws_security_group.app.id
    from_port         = 27017
    to_port           = 27017
    ip_protocol       = "tcp"
    description       = "App to DB" 
}

resource "aws_vpc_security_group_ingress_rule" "db-to-db"{
    security_group_id = aws_security_group.db.id
    referenced_security_group_id = aws_security_group.db.id
    from_port         = 27017
    to_port           = 27017
    ip_protocol       = "tcp"
    description       = "DB to DB for replica set" 
} 

resource "aws_vpc_security_group_egress_rule" "db-to-db"{
    security_group_id = aws_security_group.db.id
    referenced_security_group_id = aws_security_group.db.id
    from_port         = 27017
    to_port           = 27017
    ip_protocol       = "tcp"
    description       = "DB to DB for replica set" 
}

resource "aws_vpc_security_group_egress_rule" "db-to-http"{
  security_group_id = aws_security_group.db.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "DB to NAT HTTP"
}  

resource "aws_vpc_security_group_egress_rule" "db-to-https"{
  security_group_id = aws_security_group.db.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "DB to NAT HTTPS"
}  