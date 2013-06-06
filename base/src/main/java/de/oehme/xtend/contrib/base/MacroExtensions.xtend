package de.oehme.xtend.contrib.base

import com.google.common.collect.ImmutableList
import java.util.List
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

/**
 * Extension methods that help you with writing Xtend macros ("Active Annotations").
 */
class MacroExtensions {

	def static getSignature(MethodDeclaration method) {
		createSignature(method.simpleName, method.parameters.map[type])
	}

	def static createSignature(String name, List<? extends TypeReference> params) {
		new Signature(name, ImmutableList::copyOf(params))
	}

	def static hasMethod(ClassDeclaration cls, Signature sig) {
		cls.declaredMethods.exists[signature == sig]
	}

	/**
	 * Copies the header of the given base method so that you only have to add a body in most cases.
	 * You are free to modify the default settings, of course, e.g. widening the visibility of the
	 * implementing method.
	 */
	//TODO maybe just take the body instead of an initializer, because other modifications will be rare
	def static addImplementationFor(MutableClassDeclaration cls, MethodDeclaration baseMethod,
		(MutableMethodDeclaration)=>void init) {
		val method = cls.addMethod(baseMethod.simpleName) [
			visibility = baseMethod.visibility
			returnType = baseMethod.returnType
			exceptions = baseMethod.exceptions
			baseMethod.typeParameters.forEach[p|addTypeParameter(p.simpleName, p.upperBounds)]
			baseMethod.parameters.forEach[p|addParameter(p.simpleName, p.type)]
			varArgs = baseMethod.varArgs
			docComment = baseMethod.docComment
		]
		init.apply(method)
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
	 * Adds a toString method that prints all persistent fields of this class
	 */
	def static addDataToString(MutableClassDeclaration cls, extension TransformationContext context) {
		cls.addMethod("toString") [
			returnType = string
			body = [
				'''
					return com.google.common.base.Objects.toStringHelper(«cls.simpleName».class)
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
	def static addDataEquals(MutableClassDeclaration cls, extension TransformationContext ctx) {
		cls.addMethod("equals") [
			returnType = primitiveBoolean
			addParameter("o", object)
			body = [
				'''
					if (o instanceof «cls.simpleName») {
						«cls.simpleName» other = («cls.simpleName») o;
						return «cls.persistentState.join("\n&& ")[
						'''com.google.common.base.Objects.equal(«simpleName», other.«simpleName»)''']»;
					}
					return false;
				''']
		]
	}

	/**
	 * Adds a hashCode method that takes all persistent fields of this class
	 */
	def static addDataHashCode(MutableClassDeclaration cls, extension TransformationContext ctx) {
		cls.addMethod("hashCode") [
			returnType = primitiveInt
			body = ['''return com.google.common.base.Objects.hashCode(«cls.persistentState.join(",")[simpleName]»);''']
		]
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
