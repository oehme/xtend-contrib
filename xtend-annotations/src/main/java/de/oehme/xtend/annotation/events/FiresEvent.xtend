package de.oehme.xtend.annotation.events

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtext.common.types.JvmGenericType
import java.util.List
import java.util.ArrayList
import java.lang.annotation.Target
import java.lang.annotation.ElementType

/**
 * Generates methods for registering listeners and notifing them.
 * 
 * <pre>
 * @FiresEvent(typeof(ChangeListener))
 * class TextBox {
 * }
 * </pre>
 * becomes:
 * <pre>
 * @FiresEvent(typeof(ChangeListener))
 * class TextBox {
 * 	val List<ChangeListener> _changeListeners = new ArrayList
 *  
 * 	protected def fireStateChanged(ChangeEvent e) {
 * 		_changeListeners.forEach [
 * 			it.stateChanged(e);
 * 		]
 * 	}
 *  
 * 	def addChangeListener(ChangeListener listener) {
 * 		_changeListeners.add(listener);
 * 	}
 *  
 * 	def removeChangeListener(ChangeListener listener) {
 * 		_changeListeners.remove(listener);
 * 	}
 * }</pre>
 */
@Target(ElementType::TYPE)
@Active(typeof(FiresEventProcessor))
annotation FiresEvent {
	Class<?>[] value;
}

class FiresEventProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val annotationType = findTypeGlobally(typeof(FiresEvent))

		val valueObj = cls.findAnnotation(annotationType).getValue('value')
		switch (valueObj) {
			JvmGenericType:
				addMethodsForType(valueObj, cls, context)
			List<JvmGenericType>:
				valueObj.forEach [ type |
					addMethodsForType(type, cls, context);
				]
		}
	}

	def addMethodsForType(JvmGenericType value, MutableClassDeclaration cls, extension TransformationContext context) {
		val listenerType = newTypeReference(value.qualifiedName)
		val arrListTypeRef = newTypeReference(typeof(ArrayList), listenerType)
		val _changeListeners = '_' + value.simpleName.toFirstLower + 's'
		cls.addField(_changeListeners) [
			type = newTypeReference(typeof(List), listenerType);
			initializer = ['''new «toJavaCode(arrListTypeRef)»()''']
		]
		val listenerClass = Class::forName(listenerType.name)
		listenerClass.declaredMethods.forEach [ method |
			cls.addMethod('fire' + method.name.toFirstUpper) [ result |
				method.parameterTypes.forEach [ param |
					result.addParameter(param.simpleName.toFirstLower, newTypeReference(param))
				]
				result.body = [
					'''
						for(«toJavaCode(listenerType)» listener : «_changeListeners») {
							listener.«method.name»(«FOR p : method.parameterTypes SEPARATOR ','»«p.simpleName.toFirstLower»«ENDFOR»);
						}
					''']
			]
		]
		cls.addMethod('add' + listenerType.simpleName) [
			addParameter('listener', listenerType)
			body = [
				'''
					«_changeListeners».add(listener);
				''']
		]
		cls.addMethod('remove' + listenerType.simpleName) [
			addParameter('listener', listenerType)
			body = [
				'''
					«_changeListeners».remove(listener);
				''']
		]
	}
}
