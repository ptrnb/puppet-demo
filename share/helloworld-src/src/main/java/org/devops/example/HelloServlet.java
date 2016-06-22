package org.devops.example;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Properties;
import java.util.Enumeration;

public class HelloServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/plain");
		response.setStatus(200);
		Properties theProps;
        theProps = System.getProperties();   
		PrintWriter writer = response.getWriter();
		writer.println("Hello from " + System.getenv("LOGNAME"));
        writer.println("-------- Server Java System properties ---------------") ;
		// if(request.getParameter("long")!=null){
			// Enumeration enprop = theProps.propertyNames() ;
			// String key = "";
			// while ( enprop.hasMoreElements() ){
				// key = (String) enprop.nextElement() ;
				// writer.println(key+"\t"+theProps.getProperty(key)) ;
			// }
            // writer.close();
            // return;
		// }
        // theProps.list(writer);  // abbreviated listing is default.
        writer.close(); 

	}
}
