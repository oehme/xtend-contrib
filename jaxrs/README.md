Generate JAX-RS @Path annotations based on method name.

Usage:

	@AutoPath
	@Produces(MediaType.APPLICATION_JSON)
	class MyService {
	
		@GET
		def findAll() {	}
		
		@POST
		def save() { }
		
		def notPublishedMethod() { }
		
		@Path('/this-is-left-unchenged')
		def foo() {	}
	}

The above is equivalent to:	
	
	@Path('/my-service')
	@Produces(MediaType.APPLICATION_JSON)
	class MyService {
	
		@GET @Path('/find-all')
		def findAll() {	}
		
		@POST @Path('/save')
		def save() { }
		
		def notPublishedMethod() { }
		
		@Path('/this-is-left-unchenged')
		def foo() {	}
	}

