
pipeline{
    agent any
    environment{
        DOCKERCRED="docker-cred"
        ec2_user="ubuntu"
        IP="3.24.179.149"
        TAG="${BUILD_NUMBER}"
        NAMESPACE="flask"

        frontend_image="gokarni/frontend"
    }
    stages{
        stage("Checkout code"){
            steps{
            git branch: 'main', credentialsId: 'github', url: 'https://github.com/Gokarni/flask-app.git'
            }

        }
        stage("Build Image") {
            steps{
            sh '''
            docker build -t ${frontend_image}:${TAG} .
            '''
            }
            }
    
        stage("Push Image") {
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS'
                )] ) {
                    sh ''' echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${frontend_image}:${TAG}
                    docker logout'''
                }
                }
                }
                
        stage("Deploy Image"){
            steps{
                withCredentials([
                    file(credentialsId: 'kubeconfig', variable:'KUBECONFIG')
                ]){
                sh '''
                export KUBECONFIG="$KUBECONFIG"
                kubectl apply -f k8s/
                kubectl set image deployment/flask-deploy flask-cont=${frontend_image}:${TAG} -n ${NAMESPACE}
                    '''
                }  
                }
            }
                stage('Verify Deployment'){
                    steps{
                        withCredentials([
                    file(credentialsId: 'kubeconfig', variable:'KUBECONFIG')
                    ]){
                            script{ 
                                def dbpassword = params.MYSQL_PASSWORD
                        sh '''
                        export KUBECONFIG="$KUBECONFIG"
                        kubectl rollout status deployment/flask-deploy -n ${NAMESPACE} --timeout=120s
                        kubectl get pods -n ${NAMESPACE}
                        kubectl get svc -n ${NAMESPACE}
                        '''
                    }
                        }
                }
            }
    }
        
        }
