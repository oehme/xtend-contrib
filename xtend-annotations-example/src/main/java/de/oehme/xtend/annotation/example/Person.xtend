package de.oehme.xtend.annotation.example

import de.oehme.xtend.annotation.data.DataConstructor

class Person {
	@DataConstructor
	new(String name, int age){
		println("Person created");
	}
}

class PersonTest {
	def static void main(String[] args) {
		val p = new Person("name",14)
		println(p.name == "name")
		println(p.age == 14)
	}

}
 