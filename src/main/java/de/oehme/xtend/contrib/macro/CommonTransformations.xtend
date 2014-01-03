package de.oehme.xtend.contrib.macro

import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static extension de.oehme.xtend.contrib.macro.CommonQueries.*

/**
 * Commonly used AST transformations. These are only useful during the "doTransform" step 
 * of active annotation processing and make use of the TransformationContext.
 * 
 * You should use this as an extension for maximum convenience, e.g.:
 * 
 * <pre>
 * override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
 *	val extension transformations = new CommonTransformations(context)
 *	...
 * }
 * </pre>
 */
class CommonTransformations {
	extension TransformationContext delegate

	new(TransformationContext delegate) {
		this.delegate = delegate
	}

	/**
	 * Adds a constructor that takes all non-transient fields of this class.
	 */
	def addDataConstructor(MutableClassDeclaration cls) {
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

	/**
	 * Adds a hashCode method that takes all persistent fields of this class
	 */
	def addDataHashCode(MutableClassDeclaration cls) {
		cls.addMethod("hashCode") [
			returnType = primitiveInt
			body = [extension ctx|
				'''return «guavaObjects.toJavaCode».hashCode(«cls.persistentState.join(",")[
					simpleName]»);''']
		]
	}

	/**
	 * Copies the header of the given base method so that you only have to add a body in most cases.
	 * You are free to modify the default settings, of course, e.g. widening the visibility of the
	 * implementing method.
	 */
	def addImplementationFor(MutableClassDeclaration cls, MethodDeclaration baseMethod,
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
	def addIndirection(MutableMethodDeclaration wrapper, String innerMethodName,
		CompilationStrategy indirection) {
		val inner = wrapper.declaringType.addMethod(innerMethodName) [
			static = wrapper.static
			returnType = wrapper.returnType
			exceptions = wrapper.exceptions
			wrapper.typeParameters.forEach[p|addTypeParameter(p.simpleName, p.upperBounds)]
			wrapper.parameters.forEach[p|addParameter(p.simpleName, p.type)]
			varArgs = wrapper.varArgs
			visibility = Visibility.PRIVATE
			body = wrapper.body
		]
		wrapper.body = indirection
		inner
	}

	def addGetter(MutableFieldDeclaration field) {
		field.declaringType.addMethod("get" + field.simpleName.toFirstUpper) [
			returnType = field.type
			body = [
				'''
					return «field.simpleName»;
				''']
		]
	}

	def addSetter(MutableFieldDeclaration field) {
		field.declaringType.addMethod("set" + field.simpleName.toFirstUpper) [
			addParameter(field.simpleName, field.type)
			body = [
				'''this.«field.simpleName» = «field.simpleName»;'''
			]
		]
	}

	def dispatch setStatic(MutableMethodDeclaration method, boolean isStatic) {
		method.static = isStatic
	}

	def dispatch setStatic(MutableFieldDeclaration field, boolean isStatic) {
		field.static = isStatic
	}

	private def guavaObjects() {
		"com.google.common.base.Objects".newTypeReference
	}
}
