// Series of volumes to attach to a disk benchmarking instance in addition to the instance's root
// and (if applicable) local storage volumes.
//
// The `type` of EBS volume takes one of `standard`, `gp2`, `gp3`, `io1`, `io2`, `sc1` or `st1`. 
// See disk user-guide here: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html
// In short: 
//  
//  - General Purpose SSD — Provides a balance of price and performance. We recommend these volumes 
//      for most workloads. A maxed-out 32GB gp3 instance runs around $105/month
//
//  - Provisioned IOPS SSD — Provides high performance for mission-critical, low-latency, or high-throughput 
//      workloads. Careful! A maxed out io1 disk runs about $4,200/month! io2 offers an even higher IOPS 
//      cap and a higher durability SLA for (you guessed it) a higher cost. 
//      
//      IO Disk - A sliding scale that creates either an IO1 or IO2 volume depending on the configuration
//      - 16,000 < IOPS < 64,000      ==> IO1;
//      - 64,000 > IOPS               ==> IO2; 
//
//  - The HDD-backed volumes provided by Amazon EBS fall into these categories, Throughput Optimized HDD 
//      A low-cost HDD designed for frequently accessed, throughput-intensive workloads (`st1`) OR cold 
//      HDD (`sc1`). Both *hardly* more expensive than S3 STANDARD storage.
//
//
// NOTE: No support for deploying to AWS Outposts or Snapshots

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
resource "aws_ebs_volume" "aux_volumes" {

  // Create a new volume for each obj in `volume_configuration`
  for_each = var.aux_volume_configuration

  // General
  availability_zone = var.availability_zone
  size              = each.value.size_in_gb
  type              = each.value.type

  // Encryption Options - ecrypt all volumes w. the same key
  encrypted  = (var.disk_kms_key_id == "") ? false : true
  kms_key_id = var.disk_kms_key_id

  // Disk Characteristics -  Some disk types have unique 
  // characteristics (e.g. io1|io2 -> IOPs, gp3 -> Throughput & IOPs)
  iops       = each.value.iops
  throughput = each.value.throughput

  // Tags
  tags = {
    Name         = "Auxillary Volume (${each.key})"
    mount_target = each.value.mnt_pnt
  }
}
