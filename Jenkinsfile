
pipeline{
    agent any
    environment{
        DOCKERCRED="docker-cred"
        ec2_user="ubuntu"
        IP="3.24.179.149"
        TAG="${BUILD_NUMBER}"

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
                withCredentials{[usernamePassword(
                    credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS'
                )]{
                    sh ''' echo "$DOCKERA_PASS" | docker login -u "$DOCKER_USER" --passsword-stdin
                    docker push ${IMAGE}:${TAG}
                    docker logout'''
                }
                }
                }
                
        stage("Deploy Image"){
            steps{
                sh '''
                kubectl apply -f k8s/
                kubectl set image deployment/flask-deploy flask-deploy=${IMAGE}:${TAG} -n ${NAMESPACE}
                    '''
                }  
                }
                stage('Verify Deployment'){
                    steps{
                        sh '''
                        kubectl rollout status deployment/flask-deploy -n ${NAMESPACE} --timeout=120s
                        kubectl get pods -n ${NAMESPACE}
                        kubectl get svc -n ${NAMESPACE}
                        '''
                    }
                }
            }
        
        }
        
}
