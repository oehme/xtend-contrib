package de.oehme.xtend.contrib

import org.eclipse.xtend.lib.macro.AbstractMethodProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration

/**
 * Has the same effect as the Java keyword of the same name.
 */
@Active(SynchronizedProcessor)
annotation Synchronized {
}

class SynchronizedProcessor extends AbstractMethodProcessor {

	override doTransform(MutableMethodDeclaration annotatedMethod,
		extension TransformationContext context) {
		annotatedMethod.synchronized = true
	}

}
