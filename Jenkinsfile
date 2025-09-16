pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'my-aws-creds'
        TERRAFORM_DIR      = "$WORKSPACE/terraform"
    }

    parameters {
        choice(
            name: 'INSTANCE_TYPE',
            choices: ['t2.micro', 't2.small', 't2.medium', 't3.micro', 't3.small'],
            description: 'Select the EC2 instance type to create'
        )
        string(
            name: 'VOLUME_SIZE',
            defaultValue: '20',
            description: 'Root volume size in GB'
        )
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

        stage('Prepare .env from Secret File') {
            steps {
                withCredentials([file(credentialsId: 'env_file', variable: 'ENV_FILE_PATH')]) {
                    sh '''
                        mkdir -p $TERRAFORM_DIR
                        chmod -R u+w $TERRAFORM_DIR
                        cp ${ENV_FILE_PATH} $TERRAFORM_DIR/.env
                    '''
                }
            }
        }

        stage('Prepare Terraform Files') {
            steps {
                sh "cp $WORKSPACE/compose3.yml $TERRAFORM_DIR/"
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
                        sh """
                            terraform plan \
                              -var instance_type=${params.INSTANCE_TYPE} \
                              -var volume_size=${params.VOLUME_SIZE} \
                              -out=tfplan
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

        stage('Get Terraform Outputs') {
            steps {
                dir('terraform') {
                    script {
                        env.EC2_PUBLIC_IP = sh(
                            script: "terraform output -raw public_ip",
                            returnStdout: true
                        ).trim()

                        env.PEM_FILE = sh(
                            script: "terraform output -raw private_key_file",
                            returnStdout: true
                        ).trim()

                        echo "EC2 Public IP: ${env.EC2_PUBLIC_IP}"
                        echo "PEM File: ${env.PEM_FILE}"
                    }
                }
            }
        }

        stage('Deploy App on EC2') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'ghcr-creds',
                    usernameVariable: 'GH_USERNAME',
                    passwordVariable: 'GH_TOKEN'
                )]) {
                    script {
                        sh """
                            chmod 400 $TERRAFORM_DIR/${env.PEM_FILE}
                            ssh -o StrictHostKeyChecking=no -i $TERRAFORM_DIR/${env.PEM_FILE} ubuntu@${env.EC2_PUBLIC_IP} << 'EOF'
                                echo "$GH_TOKEN" | docker login ghcr.io -u "$GH_USERNAME" --password-stdin
                                cd app
                                mkdir -p ./data/grafana
                                sudo chown -R 472:472 ./data/grafana || echo "Directory not found, skipping chown"
                                docker compose up -d
                            EOF
                        """

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
