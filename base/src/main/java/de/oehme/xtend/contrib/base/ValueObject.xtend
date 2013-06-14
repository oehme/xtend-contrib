package de.oehme.xtend.contrib.base

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtext.xbase.lib.Procedures

import static extension de.oehme.xtend.contrib.base.ASTExtensions.*

/**
 * Turns your class into an immutable value object with a builder, getters for all fields
 * and default equals, hashcode and toString methods.
 */
@Active(typeof(ValueObjectProcessor))
annotation ValueObject {
}

class ValueObjectProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration cls, RegisterGlobalsContext context) {
		context.registerClass(cls.builderClassName)
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val extension transformations = new CommonTransformations(context)
		if(cls.extendedClass != object) cls.addError("Inheritance does not play well with immutability")

		cls.final = true
		val builder = cls.builderClass(context) => [
			final = true
			addMethod("build") [
				returnType = cls.newTypeReference
				body = [
					'''
						return new «cls.simpleName»(«cls.persistentState.join(",")[simpleName]»);
					''']
			]
			cls.persistentState.forEach [ field |
				addMethod(field.simpleName) [
					addParameter(field.simpleName, field.type)
					returnType = cls.builderClass(context).newTypeReference
					body = [
						'''
							this.«field.simpleName» = «field.simpleName»;
							return this;
						''']
				]
				addField(field.simpleName) [
					type = field.type
				]
			]
		]

		cls.addMethod("build") [
			static = true
			returnType = cls.newTypeReference
			addParameter("init", typeof(Procedures$Procedure1).newTypeReference(builder.newTypeReference))
			body = [
				'''
					«cls.builderClassName» builder = builder();
					init.apply(builder);
					return builder.build();
				''']
		]
		cls.addMethod("builder") [
			returnType = cls.builderClass(context).newTypeReference
			static = true
			body = [
				'''
					return new «cls.builderClassName»();
				''']
		]

		cls.persistentState.forEach [ field |
			field.addGetter
			//TODO https://bugs.eclipse.org/bugs/show_bug.cgi?id=404167
			cls.addField(field.simpleName) [
				type = field.type
				initializer = field.initializer
			]
			field.remove
		]

		if(!cls.hasDataConstructor) cls.addDataConstructor
		if(!cls.hasEquals) cls.addDataEquals
		if(!cls.hasHashCode) cls.addDataHashCode
		if(!cls.hasToString) cls.addDataToString
	}

	def builderClassName(ClassDeclaration cls) {
		cls.qualifiedName + "Builder"
	}

	def builderClass(ClassDeclaration cls, extension TransformationContext ctx) {
		cls.builderClassName.findClass
	}
}
