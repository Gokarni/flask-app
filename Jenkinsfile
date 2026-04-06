
pipeline{
    agent any
    environment{
        DOCKERCRED="docker-cred"
        ec2_user="ubuntu"
        IP="3.24.179.149"

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
            script{
            docker.build("${frontend_image}:latest")
            }
            }
        }
        stage("Push Imagee") {
            steps{
                script{
                    def dockeruser=params.DOCKER_UNAME
                    def dockerpass=params.DOCKER_PASS
                    sh """
                    echo ${dockerpass} | docker login -u ${dockeruser} --password-stdin
                    docker push ${frontend_image}:latest
                    """
                }
            }
        }
        stage("Deploy Image"){
            steps{
                script{ 
                def dbpassword = params.MYSQL_PASSWORD 
                sshagent(["ec2-agent"]){
                    sh '''
                    ssh  -o StrictHostKeyChecking=no ${ec2_user}@${IP} << EOF
                    kubectl delete -f Namespace.yml || true
                    kubectl delete -f mysql-deployment.yml || true
                    kubectl delete -f mysql-pv.yml || true
                    kubectl delete -f mysql-pvc.yml || true
                    kubectl delete -f mysql-svc.yml || true
                    kubectl delete -f flask-deployment.yml || true
                    kubectl delete -f flask-svc.yml || true
                    rm -rf flask-app

                    # Clone latest code
                    git clone https://github.com/Gokarni/flask-app.git

                    cd flask-app

                    kubectl apply -f Namespace.yml
                    kubectl apply -f mysql-deployment.yml
                    kubectl apply -f mysql-pv.yml
                    kubectl apply -f mysql-pvc.yml
                    kubectl apply -f mysql-svc.yml
                    kubectl apply -f flask-deployment.yml
                    kubectl apply -f flask-svc.yml
                    kubectl get pods -n flask
                    kubectl get svc -n flask

                    for pod in $(kubectl get pods -n flask -l app=mysql -o jsonpath='{.items[*].metadata.name}')
                    do
                        kubectl exec -i $pod -n flask -- mysql -u root -p${dbpassword} < message.sql
                    done

                    kubectl port-forward svc/flask-svc -n flask 5000:5000 --address=0.0.0.0

                    EOF
                    '''
                }  
                }
            }
        
        }
        
    }
}
