package de.oehme.xtend.contrib.examples.localization

import de.oehme.xtend.contrib.localization.Messages
import java.util.Date
import java.util.Locale

@Messages class MyMessages {
	def static void main(String[] args) {
		val messages = new MyMessages(Locale.GERMAN)
		println(messages.hello("Stefan", new Date))
		print(messages.trains(3))
	}
}