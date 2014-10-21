package de.oehme.xtend.contrib

import com.google.common.base.CaseFormat
import com.google.common.collect.Iterators
import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.text.DateFormat
import java.text.Format
import java.text.MessageFormat
import java.text.NumberFormat
import java.util.Date
import java.util.Locale
import java.util.PropertyResourceBundle
import java.util.ResourceBundle
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.services.TypeReferenceProvider

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Active(MessagesProcessor)
annotation Messages {
}

class MessagesProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val bundleField = cls.addField("bundle") [
			type = ResourceBundle.newTypeReference
			final = true
			primarySourceElement = cls
		]
		cls.addConstructor [
			addParameter("locale", Locale.newTypeReference)
			body = '''
				this.bundle = «ResourceBundle».getBundle("«cls.qualifiedName»", locale);
			'''
			bundleField.markAsInitializedBy(it)
			primarySourceElement = cls
		]
		val propertyFile = cls.compilationUnit.filePath.parent.append(cls.simpleName + ".properties")
		val resourceBundle = new PropertyResourceBundle(propertyFile.contentsAsStream)
		Iterators.forEnumeration(resourceBundle.keys).forEach [ key |
			val pattern = resourceBundle.getString(key)
			val patternVariables = new MessageFormat(pattern).formats
			cls.addMethod(key.keyToMethodName) [
				returnType = string
				body = '''
					return bundle.getString("«key»");
				'''
				docComment = pattern
				primarySourceElement = cls
			]
			if (!patternVariables.empty) {
				cls.addMethod(key.keyToMethodName) [
					patternVariables.forEach [ patternVariable, index |
						addParameter("arg" + index, patternVariable.argumentType(context))
					]
					returnType = string
					body = '''
						String pattern = bundle.getString("«key»");
						«MessageFormat» format = new «MessageFormat»(pattern);
						return format.format(new «Object»[]{«parameters.join(", ")[simpleName]»});
					'''
					docComment = pattern
					primarySourceElement = cls
				]
			}
		]
	}

	def keyToMethodName(String key) {
		CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, key).toFirstLower
	}

	def argumentType(Format format, extension TypeReferenceProvider typeRefs) {
		switch format {
			NumberFormat: Number.newTypeReference
			DateFormat: Date.newTypeReference
			default: object
		}
	}

}
