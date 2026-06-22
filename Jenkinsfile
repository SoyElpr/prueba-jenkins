pipeline {
    agent any

    environment {
        // Configuramos las variables para que dotnet se encuentre en el PATH
        DOTNET_ROOT = "${env.WORKSPACE}/.dotnet"
        PATH = "${env.WORKSPACE}/.dotnet:${env.PATH}"
        DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Instalar .NET SDK') {
            steps {
                sh '''
                    echo "Descargando e instalando .NET SDK 8.0 localmente en Jenkins..."
                    curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
                    chmod +x ./dotnet-install.sh
                    ./dotnet-install.sh --channel 8.0 --install-dir ./.dotnet
                    dotnet --info
                '''
            }
        }

        stage('Restaurar Paquetes y Compilar Pruebas') {
            steps {
                sh 'dotnet build Capa_Pruebas/Capa_Pruebas.csproj'
            }
        }

        stage('Ejecutar Pruebas de Conexión') {
            steps {
                // Este paso probará la conexión a la base de datos SQL Server y MongoDB.
                // Se utiliza 'host.docker.internal' en el código para que alcance la máquina host.
                sh 'dotnet test Capa_Pruebas/Capa_Pruebas.csproj --logger "trx;LogFileName=test_results.trx"'
            }
        }
    }

    post {
        always {
            // Archivar los resultados de la prueba para mostrarlos en la UI de Jenkins
            archiveArtifacts artifacts: '**/*.trx', allowEmptyArchive: true
        }
        success {
            echo '¡El pipeline se completó correctamente y las conexiones a BD son exitosas!'
        }
        failure {
            echo 'El pipeline falló. Por favor, revisa los logs de Jenkins.'
        }
    }
}
