#!/bin/bash

# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed on this system."
    exit 1
fi

# Check if Docker daemon is running
if ! systemctl is-active --quiet docker; then
    echo "Error: Docker daemon is not running. Please start it with 'sudo systemctl start docker'."
    exit 1
fi

# Check if the container already exists
docker container inspect jrvs-psql > /dev/null 2>&1
container_status=$?

# Use switch case to handle create|stop|start options
case $cmd in 
  create)
    # Check if the container has already been created
    if [ $container_status -eq 0 ]; then
      echo 'Error: Container jrvs-psql already exists.'
      exit 1	
    fi

    # Validate input arguments for 'create' command
    if [ $# -ne 3 ]; then
      echo 'Error: Create requires username and password.'
      echo 'Usage: ./psql_docker.sh create [db_username] [db_password]'
      exit 1
    fi
  
    # Create a persistent volume for database data
    docker volume create pgdata
    
    # Run the PostgreSQL container
    # Mapping port 5432 and mounting volume to /var/lib/postgresql for 18+ compatibility
    docker run --name jrvs-psql \
      -e POSTGRES_USER="$db_username" \
      -e POSTGRES_PASSWORD="$db_password" \
      -d -p 5432:5432 \
      -v pgdata:/var/lib/postgresql \
      postgres:latest

    exit $?
    ;;

  start|stop) 
    # Check if the container exists before attempting to start or stop it
    if [ $container_status -ne 0 ]; then
      echo "Error: Container jrvs-psql has not been created."
      exit 1
    fi

    # Execute the start or stop command
    echo "Executing: docker container $cmd jrvs-psql"
    docker container $cmd jrvs-psql
    exit $?
    ;;	
  
  *)
    # Handle invalid commands
    echo 'Error: Illegal command'
    echo 'Usage: ./psql_docker.sh start|stop|create [db_username] [db_password]'
    exit 1
    ;;
esac
