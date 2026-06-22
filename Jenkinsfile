pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Restaurar Paquetes y Compilar Pruebas') {
            steps {
                // Asumiendo que el agente de Jenkins tiene dotnet instalado.
                // Si este Jenkins corre en un contenedor Linux estándar sin .NET, 
                // necesitará un agente (node) de Windows o un contenedor con .NET SDK.
                // El comando intentará restaurar y compilar.
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
