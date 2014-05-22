package de.oehme.xtend.contrib

import de.oehme.xtend.contrib.macro.CommonTransformations
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration

/**
 * Adds a getter to the annotated field
 */
@Active(PropertyProcessor)
annotation Property {
}

class PropertyProcessor extends AbstractFieldProcessor {

	override doTransform(MutableFieldDeclaration annotatedField, extension TransformationContext context) {
		val extension transformations = new CommonTransformations(context)
		annotatedField.addGetter
		annotatedField.addSetter
		annotatedField.markAsRead
	}

}
