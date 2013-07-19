package de.oehme.xtend.contrib.base

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension de.oehme.xtend.contrib.base.ASTExtensions.*

@Active(ExtractInterfaceProcessor)
annotation ExtractInterface {
}

class ExtractInterfaceProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration cls, RegisterGlobalsContext context) {
		context.registerInterface(cls.qualifiedInterfaceName)
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		findInterface(cls.qualifiedInterfaceName) => [ iface |
			cls.implementedInterfaces = cls.implementedInterfaces + #[iface.newTypeReference]
			cls.declaredMethods.filter [visibility == Visibility.PUBLIC static == false]
			.forEach [ method |
				iface.addMethod(method.simpleName) [ extracted |
					extracted.visibility = Visibility.PUBLIC
					//blocked on https://bugs.eclipse.org/bugs/show_bug.cgi?id=412361
					//method.typeParameters.forEach[extracted.addTypeParameter(simpleName, upperBounds)]
					extracted.returnType = method.returnType
					method.parameters.forEach[extracted.addParameter(simpleName, type)]
					extracted.varArgs = method.varArgs
					extracted.docComment = method.docComment
					extracted.exceptions = method.exceptions
				]
			]
		]
	}

	def String qualifiedInterfaceName(ClassDeclaration cls) '''«cls.packageName».«cls.simpleInterfaceName»'''

	def simpleInterfaceName(ClassDeclaration cls) {
		val simpleName = cls.simpleName
		if (simpleName.startsWith("Default")) {
			simpleName.substring(7)
		} else if (simpleName.endsWith("Impl")) {
			simpleName.substring(0, simpleName.length - 4)
		} else {
			throw new IllegalArgumentException("Class name must start with 'Default' or end with 'Impl'")
		}
	}
}
