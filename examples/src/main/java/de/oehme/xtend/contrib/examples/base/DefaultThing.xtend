package de.oehme.xtend.contrib.examples.base

import de.oehme.xtend.contrib.base.ExtractInterface

@ExtractInterface
class DefaultThing {
	override foo() {

	}

	override bar(String baz) {
		"foobar"
	}
}