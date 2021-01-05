import boto3
from DST_handler import london_time_now


def lambda_handler(event, context):
    region = 'eu-west-1'
    ec2 = boto3.client('ec2', region_name=region)
    asclient = boto3.client('autoscaling', region_name=region)
    
    ec2_instanceIds_to_shutdown = list()
    asgs_to_suspend = dict()

    all_instances_list = ec2.describe_instances()

    for reservation in all_instances_list["Reservations"]:
        for instance in reservation["Instances"]:
            shut_down = True
            asg_groupname = ""
            if "Tags" not in instance.keys():
                print("ERROR: Instance has no tags:" + instance['InstanceId'])
                continue
            for tag in instance['Tags']:
                if tag["Key"] == "aws:autoscaling:groupName":
                    asg_groupname = tag['Value']
                if tag["Key"] == "KeepAwake":
                    if tag["Value"] == "True":
                        shut_down = False
            if shut_down:
                ec2_instanceIds_to_shutdown.append(instance['InstanceId'])
                if asg_groupname != "":
                    asgs_to_suspend[asg_groupname] = 1

    # Get RDS Instances to shutdown
    # rds = boto3.client('rds', region_name=region)
    # rds_instances = list()

    # all_rds_instances = rds.describe_db_instances()

    # for instance in all_rds_instances["DBInstances"]:
    #     rds_instances.append(instance["DBInstanceIdentifier"])
    #
    # for instance in all_rds_instances["DBInstances"]:
    #     arn = rds.list_tags_for_resource(ResourceName=instance["DBInstanceArn"])
    #     for pair in arn["TagList"]:
    #         if pair['Key'] == 'KeepAwake' and pair['Value'] == 'True':
    #             rds_instances.remove(instance["DBInstanceIdentifier"])

    # Use DST_Handler to get now time
    now = london_time_now()
    today7am = now.replace(hour=7, minute=0, second=0, microsecond=0)
    today4pm = now.replace(hour=16, minute=0, second=0, microsecond=0)
    today7pm = now.replace(hour=19, minute=0, second=0, microsecond=0)
    if today7am < now < today7pm:
        if len(ec2_instanceIds_to_shutdown) > 0:
            for asg_name in asgs_to_suspend.keys():
                print("Resuming scaling processes on " + asg_name)
                asclient.resume_processes(
                    AutoScalingGroupName=asg_name,
                    ScalingProcesses=[
                        'Launch',
                        'Terminate',
                        'HealthCheck',
                        'ReplaceUnhealthy',
                        'AZRebalance'
                    ]
                )

            print('EC2 Instances waking up')
            print(ec2_instanceIds_to_shutdown)
            ec2.start_instances(InstanceIds=ec2_instanceIds_to_shutdown)
        else:
            print("No instances to be woken")
        # if len(rds_instances) > 0:
        #     for rds_instance in rds_instances:
        #         rds.start_db_instance(DBInstanceIdentifier=rds_instance)
        #         print("Waking up " + rds_instance)
        # else:
        #     print("No RDS Instances to be woken")
    elif now > today7pm:
        if len(ec2_instanceIds_to_shutdown) > 0:
            for asg_name in asgs_to_suspend.keys():
                print("Suspending scaling processes on " + asg_name)
                asclient.suspend_processes(
                    AutoScalingGroupName=asg_name,
                    ScalingProcesses=[
                        'Launch',
                        'Terminate',
                        'HealthCheck',
                        'ReplaceUnhealthy',
                        'AZRebalance'
                    ]
                )

            print('EC2 Instances going to sleep')
            print(ec2_instanceIds_to_shutdown)
            ec2.stop_instances(InstanceIds=ec2_instanceIds_to_shutdown)
        else:
            print("No instances to be shut down")
        # if len(rds_instances) > 0:
        #     for rds_instance in rds_instances:
        #         rds.stop_db_instance(DBInstanceIdentifier=rds_instance)
        #         print("Shutting down " + rds_instance)
        # else:
        #     print("No RDS instances to be shut down")
