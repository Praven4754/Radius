pipeline {
    agent any

    environment {
        // Replace with your Jenkins AWS credential ID configured as "AWS Credentials" kind
        AWS_CREDENTIALS_ID = 'my-aws-creds'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git(
                    branch: 'main',
                    url: 'https://github.com/Bharathraj5002/Radis.git',
                    credentialsId: 'github-creds'  // Your GitHub credentials ID
                )
            }
        }

        stage('Prepare Terraform') {
            steps {
                script {
                    // Ensure .env and other necessary files are in the expected paths relative to Terraform
                    sh '''
                        cp ./path_to_env/.env ./terraform/../.env
                        cp ./path_to_compose3/compose3.yml ./terraform/../compose3.yml
                        cp ./path_to_dependency/dependency.sh ./terraform/dependency.sh
                    '''
                }
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

        // Optionally add Docker deployment stage here, if needed
        // stage('Deploy Docker App') {
        //     steps {
        //         dir('app') {
        //             sh 'docker-compose down || true'
        //             sh 'docker-compose up -d'
        //         }
        //     }
        // }
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
