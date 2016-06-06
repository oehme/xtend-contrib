package de.oehme.xtend.contrib.logging.log4j

import com.google.common.annotations.Beta
import java.lang.annotation.Target
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

/**
 * Adds a Logger field to this class  
 */
@Beta
@Target(TYPE)
@Active(Log4jProcessor)
annotation Log4j {
}

class Log4jProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		cls.addField("log") [
			static = true
			final = true
			type = Logger.newTypeReference
			initializer = '''
				«Logger».getLogger("«cls.qualifiedName»")
			'''
			primarySourceElement = cls
		]
	}
}
