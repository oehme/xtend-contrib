package de.oehme.xtend.contrib

import java.lang.annotation.Target
import java.util.logging.Logger
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Target(TYPE)
@Active(LoggerProcessor)
annotation WithLogger {
}

class LoggerProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		cls.addField("logger") [
			static = true
			final = true
			type = Logger.newTypeReference
			initializer = '''
				«Logger».getLogger("«cls.qualifiedName»")
			'''
			addAnnotation(Extension.newAnnotationReference)
			primarySourceElement = cls
		]
	}

}
