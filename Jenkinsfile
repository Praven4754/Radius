pipeline {
    agent any
    
    environment {
        AWS_CREDENTIALS_ID = 'my-aws-creds'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                git(branch: 'main', url: 'https://github.com/Bharathraj5002/Radis.git', credentialsId: 'github-creds')
            }
        }
        
        stage('Prepare .env from Secret File') {
            steps {
                withCredentials([file(credentialsId: 'env_file', variable: 'ENV_FILE_PATH')]) {
                    script {
                        // Copy the secret file to the location expected by Terraform
                        sh "cp ${ENV_FILE_PATH} terraform/../.env"
                    }
                }
            }
        }
        
        stage('Prepare other Terraform files') {
            steps {
                sh '''
                    cp compose3.yml terraform/../compose3.yml
                    cp dependency.sh terraform/dependency.sh
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
        
        // Terraform Plan and Apply stages as before
        // ...
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
