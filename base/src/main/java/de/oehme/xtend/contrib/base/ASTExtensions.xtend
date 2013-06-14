package de.oehme.xtend.contrib.base

import com.google.common.collect.ImmutableList
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

/**
 * Extension methods that help you inspect and manipulate
 * the Java AST during Xtend active annotation processing
 */
class ASTExtensions {

	def static signature(ExecutableDeclaration it) {
		signature(simpleName, parameters.map[p|p.type])
	}

	def static constructorSignature(ClassDeclaration cls, TypeReference... params) {
		signature(cls.simpleName, params)
	}

	def static signature(String name, TypeReference... params) {
		new Signature(name, ImmutableList::copyOf(params))
	}

	def static hasExecutable(ClassDeclaration cls, Signature sig) {
		cls.declaredMembers.filter(typeof(ExecutableDeclaration)).exists[signature == sig]
	}

	def static hasDataConstructor(ClassDeclaration cls) {
		cls.hasExecutable(constructorSignature(cls, cls.persistentState.map[type]))
	}

	/**
	 * Adds a constructor that takes all non-transient fields of this class.
	 */
	def static addDataConstructor(MutableClassDeclaration cls) {
		cls.addConstructor [
			val fields = persistentState(cls)
			fields.forEach [ f |
				addParameter(f.simpleName, f.type)
			]
			body = [
				'''
					«FOR f : fields»
						this.«f.simpleName» = «f.simpleName»;
					«ENDFOR»
				''']
		]
	}

	/**
	 * Copies the header of the given base method so that you only have to add a body in most cases.
	 * You are free to modify the default settings, of course, e.g. widening the visibility of the
	 * implementing method.
	 */
	def static addImplementationFor(MutableClassDeclaration cls, MethodDeclaration baseMethod,
		CompilationStrategy implementation) {
		val method = cls.addMethod(baseMethod.simpleName) [
			visibility = baseMethod.visibility
			returnType = baseMethod.returnType
			exceptions = baseMethod.exceptions
			baseMethod.typeParameters.forEach[p|addTypeParameter(p.simpleName, p.upperBounds)]
			baseMethod.parameters.forEach[p|addParameter(p.simpleName, p.type)]
			varArgs = baseMethod.varArgs
			docComment = baseMethod.docComment
			body = implementation
		]
		method
	}

	/**
	 * Moves the body of this method to a new private method with the given name.
	 * The original method then gets the newly specified body which can delegate to the inner method.
	 * @return the inner method.
	 */
	def static addIndirection(MutableMethodDeclaration wrapper, String innerMethodName, CompilationStrategy indirection) {
		val inner = wrapper.declaringType.addMethod(innerMethodName) [
			static = wrapper.static
			returnType = wrapper.returnType
			exceptions = wrapper.exceptions
			wrapper.typeParameters.forEach[p|addTypeParameter(p.simpleName, p.upperBounds)]
			wrapper.parameters.forEach[p|addParameter(p.simpleName, p.type)]
			varArgs = wrapper.varArgs
			visibility = Visibility::PRIVATE
			body = wrapper.body
		]
		wrapper.body = indirection
		inner
	}

	def static addGetter(MutableFieldDeclaration field) {
		field.declaringType.addMethod("get" + field.simpleName.toFirstUpper) [
			returnType = field.type
			body = [
				'''
					return «field.simpleName»;
				''']
		]
	}

	def static addSetter(MutableFieldDeclaration field) {
		field.declaringType.addMethod("set" + field.simpleName.toFirstUpper) [
			addParameter(field.simpleName, field.type)
			body = [
				'''this.«field.simpleName» = «field.simpleName»;'''
			]
		]
	}

	/**
	 * All non-static, non-transient fields of this class
	 */
	def static persistentState(ClassDeclaration cls) {
		cls.declaredFields.filter[!transient && !static]
	}

	/**
	 * All non-static, non-transient fields of this class
	 */
	def static persistentState(MutableClassDeclaration cls) {
		cls.declaredFields.filter[!transient && !static]
	}

	def static dispatch isStatic(FieldDeclaration field) {
		field.static
	}

	def static dispatch isStatic(MethodDeclaration method) {
		method.static
	}

	def static dispatch setStatic(MutableMethodDeclaration method, boolean isStatic) {
		method.static = isStatic
	}

	def static dispatch setStatic(MutableFieldDeclaration field, boolean isStatic) {
		field.static = isStatic
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
