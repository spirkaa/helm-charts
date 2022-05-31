pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '60'))
    parallelsAlwaysFailFast()
    disableConcurrentBuilds()
  }

  environment {
    REGISTRY = 'git.devmem.ru'
    REGISTRY_URL = "https://${REGISTRY}"
    REGISTRY_CREDS_ID = 'gitea-user'
    OWNER = 'projects'
    HELM_IMAGE = "${REGISTRY}/${OWNER}/helm:latest"
    HELM_REPO_API_URL = "${REGISTRY_URL}/api/packages/${OWNER}/helm/api/charts"
  }

  stages {
    stage('Build and release Helm charts') {
      when {
        branch 'main'
        not {
          changeRequest()
        }
      }
      steps {
        script {
          withCredentials([
            usernameColonPassword(credentialsId: "${REGISTRY_CREDS_ID}", variable: 'REGISTRY_USER')
            ]) {
            docker.withRegistry("${REGISTRY_URL}", "${REGISTRY_CREDS_ID}") {
              docker.image("${HELM_IMAGE}").inside {
                sh '''
                  helm version
                  mkdir _output

                  # Lint & package charts (all at once)
                  find ./charts -maxdepth 1 -mindepth 1 -type d -print0 | \
                    xargs -0 sh -c 'helm lint "$@" && helm package -d _output "$@"' sh

                  # Upload charts (one by one)
                  find ./_output -type f -print0 | \
                    xargs -0 -i curl -fsS -X POST \
                      --upload-file {} \
                      --user $REGISTRY_USER \
                      $HELM_REPO_API_URL
                '''
              }
            }
          }
        }
      }
      post {
        always {
          sh "docker rmi ${HELM_IMAGE}"
        }
      }
    }
  }

  post {
    always {
      emailext(
        to: '$DEFAULT_RECIPIENTS',
        subject: '$DEFAULT_SUBJECT',
        body: '$DEFAULT_CONTENT'
      )
    }
  }
}
