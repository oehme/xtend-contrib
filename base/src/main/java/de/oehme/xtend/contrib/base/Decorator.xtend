package de.oehme.xtend.contrib.base

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration

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

//TODO handle generics
class DecoratorProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {

		//fails due to https://bugs.eclipse.org/bugs/show_bug.cgi?id=409600
		//val forwarding = findTypeGlobally(typeof(Decorator))
		//val iface = cls.findAnnotation(forwarding).getValue('value') as InterfaceDeclaration
		val iface = typeof(CharSequence).findTypeGlobally as InterfaceDeclaration // dummy for testing

		iface.declaredMethods.forEach [ declared |
			if (!cls.hasMethod(declared)) {
				cls.addMethod(declared.simpleName) [ delegated |
					delegated.returnType = declared.returnType
					declared.parameters.forEach[delegated.addParameter(simpleName, type)]
					delegated.body = [
						'''
							«declared.maybeReturn» delegate.«declared.simpleName»(«declared.parameters.join(",")[simpleName]»);
						''']
				]
			}
		]

		cls.addField("delegate") [
			type = iface.newTypeReference
		]
		cls.addConstructor [
			addParameter("delegate", iface.newTypeReference)
			body = [
				'''
					this.delegate = delegate;
				''']
		]
	}

	def hasMethod(MutableClassDeclaration cls, MethodDeclaration method) {
		cls.declaredMethods.exists[signatureMatches(method)]
	}

	def signatureMatches(MethodDeclaration left, MethodDeclaration right) {
		left.simpleName == right.simpleName && left.parametersMatch(right)
	}

	def parametersMatch(MethodDeclaration left, MethodDeclaration right) {
		if (left.parameters.size != right.parameters.size) {
			false
		} else {
			for (i : 0 ..< left.parameters.size) {
				if (!left.parameters.get(i).matches(right.parameters.get(i))) {
					return false
				}
			}
			true
		}
	}

	def matches(ParameterDeclaration left, ParameterDeclaration right) {
		left.type == right.type
	}

	def maybeReturn(MethodDeclaration declared) {
		if(!declared.returnType.void) "return"
	}
}
