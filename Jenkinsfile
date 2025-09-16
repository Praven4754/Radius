pipeline {
    agent any

    parameters {
        choice(
            name: 'INSTANCE_TYPE',
            choices: ['t2.micro', 't2.small', 't2.medium', 't3.micro', 't3.small'],
            description: 'Select the EC2 instance type to create'
        )

        string(
            name: 'STORAGE_SIZE',
            defaultValue: '20',
            description: 'Enter the storage size (in GB) for root volume'
        )
    }

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
        
        stage('Debug Terraform Folder') {
            steps {
                dir('terraform') {
                    sh 'echo "Listing all files in terraform folder:"'
                    sh 'ls -lR'
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
                        // Pass the parameters to Terraform
                        sh """
                            terraform plan -out=tfplan \
                              -var="instance_type=${params.INSTANCE_TYPE}" \
                              -var="volume_size=${params.STORAGE_SIZE}"
                        """
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
            echo "Deployment successful! EC2 Type: ${params.INSTANCE_TYPE}, Storage: ${params.STORAGE_SIZE} GB"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
