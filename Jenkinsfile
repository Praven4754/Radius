pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'my-aws-creds'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git(
                    branch: 'main',
                    url: 'https://github.com/Bharathraj5002/Radius.git',
                    credentialsId: 'github-creds'
                )
            }
        }

        stage('Debug Workspace') {
            steps {
                sh 'ls -lR $WORKSPACE'
            }
        }

        stage('Prepare .env from Secret File') {
            steps {
                withCredentials([file(credentialsId: 'env_file', variable: 'ENV_FILE_PATH')]) {
                    sh '''
                        mkdir -p $WORKSPACE/terraform
                        chmod -R u+w $WORKSPACE/terraform
                        cp ${ENV_FILE_PATH} $WORKSPACE/terraform/.env
                    '''
                }
            }
        }

        stage('Prepare Terraform Files') {
            steps {
                sh '''
                    cp $WORKSPACE/compose3.yml $WORKSPACE/terraform/
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID,
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir('terraform') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID,
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir('terraform') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[ 
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: env.AWS_CREDENTIALS_ID,
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir('terraform') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
