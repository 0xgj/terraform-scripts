provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "ap-northeast-1"
}

# 创建VPC
resource "alicloud_vpc" "vpc" {
  name = "terraform-vpc"
  cidr_block = "10.1.0.0/21"
}

# 添加vswitch。vswitch 必须位于指定的vswitch。
resource "alicloud_vswitch" "vsw" {
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-northeast-1a"
}

# 增加安全组
resource "alicloud_security_group" "sg" {
  name   = "terraform-sg"
  vpc_id = "${alicloud_vpc.vpc.id}" 
}

# 设置安全组规则
resource "alicloud_security_group_rule" "allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

# 创建ECS服务器
resource "alicloud_instance" "dev" {
  count = "1"
  instance_name = "terraform-ecs"
  key_name = "caogj"
  internet_max_bandwidth_out = 10
  availability_zone = "ap-northeast-1a"
  image_id = "ubuntu_16_0402_64_20G_alibase_20171227.vhd"
  instance_type = "ecs.n4.small"
  system_disk_category = "cloud_efficiency"
  security_groups = ["${alicloud_security_group.sg.id}"] 
  vswitch_id = "${alicloud_vswitch.vsw.id}"
}
