package de.oehme.xtend.contrib

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Target(TYPE)
@Active(BuilderProcessor)
annotation Buildable {
}

class BuilderProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration cls, extension RegisterGlobalsContext context) {
		context.registerClass(builderClassName(cls))
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val builder = cls.builderClassName.findClass
		builder => [
			primarySourceElement = cls
			cls.builtFields(context).forEach [ builtField |
				addField(builtField.simpleName) [
					type = builtField.type
					primarySourceElement = cls
				]
				addMethod(builtField.simpleName) [
					returnType = builder.newTypeReference
					addParameter(builtField.simpleName, builtField.type)
					body = '''
						this.«builtField.simpleName» = «builtField.simpleName»;
						return this;
					'''
					primarySourceElement = cls
				]
			]
			addMethod("build") [
				returnType = cls.newTypeReference
				body = '''
					return new «cls»(«cls.builtFields(context).join(", ")[simpleName]»);
				'''
				primarySourceElement = cls
			]
		]
	}

	def builderClassName(ClassDeclaration cls) {
		cls.qualifiedName + ".Builder"
	}

	def builtFields(MutableClassDeclaration cls, extension TransformationContext context) {
		cls.declaredFields.filter[final && !static && !transient && isThePrimaryGeneratedJavaElement]
	}

}
