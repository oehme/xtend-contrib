package de.oehme.xtend.contrib.examples

import de.oehme.xtend.contrib.Buildable
import org.eclipse.xtend.lib.annotations.Data

@Data
@Buildable
class Person {
	String firstName
	String lastName
	int age
}

class Main {
	def static void main(String[] args) {
		create()
		copy()
	}

	def static void create() {
		// Java style
		val me = Person.builder.firstName("Stefan").lastName("Oehme").age(27).build
		println(me)
		// Xtend style
		val john = Person.build [
			firstName = "John"
			lastName = "Doe"
			age = -1
		]
		println(john)
	}

	def static void copy() {
		val me = Person.builder.firstName("Stefan").lastName("Oehme").age(27).build
		// Java style
		val older_me = me.copy.age(28).build
		println(older_me)
		// Xtend style
		val john = me.copy [
			firstName = "John"
		]
		println(john)
	}

}
