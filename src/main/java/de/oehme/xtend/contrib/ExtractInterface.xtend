package de.oehme.xtend.contrib

import de.oehme.xtend.contrib.macro.CommonTransformations
import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension de.oehme.xtend.contrib.macro.CommonQueries.*

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Active(ExtractInterfaceProcessor)
annotation ExtractInterface {
}

class ExtractInterfaceProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration cls, RegisterGlobalsContext context) {
		context.registerInterface(cls.qualifiedInterfaceName)
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val extension CommonTransformations = new CommonTransformations(context)
		findInterface(cls.qualifiedInterfaceName) => [ iface |
			iface.primarySourceElement = cls
			val typeParameterMappings = newHashMap
			cls.typeParameters.forEach[p|
				val copy = iface.addTypeParameter(p.simpleName, p.upperBounds)
				typeParameterMappings.put(p.newTypeReference, copy.newTypeReference)
			]
			cls.implementedInterfaces = cls.implementedInterfaces + #[iface.newTypeReference(cls.typeParameters.map[newSelfTypeReference])]
			cls.newSelfTypeReference.declaredResolvedMethods
			.filter[declaration.visibility == Visibility.PUBLIC && declaration.static == false]
			.forEach [ method |
				iface.addMethod(method.declaration.simpleName) [
					primarySourceElement = method.declaration
					copySignatureFrom(method, typeParameterMappings)
					visibility = Visibility.PUBLIC
					abstract = true
				]
			]
		]
	}

	def String qualifiedInterfaceName(ClassDeclaration cls) '''«cls.packageName».«cls.
		simpleInterfaceName»'''

	def simpleInterfaceName(ClassDeclaration cls) {
		val simpleName = cls.simpleName
		if(simpleName.startsWith("Default")) {
			simpleName.substring(7)
		} else if(simpleName.endsWith("Impl")) {
			simpleName.substring(0, simpleName.length - 4)
		} else {
			throw new IllegalArgumentException(
				"Class name must start with 'Default' or end with 'Impl'")
		}
	}
}
