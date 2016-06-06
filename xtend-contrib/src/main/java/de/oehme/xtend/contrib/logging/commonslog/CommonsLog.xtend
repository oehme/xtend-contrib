package de.oehme.xtend.contrib.logging.commonslog

import com.google.common.annotations.Beta
import java.lang.annotation.Target
import org.apache.commons.logging.LogFactory
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

/**
 * Adds a Logger field to this class  
 */
@Beta
@Target(TYPE)
@Active(CommonsLogProcessor)
annotation CommonsLog {
}

class CommonsLogProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		cls.addField("log") [
			static = true
			final = true
			type = org.apache.commons.logging.Log.newTypeReference
			initializer = '''
				«LogFactory».getLog("«cls.qualifiedName»")
			'''
			primarySourceElement = cls
		]
	}
}