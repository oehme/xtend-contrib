package de.oehme.xtend.contrib.examples.base

import de.oehme.xtend.contrib.base.Immutable

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
