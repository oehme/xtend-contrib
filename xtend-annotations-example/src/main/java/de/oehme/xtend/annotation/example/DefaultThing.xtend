package de.oehme.xtend.annotation.example

import de.oehme.xtend.annotation.extract.ExtractInterface

@ExtractInterface
class DefaultThing {
	def foo() {

	}

	def bar(String baz) {
		"foobar"
	}
}