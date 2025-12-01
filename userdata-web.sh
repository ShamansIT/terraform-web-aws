#!/bin/bash
# Update system packages
yum update -y

# Install nginx
amazon-linux-extras install nginx1 -y || yum install -y nginx

# Enable and start nginx
systemctl enable nginx
systemctl start nginx

# Get instance metadata: Availability Zone and Instance ID
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Create simple HTML page with lab info
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>terraform-web-aws lab</title>
</head>
<body>
    <h1>Terraform Web AWS Lab</h1>
    <p>Instance ID: ${INSTANCE_ID}</p>
    <p>Availability Zone: ${AZ}</p>
    <p>Owner: Serhii / Student ID: L00196841</p>
</body>
</html>
EOF
