//
// AWS EC2 Instance used for all Disk Test
//

// Resources: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance 
resource "aws_instance" "disk" {

  // General
  ami           = var.instance_ami  // Default to 20.04 Ubuntu LTS; ARM64
  instance_type = var.instance_type // Select an Instance Type w. NVME Local Storage

  // Security + Networking
  vpc_security_group_ids = var.instance_security_group_ids
  subnet_id              = var.instance_launch_subnet.id

  // SSH Key
  key_name = var.instance_ssh_key

  // Disk Properties
  ebs_optimized = true

  // Root Disk Properties
  root_block_device {
    volume_size = var.root_volume_configuration.size_in_gb
    volume_type = var.root_volume_configuration.type
    iops        = var.root_volume_configuration.iops
    throughput  = var.root_volume_configuration.throughput

    // Encryption
    encrypted  = (var.disk_kms_key_id == "") ? false : true
    kms_key_id = var.disk_kms_key_id

    // Lifecycle Management
    delete_on_termination = true

    // Tags
    tags = {
      Name = "Disk Benchmarking Root (${var.root_volume_configuration.type})"
    }

  }

  // User Data - The testing instance requires a few utilities for benchmarking
  // disk performance (e.g. fio, iostat, sysstat) - init those w. instance here
  user_data = templatefile(
    var.instance_user_data_path, var.instance_user_data_args
  )

  // "Provision" (scp) files onto the instance
  provisioner "file" {
    source      = var.benchmarking_utilities_path
    destination = "/home/ubuntu/benchmarks_utils"

    // Provisioning connection is scp over SSH; assumes instance is reachable from
    // provisioning machine... 
    connection {
      type        = "ssh"
      user        = "ubuntu" // Assumes Ubuntu...
      private_key = file("~/.ssh/${var.instance_ssh_key}.pem")
      port        = 22 // Safe to assume SSH runs on 22...
      host        = self.public_ip
    }

  }

  // Tags
  tags = {
    Name = "${var.module_friendly_name} - Disk Benchmarking Instance"
  }

}

// Attach
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment 
resource "aws_volume_attachment" "ebs_attachements" {
  for_each = aws_ebs_volume.aux_volumes

  // General
  device_name = each.value.tags.mount_target // NOTE: Not really supposed to use tags like this...
  volume_id   = each.value.id
  instance_id = aws_instance.disk.id

  // Set explicit dependency on the existence of the test EBS volumes
  depends_on = [
    aws_ebs_volume.aux_volumes
  ]
}