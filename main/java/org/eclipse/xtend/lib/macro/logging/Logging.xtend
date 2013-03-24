package org.eclipse.xtend.lib.macro.logging

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.logging.Logger
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtext.xbase.lib.Functions

@Target(ElementType::TYPE)
@Active(typeof(LoggingProcessor))
annotation Logging {
	// when this will be fixed:  https://bugs.eclipse.org/bugs/show_bug.cgi?id=403789
	//LoggingType type = LoggingType::JavaUtilLogging
	
	String type = "JavaUtilLogging"
}

class LoggingProcessor extends AbstractClassProcessor {

	private val LoggingSystem[] loggingSystems = #[new Slf4j(), new Log4j(), new JUL()]

	override doTransform(MutableClassDeclaration clazz, TransformationContext context) {
		val preferred = findPreferred(clazz, context)
		val loggingSystem = if (preferred != null) { preferred } else { findAvailable(context) }
		
		addLogging(clazz, context, loggingSystem)
		addDebugMethod(clazz, context, loggingSystem)
		addInfoMethod(clazz, context, loggingSystem)
		addWarnMethod(clazz, context, loggingSystem)
		addErrorMethod(clazz, context, loggingSystem)
		addErrorWithExceptionMethod(clazz, context, loggingSystem)
	}
	
	def addDebugMethod(MutableClassDeclaration clazz, extension TransformationContext context, LoggingSystem system) {
		clazz.addMethod("debug", [
			static = true
			visibility = Visibility::PRIVATE 
			addParameter("logStatement", typeof(Functions$Function0).newTypeReference(typeof(String).newTypeReference))
			body = [ '''
			   if (LOG.«system.debugCheck») {
			   	  LOG.«system.getDebugCall("logStatement.apply()")»;
			   }
			'''
			]
		])
	}
	def addInfoMethod(MutableClassDeclaration clazz, extension TransformationContext context, LoggingSystem system) {
		clazz.addMethod("info", [
			static = true
			visibility = Visibility::PRIVATE 
			addParameter("logStatement", typeof(Functions$Function0).newTypeReference(typeof(String).newTypeReference))
			body = [ '''
			   if (LOG.«system.infoCheck») {
			   	  LOG.«system.getInfoCall("logStatement.apply()")»;
			   }
			'''
			]
		])
	}
	def addWarnMethod(MutableClassDeclaration clazz, extension TransformationContext context, LoggingSystem system) {
		clazz.addMethod("warn", [
			static = true
			visibility = Visibility::PRIVATE 
			addParameter("logStatement", typeof(Functions$Function0).newTypeReference(typeof(String).newTypeReference))
			body = [ '''
			   if (LOG.«system.warningCheck») {
			   	  LOG.«system.getWarnCall("logStatement.apply()")»;
			   }
			'''
			]
		])
	}
	def addErrorMethod(MutableClassDeclaration clazz, extension TransformationContext context, LoggingSystem system) {
		clazz.addMethod("error", [
			static = true
			visibility = Visibility::PRIVATE 
			addParameter("logStatement", typeof(Functions$Function0).newTypeReference(typeof(String).newTypeReference))
			body = [ '''
			   if (LOG.«system.errorCheck») {
			   	  LOG.«system.getErrorCall("logStatement.apply()")»;
			   }
			'''
			]
		])
	}
	def addErrorWithExceptionMethod(MutableClassDeclaration clazz, extension TransformationContext context, LoggingSystem system) {
		clazz.addMethod("error", [
			static = true
			visibility = Visibility::PRIVATE 
			addParameter("logStatement", typeof(Functions$Function0).newTypeReference(typeof(String).newTypeReference))
			addParameter("throwable", typeof(Throwable).newTypeReference)
			body = [ '''
			   if (LOG.«system.errorCheck») {
			   	  LOG.«system.getErrorCall("logStatement.apply(), throwable")»;
			   }
			'''
			]
		])
	}
	
	
	def addLogging(MutableClassDeclaration clazz, extension TransformationContext context, LoggingSystem system) {
		if (system.isAvailable(context)) {
			clazz.addField("LOG",
				[
					type = system.fieldType(context)
					static = true
					final = true
					initializer = ['''«system.initMethod»("«clazz.qualifiedName»"); ''']
				])
		} else {
			context.addError(clazz, system.loggingName + " is not included in the project!")
		}
	}

	def LoggingSystem findPreferred(MutableClassDeclaration clazz, extension TransformationContext context) {
		val annot = clazz.findAnnotation(findTypeGlobally(typeof(Logging)))
		val Object value = annot.getValue("type")
		if (value != null) {
			val LoggingType type = if (value instanceof String) {
				try {
					LoggingType::valueOf(value as String)
				} catch (IllegalArgumentException e) {
					addError(clazz, "Valid arguments : " +LoggingType::values.toList)
					null
				}
			} else if (value instanceof LoggingType) {
				value as LoggingType
			} else { 
				null 
			}
			switch (type) {
				case LoggingType::Log4J : new Log4j
				case LoggingType::JavaUtilLogging : new JUL
				case LoggingType::Slf4J : new Slf4j
				default : null
			}
		} else {
			null
		}
	}
	
	
	def LoggingSystem findAvailable(TransformationContext context) {
		for (LoggingSystem ls : loggingSystems) {
			if (ls.isAvailable(context)) {
				return ls
			}
		}		
	}
}

abstract class LoggingSystem {
	def abstract String loggingName()

	def abstract String initMethod()

	def abstract TypeReference fieldType(TransformationContext context)

	def abstract boolean isAvailable(TransformationContext context)
	
	def abstract String getDebugCheck()
	
	def String getDebugCall(String parameters) {
		return "debug("+parameters+")"
	}
	
	def abstract String getInfoCheck()

	def String getInfoCall(String parameters) {
		return "info("+parameters+")"
	}
	
	def abstract String getWarningCheck()
	
	def String getWarnCall(String parameters) {
		return "warn("+parameters+")"
	}
	
	def abstract String getErrorCheck()
	
	def String getErrorCall(String parameters) {
		return "error("+parameters+")"
	}

}

class JUL extends LoggingSystem {

	override fieldType(extension TransformationContext context) {
		typeof(Logger).newTypeReference
	}

	override isAvailable(TransformationContext context) {
		true
	}

	override loggingName() {
		"java-util-logging"
	}

	override initMethod() {
		"Logger.getLogger"
	}
	
	override getDebugCheck() {
		"isLoggable(java.util.logging.Level.FINE)"
	}
	
	override getInfoCheck() {
		"isLoggable(java.util.logging.Level.INFO)"
	}
	
	override getWarningCheck() {
		"isLoggable(java.util.logging.Level.WARNING)"
	}
	
	override getErrorCheck() {
		"isLoggable(java.util.logging.Level.SEVERE)"
	}
	
	override getDebugCall(String parameters) {
		"log(java.util.logging.Level.FINE,"+parameters+")"
	}

	override getWarnCall(String parameters) {
		"warning("+parameters+")"
	}

	override getErrorCall(String parameters) {
		"log(java.util.logging.Level.SEVERE,"+parameters+")"
	}
	
}

abstract class ExternalLogging extends LoggingSystem {
	String className

	new(String cn) {
		className = cn
	}

	override fieldType(extension TransformationContext context) {
		findTypeGlobally(className).newTypeReference
	}

	override isAvailable(extension TransformationContext context) {
		findTypeGlobally(className) != null
	}

	override getDebugCheck() { "isDebugEnabled()" }
	
	override getInfoCheck() { "isInfoEnabled()" }
	
	override getWarningCheck() { "isWarnEnabled()" }
	
	override getErrorCheck() { "isErrorEnabled()" }

}

class Log4j extends ExternalLogging {

	new() {
		super("org.apache.log4j.Logger")
	}

	override loggingName() {
		"log4j 1.x"
	}

	override initMethod() {
		"Logger.getLogger"
	}
	
	override getErrorCheck() {
		"isEnabledFor(org.apache.log4j.Level.ERROR)"
	}
	
	override getWarningCheck() {
		"isEnabledFor(org.apache.log4j.Level.WARN)"
	}
	
}

class Slf4j extends ExternalLogging {

	new() {
		super("org.slf4j.Logger")
	}

	override loggingName() {
		"slf4j"
	}

	override initMethod() {
		"org.slf4j.LoggerFactory.getLogger"
	}
}


