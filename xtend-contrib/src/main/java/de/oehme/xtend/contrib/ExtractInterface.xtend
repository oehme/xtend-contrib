package de.oehme.xtend.contrib

import com.google.common.annotations.Beta
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

/**
 * Extracts an interface from this class, pulling up all public, non-static methods. The class must either have the
 * 'Default'-prefix or 'Impl'-suffix.
 */
@Beta
@Target(ElementType.TYPE)
@Active(ExtractInterfaceProcessor)
annotation ExtractInterface {
}

class ExtractInterfaceProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration cls, RegisterGlobalsContext context) {
		context.registerInterface(cls.qualifiedInterfaceName)
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val extension SignatureHelper = new SignatureHelper(context)
		findInterface(cls.qualifiedInterfaceName) => [ iface |
			iface.primarySourceElement = cls
			val typeParameterMappings = newHashMap
			cls.typeParameters.forEach [ p |
				val copy = iface.addTypeParameter(p.simpleName, p.upperBounds)
				typeParameterMappings.put(p.newTypeReference, copy.newTypeReference)
			]
			val interfaceWithTypeParameters = iface.newTypeReference(cls.typeParameters.map[newSelfTypeReference])
			cls.implementedInterfaces = cls.implementedInterfaces + #[interfaceWithTypeParameters]
			val apiMethods = cls.newSelfTypeReference.declaredResolvedMethods.filter[
				declaration.visibility == Visibility.PUBLIC && declaration.static == false]
			apiMethods.forEach [ method |
				if (method.declaration.returnType.isInferred) {
					method.declaration.addError("@ExtractInterface does not support inferred return types")
				}
				iface.addMethod(method.declaration.simpleName) [
					primarySourceElement = method.declaration
					copySignatureFrom(method, typeParameterMappings)
					visibility = Visibility.PUBLIC
					abstract = true
				]
			]
		]
	}

	def String qualifiedInterfaceName(ClassDeclaration cls) '''«cls.compilationUnit.packageName».«cls.simpleInterfaceName»'''

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
