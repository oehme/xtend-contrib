package de.oehme.xtend.contrib.base

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

import static extension de.oehme.xtend.contrib.base.ASTExtensions.*

/**
 * Transformations that are commonly used during active annotation processing
 */
class CommonTransformations {
	extension TransformationContext delegate

	new(TransformationContext delegate) {
		this.delegate = delegate
	}

	def hasToString(MutableClassDeclaration cls) {
		cls.hasExecutable("toString".signature)
	}

	/**
	 * Adds a toString method that prints all persistent fields of this class
	 */
	def addDataToString(MutableClassDeclaration cls) {
		cls.addMethod("toString") [
			returnType = string
			body = [extension ctx|
				'''
					return «guavaObjects.toJavaCode».toStringHelper(«cls.simpleName».class)
					«FOR a : cls.declaredFields»
						.add("«a.simpleName»",«a.simpleName»)
					«ENDFOR»
					.toString();
				''']
		]
	}

	def hasEquals(MutableClassDeclaration cls) {
		cls.hasExecutable("equals".signature(object))
	}

	/**
	 * Adds an equals method that compares all persistent fields of this class
	 */
	def addDataEquals(MutableClassDeclaration cls) {
		cls.addMethod("equals") [
			returnType = primitiveBoolean
			addParameter("o", object)
			body = [extension ctx|
				'''
					if (o instanceof «cls.simpleName») {
						«cls.simpleName» other = («cls.simpleName») o;
						return «cls.persistentState.join("\n&& ")[
						'''«guavaObjects.toJavaCode».equal(«simpleName», other.«simpleName»)''']»;
					}
					return false;
				''']
		]
	}

	def hasHashCode(MutableClassDeclaration cls) {
		cls.hasExecutable("hashCode".signature)
	}

	/**
	 * Adds a hashCode method that takes all persistent fields of this class
	 */
	def addDataHashCode(MutableClassDeclaration cls) {
		cls.addMethod("hashCode") [
			returnType = primitiveInt
			body = [extension ctx|
				'''return «guavaObjects.toJavaCode».hashCode(«cls.persistentState.join(",")[simpleName]»);''']
		]
	}

	private def guavaObjects() {
		"com.google.common.base.Objects".newTypeReference
	}
}
