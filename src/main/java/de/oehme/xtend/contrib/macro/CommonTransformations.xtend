package de.oehme.xtend.contrib.macro

import com.google.common.collect.Maps
import java.util.Map
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.ResolvedMethod
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend2.lib.StringConcatenationClient

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
	 * Copies the header of the given base method so that you only have to add a body in most cases.
	 * You are free to modify the default settings, of course, e.g. widening the visibility of the
	 * implementing method.
	 */
	def addImplementationFor(MutableClassDeclaration cls, ResolvedMethod baseMethod, CompilationStrategy implementation) {
		createImplementation(cls, baseMethod) => [
			body = implementation
		]
	}

	def addImplementationFor(MutableClassDeclaration cls, ResolvedMethod baseMethod,
		StringConcatenationClient implementation) {
		createImplementation(cls, baseMethod) => [
			body = implementation
		]
	}

	def private createImplementation(MutableClassDeclaration cls, ResolvedMethod baseMethod) {
		cls.addMethod(baseMethod.declaration.simpleName) [
			copySignatureFrom(baseMethod)
			abstract = false
			primarySourceElement  baseMethod.declaration
		]
	}

	/**
	 * Moves the body of this method to a new private method with the given name.
	 * The original method then gets the newly specified body which can delegate to the inner method.
	 * @return the inner method.
	 */
	def addIndirection(MutableMethodDeclaration wrapper, String innerMethodName, CompilationStrategy indirection) {
		val inner = createInnerMethod(wrapper, innerMethodName)
		wrapper.body = indirection
		inner
	}

	def addIndirection(MutableMethodDeclaration wrapper, String innerMethodName, StringConcatenationClient indirection) {
		val inner = createInnerMethod(wrapper, innerMethodName)
		wrapper.body = indirection
		inner
	}

	private def createInnerMethod(MutableMethodDeclaration wrapper, String innerMethodName) {
		wrapper.declaringType.addMethod(innerMethodName) [
			val resolvedMethod = wrapper.declaringType.newSelfTypeReference.declaredResolvedMethods.findFirst[declaration == wrapper]
			copySignatureFrom(resolvedMethod)
			visibility = Visibility.PRIVATE
			body = wrapper.body
			primarySourceElement = wrapper
		]
	}
	def copySignatureFrom(MutableMethodDeclaration it, ResolvedMethod source) {
		copySignatureFrom(it, source, #{})
	}

	def copySignatureFrom(MutableMethodDeclaration it, ResolvedMethod source, Map<TypeReference, TypeReference> classTypeParameterMappings) {
		abstract = source.declaration.abstract
		deprecated = source.declaration.deprecated
		^default = source.declaration.^default
		docComment = source.declaration.docComment
		final = source.declaration.final
		native = source.declaration.native
		static = source.declaration.static
		strictFloatingPoint = source.declaration.strictFloatingPoint
		synchronized = source.declaration.synchronized
		varArgs = source.declaration.varArgs
		visibility = source.declaration.visibility

		val typeParameterMappings = Maps.newHashMap(classTypeParameterMappings)
		source.resolvedTypeParameters.forEach [ param |
			val copy = addTypeParameter(param.declaration.simpleName, param.resolvedUpperBounds.map[replace(typeParameterMappings)])
			typeParameterMappings.put(param.declaration.newTypeReference, copy.newTypeReference)
		]
		exceptions = source.resolvedExceptionTypes.map[replace(typeParameterMappings)]
		returnType = source.resolvedReturnType.replace(typeParameterMappings)
		source.resolvedParameters.forEach [ p |
			addParameter(p.declaration.simpleName, p.resolvedType.replace(typeParameterMappings))
		]
	}

	private def TypeReference replace(TypeReference target,
		Map<? extends TypeReference, ? extends TypeReference> mappings) {
		mappings.entrySet.fold(target)[result, mapping|result.replace(mapping.key, mapping.value)]
	}

	private def TypeReference replace(TypeReference target, TypeReference oldType, TypeReference newType) {
		if (target.equals(oldType))
			return newType
		if (target.actualTypeArguments.contains(oldType))
			return newTypeReference(target.type, target.actualTypeArguments.map[replace(oldType, newType)])
		if(target.isArray)
			return target.arrayComponentType.replace(oldType, newType).newArrayTypeReference
		return target
	}
}
