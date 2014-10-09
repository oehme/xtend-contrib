package de.oehme.xtend.contrib.macro

import com.google.common.collect.ImmutableList
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference

/**
 * AST-Queries which are useful during all the phases of active annotation processing. 
 * The helper methods in this class will always be static, so it is safe to use them as a static extension.
 */
class CommonQueries {

	def static signature(String name, TypeReference... params) {
		new Signature(name, ImmutableList.copyOf(params))
	}

	def static signature(ExecutableDeclaration it) {
		signature(simpleName, parameters.map[p|p.type])
	}

	def static constructorSignature(ClassDeclaration cls, TypeReference... params) {
		signature(cls.simpleName, params)
	}

	def static hasExecutable(ClassDeclaration cls, Signature sig) {
		cls.declaredMembers.filter(ExecutableDeclaration).exists[signature == sig]
	}

	def static dispatch isStatic(FieldDeclaration field) {
		field.static
	}

	def static dispatch isStatic(MethodDeclaration method) {
		method.static
	}

	def static dispatch propertyType(FieldDeclaration field) {
		field.type
	}

	def static dispatch propertyType(MethodDeclaration method) {
		method.returnType
	}

	def static packageName(ClassDeclaration cls) {
		val parts = cls.qualifiedName.split("\\.")
		parts.take(parts.size - 1).join(".")
	}
}

/**
 * A signature represents the simple name and parameter types of a method.
 * These parts are what is needed for two methods to be considered "duplicates".
 * Note that this implementation is not aware of type erasure,
 * so it will fail to detect duplicates that have the same erasure.
 */
@Data final class Signature {
	String name
	ImmutableList<? extends TypeReference> parameterTypes

	override toString() {
		'''«name»(«parameterTypes.join(",")[name]»)'''
	}
}
