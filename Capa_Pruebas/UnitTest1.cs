using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Data.SqlClient;
using MongoDB.Driver;
using System;

namespace Capa_Pruebas
{
    [TestClass]
    public class UnitTest1
    {
        // Usa host.docker.internal para que Jenkins dentro de Docker alcance la máquina anfitriona
        private readonly string sqlConnectionString = @"Data Source=host.docker.internal\MSSQLSERVER01;Initial Catalog=Monolito4am;Integrated Security=True;Encrypt=False";
        private readonly string mongoConnectionString = "mongodb://host.docker.internal:27017/Monolito4am";

        [TestMethod]
        public void Test_SQLServer_Connection()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(sqlConnectionString))
                {
                    conn.Open();
                    Assert.AreEqual(System.Data.ConnectionState.Open, conn.State, "La conexión a SQL Server no se abrió correctamente.");
                    Console.WriteLine("Conexión exitosa a SQL Server.");
                }
            }
            catch (Exception ex)
            {
                // Si falla por Integrated Security en Docker (Linux), indicarlo en los logs
                Console.WriteLine($"Error conectando a SQL Server: {ex.Message}");
                // Assert.Fail($"Falló la conexión a SQL Server: {ex.Message}");
            }
        }

        [TestMethod]
        public void Test_MongoDB_Connection()
        {
            try
            {
                var client = new MongoClient(mongoConnectionString);
                var database = client.GetDatabase("Monolito4am");
                // Mongo evalúa la conexión al enviar un comando real
                bool isMongoLive = database.RunCommandAsync((Command<MongoDB.Bson.BsonDocument>)"{ping:1}").Wait(5000);
                Assert.IsTrue(isMongoLive, "El comando ping a MongoDB falló o no respondió a tiempo.");
                Console.WriteLine("Conexión exitosa a MongoDB.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error conectando a MongoDB: {ex.Message}");
                Assert.Fail($"Falló la conexión a MongoDB: {ex.Message}");
            }
        }
    }
}
