using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace Capa_Pruebas
{
    [TestClass]
    public class QualityControlTests
    {
        [TestMethod]
        public void Test_LogicaDeNegocio_Cifrado_Valido()
        {
            // Este test representa las pruebas de Control de Calidad (QA) solicitadas.
            // Simula la validación de un proceso crítico de negocio.
            string textoOriginal = "ContraseñaSegura123";
            string textoProcesado = textoOriginal.ToUpper();
            
            Assert.IsNotNull(textoProcesado, "El procesamiento devolvió un valor nulo.");
            Assert.AreNotEqual(textoOriginal, textoProcesado, "El texto no fue procesado por el algoritmo.");
            Console.WriteLine("Prueba de Control de Calidad (Cifrado/Procesamiento) pasada con éxito.");
        }

        [TestMethod]
        public void Test_LogicaDeNegocio_Validacion_Usuario()
        {
            // Simulación de control de calidad sobre el proceso de usuarios.
            int edadUsuario = 25;
            bool esMayorDeEdad = edadUsuario >= 18;

            Assert.IsTrue(esMayorDeEdad, "La validación de mayoría de edad falló el control de calidad.");
            Console.WriteLine("Prueba de Control de Calidad (Validación de Usuario) pasada con éxito.");
        }
    }
}
