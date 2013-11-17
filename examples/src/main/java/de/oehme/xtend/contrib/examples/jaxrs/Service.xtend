package de.oehme.xtend.contrib.examples.jaxrs

import de.oehme.xtend.contrib.jaxrs.AutoPath
import javax.ws.rs.GET
import javax.ws.rs.POST
import javax.ws.rs.Path

@AutoPath
class JaxRsService {
	@GET
	def find() {
	}

	@POST
	def saveString(String arg) {
	}

	def notJAXRS() {
	}

	@GET
	@Path("/custom")
	def pathDeclared() {
	}
}
