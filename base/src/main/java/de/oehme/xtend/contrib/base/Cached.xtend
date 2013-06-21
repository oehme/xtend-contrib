package de.oehme.xtend.contrib.base

import java.util.Arrays
import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy$CompilationContext
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtext.xbase.lib.Exceptions

import static extension de.oehme.xtend.contrib.base.ASTExtensions.*

/**
 * Caches invocations of a method. When the method is called multiple times with the same parameters, a cached result will be returned.
 * Useful for expensive calculations or recursive algorithms.
 * <br>
 * The method must guarantee the following conditions:
 * <ul>
 * 	<li>The method's parameters have meaningful equals/hashcode implementations.</li>
 * 	<li>The result of the method only depends on the parameters or immutable internal state</li>
 * 	<li>The method is referentially transparent (has no externally visible side effects)</li>
 * </ul>
 */
@Active(typeof(MemoizeProcessor))
annotation Cached {
}

class MemoizeProcessor implements TransformationParticipant<MutableMethodDeclaration> {
	override doTransform(List<? extends MutableMethodDeclaration> methods, extension TransformationContext context) {
		for (i : 0 ..< methods.size) {
			val it = methods.get(i)
			switch (parameters.size) {
				case 0: new ParamterlessMethodMemoizer(it, context, i).generate
				case 1: new SingleParameterMethodMemoizer(it, context, i).generate
				default: new MultipleParameterMethodMemoizer(it, context, i).generate
			}
		}
	}
}

abstract class MethodMemoizer {

	protected val extension TransformationContext context
	protected val MutableMethodDeclaration method
	protected val int index

	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		this.method = method
		this.context = context
		this.index = index
	}

	def final generate() {
		method => [
			returnType = returnType.wrapperIfPrimitive
			addIndirection(initMethodName)[cacheCall]
			declaringType => [
				addField(cacheFieldName) [
					static = method.static
					type = cacheFieldType
					initializer = [cacheFieldInit]
				]
			]
		]
	}

	def protected final String initMethodName() '''«method.simpleName»_init'''

	def protected final String cacheFieldName() '''cache«index»_«method.simpleName»'''

	def protected CharSequence cacheCall(CompilationContext context)

	def protected TypeReference cacheFieldType()

	def protected CharSequence cacheFieldInit(CompilationContext context)
}

/**
 * Uses double null check synchronization for multithreaded correctness and performance
 */
class ParamterlessMethodMemoizer extends MethodMemoizer {

	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}

	override protected cacheCall(extension CompilationContext context) '''
		if («cacheFieldName» == null) {
			synchronized(«lock») {
				if («cacheFieldName» == null) {
					«cacheFieldName» = «initMethodName»();
				}
			}
		}
		return «cacheFieldName»;
	'''

	override protected cacheFieldType() {
		method.returnType
	}

	override protected cacheFieldInit(CompilationContext context) '''null'''

	def lock() {
		if (method.static) '''«method.declaringType.simpleName».class''' else "this"
	}
}

/**
 * Uses Guava's LoadingCache to store the return value for each combination of parameters
 */
abstract class ParametrizedMethodMemoizer extends MethodMemoizer {
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}

	override protected final cacheFieldInit(extension CompilationContext context) '''
		com.google.common.cache.CacheBuilder.newBuilder()
		.build(new com.google.common.cache.CacheLoader<«cacheKeyType.toJavaCode», «method.returnType.toJavaCode»>() {
			@Override
			public «method.returnType.toJavaCode» load(«cacheKeyType.toJavaCode» key) throws Exception {
				return «initMethodName»(«cacheKeyToParameters(context)»);
			}
		})
	'''

	override protected final cacheFieldType() {
		newTypeReference(
			"com.google.common.cache.LoadingCache",
			cacheKeyType,
			method.returnType
		)
	}

	override protected final cacheCall(extension CompilationContext context) '''
		try {
			return «cacheFieldName».get(«parametersToCacheKey(context)»);
		} catch (Throwable e) {
			if (e instanceof java.util.concurrent.ExecutionException
				|| e instanceof com.google.common.util.concurrent.UncheckedExecutionException
				|| e instanceof com.google.common.util.concurrent.ExecutionError) {
				Throwable cause = e.getCause();
				throw «typeof(Exceptions).newTypeReference.toJavaCode».sneakyThrow(cause);
			} else {
				throw «typeof(Exceptions).newTypeReference.toJavaCode».sneakyThrow(e);
			}
		}
	'''

	def protected TypeReference cacheKeyType()

	def protected CharSequence parametersToCacheKey(CompilationContext context)

	def protected CharSequence cacheKeyToParameters(CompilationContext context)
}

class SingleParameterMethodMemoizer extends ParametrizedMethodMemoizer {
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}

	override protected cacheKeyToParameters(CompilationContext context) '''key'''

	override protected parametersToCacheKey(CompilationContext context) {
		parameter.simpleName
	}

	override protected cacheKeyType() {
		parameter.type.wrapperIfPrimitive
	}

	def private parameter() {
		method.parameters.head
	}
}

class MultipleParameterMethodMemoizer extends ParametrizedMethodMemoizer {
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}

	override protected cacheKeyToParameters(extension CompilationContext context) {
		method.parameters.join(",")[
			'''
				(«type.wrapperIfPrimitive.toJavaCode») key.get(«method.parameters.indexOf(it)»)
			''']
	}

	override protected parametersToCacheKey(extension CompilationContext context) '''
		new «cacheKeyType.toJavaCode»(«method.parameters.join("", ",", "")[simpleName]»)
	'''

	override protected cacheKeyType() {
		typeof(CacheKey).newTypeReference
	}
}

/**
 * This class is an implementation detail and not fit for general use.
 * It foregoes immutability for pure performance
 */
class CacheKey {
	val Object[] parameters

	new(Object... parameters) {
		this.parameters = parameters
	}

	def Object get(int index) {
		parameters.get(index)
	}

	override equals(Object obj) {
		if (obj instanceof CacheKey) {
			return Arrays::equals(parameters, (obj as CacheKey).parameters)
		}
		false
	}

	override hashCode() {
		Arrays::hashCode(parameters)
	}
}
