package de.oehme.xtend.contrib.jaxrs

import com.google.common.base.CaseFormat
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.MutableAnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.NamedElement
import org.eclipse.xtend.lib.macro.declaration.Type
import javax.ws.rs.Path
import javax.ws.rs.HttpMethod

@Target(ElementType.TYPE)
@Active(AutoPathProcessor)
annotation AutoPath {
}

class AutoPathProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration type, extension TransformationContext ctx) {
		val path = findTypeGlobally(Path)
		if(path == null) {
			val autoPath = findTypeGlobally(AutoPath)
			val annotation = type.annotations.filter[annotationTypeDeclaration == autoPath].head
			annotation.addError(Path.name+" not found on classpath.");
			return;
		}
		val httpMethod = findTypeGlobally(HttpMethod)
		type.addPathIfNone(path)
		type.declaredMethods
			.filter[annotations.exists[annotationTypeDeclaration.hasAnnotation(httpMethod)]]
			.forEach[addPathIfNone(path)]
	}

	def addPathIfNone(MutableAnnotationTarget target, Type path) {
		if (!target.hasAnnotation(path)) {
			target.addAnnotation(path).set('value', target.toPath)
		}
	}

	def hasAnnotation(AnnotationTarget target, Type type) {
		target.annotations.exists[annotationTypeDeclaration.qualifiedName == type.qualifiedName]
	}

	def toPath(NamedElement s) {
		'/' + s.simpleName.toHyphen
	}

	def toHyphen(String s) {
		CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_HYPHEN, s)
	}
}
