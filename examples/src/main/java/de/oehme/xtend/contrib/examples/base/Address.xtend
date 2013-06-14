package de.oehme.xtend.contrib.examples.base

import de.oehme.xtend.contrib.base.ValueObject

@ValueObject class Address {
	String street
	String city
	String zip
	String postOfficeBox
}