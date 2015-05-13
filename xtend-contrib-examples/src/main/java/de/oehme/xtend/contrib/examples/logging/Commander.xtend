package de.oehme.xtend.contrib.examples.logging

import de.oehme.xtend.contrib.logging.Log

@Log
class Commander {
	def whatIsThis() {
		log.warning("It's a trap!")
	}
}
