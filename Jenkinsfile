pipeline {
    agent  { node { label 'docker-slave' } }
    parameters {
        choice(choices: 'PROD\nPRE-PROD', description: 'environment name', name: 'EnvName')
    }
    stages {
        stage('Build image') {
            steps {
                  sh "git clone https://github.com/Ankur012/ecs-pipeline.git"
                  sh "ls -altr"
                  withCredentials([string(credentialsId: 'AWS_REPOSITORY_URL_SECRET', variable: 'AWS_ECR_URL')]) {
                  script {
                    sh "cd ecs-pipeline && docker build -t ${AWS_ECR_URL}:${env.BUILD_NUMBER} ."
                    }
                  }
                } // stage Build end
            }
      stage('Push Image to ECR') {
          steps {
            withCredentials([string(credentialsId: 'AWS_REPOSITORY_URL_SECRET', variable: 'AWS_ECR_URL')]) {
              withAWS(region: "us-east-1", credentials: 'cust-dev') {
                script {
                  def login = ecrLogin()
                  sh('#!/bin/sh -e\n' + "${login}") // hide logging
                  docker.image("${AWS_ECR_URL}:${env.BUILD_NUMBER}").push()
                }
              }
            }
          }
        }
    stage('Deploy app in PRE-PROD PRE-PROD') {
      options { withAWS(region: "us-east-1", credentials: 'cust-dev') }
      when { equals expected: "PRE-PROD", actual: "${params.EnvName}" }
          environment {
            AWS_ECR_REGION = 'us-east-1'
            AWS_ECS_SERVICE = 'pre-prod'
            AWS_ECS_EXECUTION_ROL = 'Jenkins_CICD'
            AWS_ECS_TASK_DEFINITION = 'pre-prod'
            AWS_ECS_COMPATIBILITY = 'FARGATE'
            AWS_ECS_NETWORK_MODE = 'awsvpc'
            AWS_ECS_CPU = '256'
            AWS_ECS_MEMORY = '512'
            AWS_ECS_CLUSTER = 'pre-prod'
            AWS_ECS_TASK_DEFINITION_PATH = 'task.json'
          }
          steps {
             
              script {
                sh("aws ecs register-task-definition --region ${AWS_ECR_REGION} --family ${AWS_ECS_TASK_DEFINITION} --execution-role-arn ${AWS_ECS_EXECUTION_ROL} --requires-compatibilities ${AWS_ECS_COMPATIBILITY} --network-mode ${AWS_ECS_NETWORK_MODE} --cpu ${AWS_ECS_CPU} --memory ${AWS_ECS_MEMORY} --container-definitions file://${AWS_ECS_TASK_DEFINITION_PATH}")
                def taskRevision = sh(script: "aws ecs describe-task-definition --task-definition ${AWS_ECS_TASK_DEFINITION} | egrep \"revision\" | tr \"/\" \" \" | awk '{print \$2}' | sed 's/\"\$//'", returnStdout: true)
                sh("aws ecs update-service --cluster ${AWS_ECS_CLUSTER} --service ${AWS_ECS_SERVICE} --task-definition ${AWS_ECS_TASK_DEFINITION}:${taskRevision}")
              }
          }
        } 
        stage('Deploy app in PROD PRE-PROD') {
          options { withAWS(region: "us-east-1", credentials: 'cust-dev') }
          when { equals expected: "PROD", actual: "${params.EnvName}" }
              environment {
                AWS_ECR_REGION = 'us-east-1'
                AWS_ECS_SERVICE = 'prod'
                AWS_ECS_EXECUTION_ROL = 'Jenkins_CICD'
                AWS_ECS_TASK_DEFINITION = 'prod'
                AWS_ECS_COMPATIBILITY = 'FARGATE'
                AWS_ECS_NETWORK_MODE = 'awsvpc'
                AWS_ECS_CPU = '256'
                AWS_ECS_MEMORY = '512'
                AWS_ECS_CLUSTER = 'prod'
                AWS_ECS_TASK_DEFINITION_PATH = 'task.json'
              }
              steps {
                 
                  script {
                    
                    sh("aws ecs register-task-definition --region ${AWS_ECR_REGION} --family ${AWS_ECS_TASK_DEFINITION} --execution-role-arn ${AWS_ECS_EXECUTION_ROL} --requires-compatibilities ${AWS_ECS_COMPATIBILITY} --network-mode ${AWS_ECS_NETWORK_MODE} --cpu ${AWS_ECS_CPU} --memory ${AWS_ECS_MEMORY} --container-definitions file://${AWS_ECS_TASK_DEFINITION_PATH}")
                    def taskRevision = sh(script: "aws ecs describe-task-definition --task-definition ${AWS_ECS_TASK_DEFINITION} | egrep \"revision\" | tr \"/\" \" \" | awk '{print \$2}' | sed 's/\"\$//'", returnStdout: true)
                    sh("aws ecs update-service --cluster ${AWS_ECS_CLUSTER} --service ${AWS_ECS_SERVICE} --task-definition ${AWS_ECS_TASK_DEFINITION}:${taskRevision}")
                  }
              }
            }    
  }
post {
      always {
              cleanWs()
                }
  }

}
