package de.oehme.xtend.contrib.examples

import de.oehme.xtend.contrib.Buildable
import org.eclipse.xtend.lib.annotations.Data

@Data
@Buildable
class Person {
	String firstName
	String lastName
	int age
	
	def static void main(String[] args) {
		//Java style
		val me = Person.builder.firstName("Stefan").lastName("Oehme").age(27).build
		println(me)
		//Xtend style
		val john = Person.build [
			firstName = "John"
			lastName = "Doe"
			age = -1
		]
		println(john)
	}
	
}