node {

    def tag = "3.0"
    def dockerHubUser = "anujsharma1990"
    def containerName = "bankingapp"
    def httpPort = "8989"
    def containerPort = "8989"

    stage('Clean Workspace') {
        cleanWs()
    }

    stage('Checkout Code') {
        echo "Checking out source code..."
        checkout scm
    }

    stage('Maven Build') {
        echo "Building application..."
        sh "mvn clean package -DskipTests"
    }

    stage('Get Docker Credentials') {
        withCredentials([
            usernamePassword(
                credentialsId: 'dockerHubAccount',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASSWORD'
            )
        ]) {
            dockerHubUser = env.DOCKER_USER
        }
    }

    stage('Build Docker Image') {
        echo "Building Docker image..."

        sh """
            docker build \
                --pull \
                --no-cache \
                -t ${dockerHubUser}/${containerName}:${tag} .
        """
    }

    stage('Push Docker Image') {
        withCredentials([
            usernamePassword(
                credentialsId: 'dockerHubAccount',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASSWORD'
            )
        ]) {

            sh """
                echo "\$DOCKER_PASSWORD" | docker login \
                    -u "\$DOCKER_USER" \
                    --password-stdin

                docker push ${dockerHubUser}/${containerName}:${tag}

                docker logout
            """
        }
    }

    stage('Deploy Container') {
        withCredentials([
            usernamePassword(
                credentialsId: 'dockerHubAccount',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASSWORD'
            )
        ]) {

            sh """
                echo "\$DOCKER_PASSWORD" | docker login \
                    -u "\$DOCKER_USER" \
                    --password-stdin

                docker pull ${dockerHubUser}/${containerName}:${tag}

                echo "Checking for existing container..."

                if docker ps -a --format '{{.Names}}' | grep -w ${containerName}; then
                    echo "Stopping existing container..."
                    docker stop ${containerName}
                    docker rm ${containerName}
                fi

                echo "Starting new container..."

                docker run -d \
                    --name ${containerName} \
                    --restart unless-stopped \
                    -p ${httpPort}:${containerPort} \
                    ${dockerHubUser}/${containerName}:${tag}

                docker image prune -f

                docker logout
            """
        }
    }
    stage('Kubernetes Deployment') {
        sleep 15

        sh """
           kubectl delete -f deployment.yaml
           kubectl apply -f deployment.yaml
           kubectl get pods -o wide
        """
    }
    stage('Verify Deployment') {
        sleep 15

        sh """
            docker ps

            curl -f http://localhost:${httpPort}/bank-api/swagger-ui.html
        """
    }

    stage('Cleanup') {
        cleanWs()
    }
}
