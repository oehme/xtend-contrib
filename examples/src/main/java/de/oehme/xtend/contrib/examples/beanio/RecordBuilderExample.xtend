package de.oehme.xtend.contrib.examples.beanio

import org.beanio.builder.RecordBuilder
import org.beanio.builder.FieldBuilder
import org.beanio.builder.Align
import static extension de.oehme.xtend.contrib.beanio.BeanioBuilderExtensions.*

class RecordBuilderExample {

	def vanilla() {
		new RecordBuilder("Foo") => [
			addField(
				new FieldBuilder("Bar") => [
					rid
					align = Align::LEFT
					at = 50
					defaultValue = "Baz"
				]
			)
		]
	}

	//one less level of indentation
	def withExtensions() {
		new RecordBuilder("Foo") => [
			addField("Bar") [
				rid
				align = Align::LEFT
				at = 50
				defaultValue = "Baz"
			]
		]
	}
}
