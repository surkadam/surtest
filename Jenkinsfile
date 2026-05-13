pipeline {
    agent any

    parameters {
        string(
            name: 'QSCANNER_PATH',
            defaultValue: './qscanner',
            description: 'Absolute or relative path to the qscanner binary on the agent'
        )
    }

    environment {
        QUALYS_POD = 'ENG-POD01'
        GHCR_ORG   = 'surkadam'
    }

    stages {

        stage('Setup') {
            steps {
                script {
                    // Strip 'origin/' prefix and replace '/' with '-' for valid Docker tags
                    def rawBranch = env.GIT_BRANCH ?: 'unknown'
                    def branch = rawBranch.replaceAll('origin/', '').replaceAll('/', '-')
                    env.BRANCH_TAG    = branch
                    env.PYTHON_IMAGE  = "ghcr.io/${env.GHCR_ORG}/qscanner-demo/python-app:${branch}"
                    env.NODE_IMAGE    = "ghcr.io/${env.GHCR_ORG}/qscanner-demo/node-app:${branch}"
                    env.GIT_SHA_SHORT = env.GIT_COMMIT?.take(8) ?: 'unknown'
                    echo "Branch  : ${branch}"
                    echo "Commit  : ${env.GIT_COMMIT}"
                    echo "Python  : ${env.PYTHON_IMAGE}"
                    echo "Node    : ${env.NODE_IMAGE}"
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build python-app') {
                    steps {
                        sh "docker build -t ${env.PYTHON_IMAGE} ./apps/python-app"
                    }
                }
                stage('Build node-app') {
                    steps {
                        sh "docker build -t ${env.NODE_IMAGE} ./apps/node-app"
                    }
                }
            }
        }

        stage('Qualys Image Scan') {
            parallel {
                stage('Scan python-app image') {
                    steps {
                        withCredentials([
                            string(credentialsId: 'QUALYS_CLIENT_ID',     variable: 'CLIENT_ID'),
                            string(credentialsId: 'QUALYS_CLIENT_SECRET', variable: 'CLIENT_SECRET')
                        ]) {
                            sh """
                                ${params.QSCANNER_PATH} image ${env.PYTHON_IMAGE} \\
                                  --pod ${env.QUALYS_POD} \\
                                  --skip-verify-tls \\
                                  -l debug \\
                                  --client-id \$CLIENT_ID \\
                                  --client-secret \$CLIENT_SECRET \\
                                  --collect-build-pipeline-metadata=true
                            """
                        }
                    }
                }
                stage('Scan node-app image') {
                    steps {
                        withCredentials([
                            string(credentialsId: 'QUALYS_CLIENT_ID',     variable: 'CLIENT_ID'),
                            string(credentialsId: 'QUALYS_CLIENT_SECRET', variable: 'CLIENT_SECRET')
                        ]) {
                            sh """
                                ${params.QSCANNER_PATH} image ${env.NODE_IMAGE} \\
                                  --pod ${env.QUALYS_POD} \\
                                  --skip-verify-tls \\
                                  -l debug \\
                                  --client-id \$CLIENT_ID \\
                                  --client-secret \$CLIENT_SECRET \\
                                  --collect-build-pipeline-metadata=true
                            """
                        }
                    }
                }
            }
        }

        stage('Qualys Code Scan') {
            parallel {
                stage('Code scan python-app') {
                    steps {
                        withCredentials([
                            string(credentialsId: 'QUALYS_CLIENT_ID',     variable: 'CLIENT_ID'),
                            string(credentialsId: 'QUALYS_CLIENT_SECRET', variable: 'CLIENT_SECRET')
                        ]) {
                            sh """
                                ${params.QSCANNER_PATH} code ./apps/python-app \\
                                  --pod ${env.QUALYS_POD} \\
                                  --skip-verify-tls \\
                                  -l debug \\
                                  --client-id \$CLIENT_ID \\
                                  --client-secret \$CLIENT_SECRET \\
                                  --image ${env.PYTHON_IMAGE}
                            """
                        }
                    }
                }
                stage('Code scan node-app') {
                    steps {
                        withCredentials([
                            string(credentialsId: 'QUALYS_CLIENT_ID',     variable: 'CLIENT_ID'),
                            string(credentialsId: 'QUALYS_CLIENT_SECRET', variable: 'CLIENT_SECRET')
                        ]) {
                            sh """
                                ${params.QSCANNER_PATH} code ./apps/node-app \\
                                  --pod ${env.QUALYS_POD} \\
                                  --skip-verify-tls \\
                                  -l debug \\
                                  --client-id \$CLIENT_ID \\
                                  --client-secret \$CLIENT_SECRET \\
                                  --image ${env.NODE_IMAGE}
                            """
                        }
                    }
                }
            }
        }

    }

    post {
        success {
            echo """
=== Qualys Scan Complete ===
Branch  : ${env.BRANCH_TAG}
Commit  : ${env.GIT_COMMIT}
Python  : ${env.PYTHON_IMAGE}
Node    : ${env.NODE_IMAGE}
Query pivot_list with:
  buildPipelineMetadata.repositoryMetadata.repository:"https://github.com/surkadam/surtest.git"
  AND buildPipelineMetadata.repositoryMetadata.branch:"${env.BRANCH_TAG}"
  AND buildPipelineMetadata.repositoryMetadata.commits.hash:"${env.GIT_COMMIT}"
"""
        }
        failure {
            echo 'Pipeline failed — check qscanner output above for details.'
        }
    }
}
