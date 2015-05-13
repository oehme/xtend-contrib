package de.oehme.xtend.contrib

import com.google.common.annotations.Beta
import java.lang.annotation.Target
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

/**
 * Adds an inner Builder class to this class. The builder will have a fluent setter for each final field and can be
 * initialized from an existing value. The class will both have builder/copier()-method for Java clients and
 * build/copy[]-method for Xtend clients.
 * This annotation assumes that there is a constructor which takes all the fields in the same order they are defined in the class.
 * Integrates well with the {@link Data} annotation.
 */
@Beta
@Target(TYPE)
@Active(BuilderProcessor)
annotation Buildable {
}

class BuilderProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration it, extension RegisterGlobalsContext context) {
		if (context.findSourceClass(builderClassName) === null) {
			context.registerClass(builderClassName)
		}
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val builder = cls.builderClassName.findClass
		builder => [
			primarySourceElement = cls
			addConstructor[
				visibility = Visibility.PRIVATE
				addParameter("other", cls.newSelfTypeReference)
				body = '''
					«FOR builtField : cls.builtFields(context)»
						this.«builtField.simpleName» = other.«builtField.simpleName»;
					«ENDFOR»
				'''
				primarySourceElement = cls
			]
			addConstructor[
				visibility = Visibility.PRIVATE
				primarySourceElement = cls
			]
			cls.builtFields(context).forEach [ builtField |
				addField(builtField.simpleName) [
					type = builtField.type
					primarySourceElement = builtField
				]
				addMethod(builtField.simpleName) [
					returnType = builder.newTypeReference
					addParameter(builtField.simpleName, builtField.type)
					body = '''
						this.«builtField.simpleName» = «builtField.simpleName»;
						return this;
					'''
					primarySourceElement = builtField
				]
				addMethod('''set«builtField.simpleName.toFirstUpper»''') [
					returnType = builder.newTypeReference
					addParameter(builtField.simpleName, builtField.type)
					body = '''
						this.«builtField.simpleName» = «builtField.simpleName»;
						return this;
					'''
					primarySourceElement = builtField
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
		cls.addMethod("builder") [
			returnType = builder.newTypeReference
			static = true
			body = '''
				return new «builder»();
			'''
			primarySourceElement = cls
		]
		cls.addMethod("copy") [
			returnType = builder.newTypeReference
			body = '''
				return new «builder»(this);
			'''
			primarySourceElement = cls
		]
		cls.addMethod("build") [
			returnType = cls.newTypeReference
			static = true
			addParameter("init", Procedures.Procedure1.newTypeReference(builder.newSelfTypeReference))
			body = '''
				final «builder» builder = new «builder»();
				init.apply(builder);
				return builder.build();
			'''
			primarySourceElement = cls
		]
		cls.addMethod("copy") [
			returnType = cls.newTypeReference
			addParameter("copier", Procedures.Procedure1.newTypeReference(builder.newSelfTypeReference))
			body = '''
				final «builder» builder = new «builder»(this);
				copier.apply(builder);
				return builder.build();
			'''
			primarySourceElement = cls
		]
	}

	def builderClassName(ClassDeclaration cls) {
		cls.qualifiedName + ".Builder"
	}

	def builtFields(MutableClassDeclaration cls, extension TransformationContext context) {
		val sourceClass = cls.primarySourceElement as ClassDeclaration
		sourceClass.declaredFields.filter [
			(final || cls.alsoCollectNonFinalFields(context)) && !static && !transient
		]
	}

	def boolean alsoCollectNonFinalFields(ClassDeclaration cls, extension TransformationContext context) {
		cls.findAnnotation(Data.findTypeGlobally) !== null
	}

}
