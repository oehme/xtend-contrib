package de.oehme.xtend.contrib.base

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static extension de.oehme.xtend.contrib.base.ASTExtensions.*

/**
 * Creates a decorator for the given interface.
 * It will contain a {@code delegate} field, a constructor that takes the delegate as a parameter
 * and default implementations for all methods.
 * You only need to customize the methods you are really interested in.
 */
@Active(typeof(DecoratorProcessor))
annotation Decorator {
	Class<?> value;
}

//TODO how will we handle generics?
class DecoratorProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {

		//fails due to https://bugs.eclipse.org/bugs/show_bug.cgi?id=409600
		//val forwarding = findTypeGlobally(typeof(Decorator))
		//val iface = cls.findAnnotation(forwarding).getValue('value') as InterfaceDeclaration
		val iface = typeof(CharSequence).findTypeGlobally as InterfaceDeclaration // dummy for testing

		iface.declaredMethods.forEach [ declared |
			if (!cls.hasExecutable(declared.signature)) {
				cls.addImplementationFor(declared) [
					'''
						«declared.maybeReturn» delegate.«declared.simpleName»(«declared.parameters.join(",")[simpleName]»);
					'''
				]
			}
		]

		cls.addField("delegate") [
			type = iface.newTypeReference
		]
		if(!cls.hasDataConstructor) cls.addDataConstructor
	}

	def maybeReturn(MethodDeclaration declared) {
		if(!declared.returnType.void) "return"
	}
}
