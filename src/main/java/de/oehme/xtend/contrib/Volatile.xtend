package de.oehme.xtend.contrib

import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

/**
 * Has the same effect as the Java keyword of the same name.
 */
@Active(VolatileProcessor)
annotation Volatile {
}

class VolatileProcessor extends AbstractFieldProcessor {

	override doTransform(MutableFieldDeclaration annotatedField,
		extension TransformationContext context) {
		annotatedField.volatile = true
	}

}
