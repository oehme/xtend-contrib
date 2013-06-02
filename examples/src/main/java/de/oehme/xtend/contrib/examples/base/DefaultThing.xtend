package de.oehme.xtend.contrib.examples.base

import de.oehme.xtend.contrib.base.ExtractInterface

@ExtractInterface
class DefaultThing {
	def foo() {

	}

	def bar(String baz) {
		"foobar"
	}
}