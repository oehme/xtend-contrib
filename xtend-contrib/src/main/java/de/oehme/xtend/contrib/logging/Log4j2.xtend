package de.oehme.xtend.contrib.logging

import com.google.common.annotations.Beta
import java.lang.annotation.Target
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.Logger
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

/**
 * Adds a Logger field to this class  
 */
@Beta
@Target(TYPE)
@Active(Log4j2Processor)
annotation Log4j2 {
}

class Log4j2Processor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		cls.addField("log") [
			static = true
			final = true
			type = Logger.newTypeReference
			initializer = '''
				«LogManager».getLogger("«cls.qualifiedName»")
			'''
			primarySourceElement = cls
		]
	}
}
