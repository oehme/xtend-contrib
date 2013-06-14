package de.oehme.xtend.contrib.caliper

import com.google.caliper.Param
import com.google.caliper.Runner
import com.google.caliper.SimpleBenchmark
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import static extension de.oehme.xtend.contrib.base.ASTExtensions.*

/**
 * <p>
 * Classes marked with this annotation will be transformed into Caliper benchmarks.
 * </p>
 * <h1>Benchmarked methods</h1>
 * <p>
 * Benchmarked methods can be defined in two ways:
 * <ol>
 * <li>by prefixing their name with "time",
 * you can control looping and return values yourself.
 * The number of iterations is automatically available as a method parameter.
 * <pre>
 * def timeFoo() {
 *   val sum = 0
 *   for(i : 1..iterations) {
 *     sum += doStuff()
 *   }
 *   sum
 * }</pre>
 * </li>
 * <li>by prefixing the name with "loop",
 * your method is just called in a for loop and its return value is ignored
 * <pre>
 * def loopFoo() {
 *   doStuff()
 * }</pre>
 * </li>
 * </ol>
 * </p>
 * <h1>Parameters</h1>
 * <p>
 * Benchmark parameters can be specified by fields or methods named "xxxValues", where "xxx" is the desired name of the parameter.
 * The (return-)type of these members must be an Iterable whose component type is the desired type of the parameter.
 *
 * <pre>
 * List&ltInteger&gt numValues = #[1,2,3]
 *
 * def loopFoo() {
 *   doSomething(num)
 * }
 * </pre>
 * </p>
 * <p>
 * You can also specify parameters without hardcoded values by using the {@link com.google.caliper.Param} annotation, e.g.:
 * <pre>@Param boolean useTheForce</pre>
 * When you do so, Caliper will just try all known values for Enums and Booleans.
 * For everything else you will need to supply parameters on the command line.
 * </p>
 * For more information, visit the <a href="https://code.google.com/p/caliper/">Caliper Website</a>.
 */
@Active(typeof(BenchmarkProcessor))
annotation Benchmark {
}

class BenchmarkProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration benchmark, extension TransformationContext context) {
		benchmark.final = true
		benchmark.extendedClass = typeof(SimpleBenchmark).newTypeReference

		benchmark.timedMethods.forEach [
			addParameter("iterations", primitiveInt)
		]

		benchmark.loopMethods.forEach [ method |
			benchmark.addMethod(method.simpleName.replaceFirst("loop", "time")) [
				addParameter("iterations", primitiveInt)
				body = [
					'''
						for (int i = 0; i < iterations;i++) {
							«method.simpleName»();
						}
					''']
			]
		]

		benchmark.benchmarkParameters.forEach [ param |
			benchmark.addField(param.simpleName.replace("Values", "")) [
				addAnnotation(typeof(Param).findTypeGlobally)
				type = param.propertyType.actualTypeArguments.get(0)
			]
			param.visibility = Visibility::DEFAULT
			param.static = true
		]

		benchmark.addMethod("main") [
			static = true
			addParameter("args", newArrayTypeReference(string))
			body = [extension it|
				'''
					«typeof(Runner).newTypeReference.toJavaCode».main(«benchmark.simpleName».class, args);
				''']
		]
	}

	def benchmarkParameters(MutableClassDeclaration benchmark) {
		(benchmark.declaredFields + benchmark.declaredMethods).filter [
			simpleName.endsWith("Values")
		]
	}

	def timedMethods(MutableClassDeclaration benchmark) {
		benchmark.declaredMethods.filter [
			static == false && simpleName.startsWith("time")
		]
	}

	def loopMethods(MutableClassDeclaration benchmark) {
		benchmark.declaredMethods.filter [
			static == false && simpleName.startsWith("loop")
		]
	}
}
