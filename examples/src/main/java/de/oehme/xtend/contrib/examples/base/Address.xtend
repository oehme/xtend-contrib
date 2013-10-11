package de.oehme.xtend.contrib.examples.base

import de.oehme.xtend.contrib.base.ValueObject

@ValueObject class Address {
	String street
	String city
	String zip
	String postOfficeBox
}

class AddressBuilder {
	/*You can customize the builder if you want, 
	* for instance add Annotations or convenience methods.
	*/
}
