package de.oehme.xtend.annotation.example

import de.oehme.xtend.annotation.data.Immutable

@Immutable
class Address {
	String street;
	String city;
	String zip;
	String postOfficeBox
}

class AddressTest {
	def foo() {
		val address = Address::build[
			street = "Fleet Street"
			city = "London"
		]

		address.hashCode
	}

}
