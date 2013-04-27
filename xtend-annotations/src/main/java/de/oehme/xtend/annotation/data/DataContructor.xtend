package de.oehme.xtend.annotation.data

import java.util.List
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

/**
 * Usage:
 * <pre>
 * class Person {
 *  @DataConstructor
 *  new(String name, int age) {
 *      println("Person created");
 *  }
 * }
 * </pre>
 * This is equivalent to:
 * <pre>
 * class Person {
 *     public final String name;
 *     public final int age;
 * 
 *     new(String name, int age) {
 *         this.name = name
 *         this.age = age
 *         println("Person created");
 *     }
 * }
 * </pre>
 */
@Active(typeof(DataContructorProcessor))
annotation DataConstructor {
}

class DataContructorProcessor implements TransformationParticipant<MutableConstructorDeclaration> {

	def void doTransform(MutableConstructorDeclaration constructor, extension TransformationContext context) {
		if (constructor.parameters.empty) {
			return
		}
		val added = newArrayList()
		val type = constructor.declaringType
		constructor.parameters.forEach [ arg |
			println(arg.simpleName+":"+type.findField(arg.simpleName)+":"+type.declaredFields.toList)
			if (type.findField(arg.simpleName) == null) {
				println("adding "+arg.simpleName)
				type.addField(arg.simpleName) [ field |
					field.final = true
					field.visibility = Visibility::PUBLIC;
					field.type = arg.type
				]
				added.add(arg.simpleName)
			}
		]
		val emptyContructor = constructor.body.toString.replaceAll("[{}]", '').trim.empty;
		if (!emptyContructor) {
			type.addMethod("__init") [ init |
				init.body = constructor.body
				init.visibility = Visibility::PRIVATE;
				constructor.parameters.forEach [ arg |
					init.addParameter(arg.simpleName, arg.type)
				]
			]
		}
		constructor.body = [
			'''
				«FOR arg : constructor.parameters»
					this.«arg.simpleName» = «arg.simpleName»;
				«ENDFOR»
				«IF !emptyContructor»
					__init(«constructor.parameters.map[simpleName].join(',')»);
				«ENDIF»
			'''
		]

	}

	override doTransform(List<? extends MutableConstructorDeclaration> annotatedTargetElements,
		extension TransformationContext context) {
		annotatedTargetElements.forEach[doTransform(it, context)]

	}

}
