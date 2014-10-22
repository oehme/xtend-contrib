package de.oehme.xtend.contrib.examples

import de.oehme.xtend.contrib.ExtractInterface

@ExtractInterface
class DefaultThing {
	override int findSomething(String arg) {
		arg.lastIndexOf("something")
	}
	
	def static void main(String[] args) {
		val Thing thing = new DefaultThing
		thing.findSomething("There is something")
	}
}
