resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.project-prefix}-ecs-${format("%s", terraform.workspace)}" # Nome do cluster ex: my-api-ecommerce-api-ecs-dev
}


resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "project-name-ecs-task-env"  # Nome da task ex: my-api-ecommerce-ecs-task-dev
  container_definitions    = <<DEFINITION
  [
    {
      "name": "project-name-ecs-task-env",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/ecr-repo:latest",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "project-name-ecs-task-env",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs-hml"
                }
            },
      "portMappings": [
        {
          "containerPort": 3333,
          "hostPort": 3333
        }
      ],
      "cpu": 1024,
      "memoryReservation": 1024,
      "environment": [
        {
          "name": "VAR_NAME_00",
          "value": "VALUE-00"
        },
        {
          "name": "VAR_NAME_01",
          "value": "VALUE-01"
        },
        {
          "name": "VAR_NAME_02",
          "value": "VALUE-02"
        }
      ]  

    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 2048         # Specifying the memory our container requires
  cpu                      = 1024         # Specifying the CPU our container requires
  execution_role_arn       = "${var.arn-ecsTaskExecutionRole}"
}

resource "aws_ecs_service" "my_first_service" {
  name            = "${var.project-prefix}-svc-${format("%s", terraform.workspace)}"    # Nome do primeiro service  ex: my-api-ecommerce-ecs-svc-dev
  cluster         = "${aws_ecs_cluster.my_cluster.id}" # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Setting the number of containers to 3

  load_balancer {
                        
   #target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:071666281700:targetgroup/target-group/48303fda90820b0b" # Referencing our target group
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.my_first_task.family}"
    container_port   = 3333 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${lookup(var.subnets-ids-az-a, terraform.workspace)}", "${lookup(var.subnets-ids-az-b, terraform.workspace)}", "${lookup(var.subnets-ids-az-c, terraform.workspace)}"]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}
