using System;
using System.Net;
using System.Net.Mail;

public class TestEmail {
    public static void Main() {
        string user = "guerragabriel827@gmail.com";
        string pass = "cpmy ytzx sghs bzfy";
        
        try {
            using (var smtp = new SmtpClient("smtp.gmail.com", 587)) {
                smtp.EnableSsl = true;
                smtp.UseDefaultCredentials = false;
                smtp.Credentials = new NetworkCredential(user, pass);
                
                var msg = new MailMessage {
                    From = new MailAddress(user, "Test Monolito"),
                    Subject = "Test SMTP",
                    Body = "<h1>Success!</h1> SMTP is working.",
                    IsBodyHtml = true
                };
                msg.To.Add(user);
                
                Console.WriteLine("Sending...");
                smtp.Send(msg);
                Console.WriteLine("Sent successfully!");
            }
        } catch (Exception ex) {
            Console.WriteLine("Error: " + ex.Message);
            if (ex.InnerException != null) Console.WriteLine("Inner: " + ex.InnerException.Message);
        }
    }
}
