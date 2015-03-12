package de.oehme.xtend.contrib

import com.google.common.annotations.Beta
import com.google.common.collect.Maps
import java.util.Map
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.ResolvedMethod
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend2.lib.StringConcatenationClient

/**
 * Helps you with copying signatures of existing methods.
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
@Beta
@FinalFieldsConstructor
class SignatureHelper {
	val extension TransformationContext delegate

	/**
	 * Copies the signature of the given base method so that you only have to add a body in most cases.
	 * You are free to modify the default settings, of course, e.g. widening the visibility of the
	 * implementing method.
	 * @return the new implementation method
	 */
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
	 * @return the new inner method.
	 */
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
	
	/**
	 * Copies the fully resolved signature from the source to this method, including type parameter resolution
	 */
	def copySignatureFrom(MutableMethodDeclaration it, ResolvedMethod source) {
		copySignatureFrom(it, source, #{})
	}

	/**
	 * Copies the fully resolved signature from the source to this method, including type parameter resolution. 
	 * The class-level type parameters assign each type parameter in the target method to a type parameter in the source method.
	 */
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
			val copy = addTypeParameter(param.declaration.simpleName, param.resolvedUpperBounds)
			typeParameterMappings.put(param.declaration.newTypeReference, copy.newTypeReference)
			copy.upperBounds = copy.upperBounds.map[replace(typeParameterMappings)]
		]
		exceptions = source.resolvedExceptionTypes.map[replace(typeParameterMappings)]
		returnType = source.resolvedReturnType.replace(typeParameterMappings)
		source.resolvedParameters.forEach [ p |
			val addedParam = addParameter(p.declaration.simpleName, p.resolvedType.replace(typeParameterMappings))
			p.declaration.annotations.forEach[addedParam.addAnnotation(it)]
		]
	}

	private def TypeReference replace(TypeReference target,
		Map<? extends TypeReference, ? extends TypeReference> mappings) {
		mappings.entrySet.fold(target)[result, mapping|result.replace(mapping.key, mapping.value)]
	}

	private def TypeReference replace(TypeReference target, TypeReference oldType, TypeReference newType) {
		if (target == oldType)
			return newType
		if (!target.actualTypeArguments.isEmpty)
			return newTypeReference(target.type, target.actualTypeArguments.map[replace(oldType, newType)])
		if (target.wildCard) {
			if (target.upperBound != object)
				return target.upperBound.replace(oldType, newType).newWildcardTypeReference
			else if (!target.lowerBound.isAnyType)
				return target.lowerBound.replace(oldType, newType).newWildcardTypeReferenceWithLowerBound
		}
		if(target.isArray)
			return target.arrayComponentType.replace(oldType, newType).newArrayTypeReference
		return target
	}
}