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

@Target(ElementType::TYPE)
@Active(typeof(FiresEventProcessor))
annotation FiresEvent {
	Class<?>[] value;
}

class FiresEventProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		val annotationType = findTypeGlobally(typeof(FiresEvent))
		
		val value = cls.findAnnotation(annotationType).getValue('value') as JvmGenericType
		val listenerType = newTypeReference(value.qualifiedName)
		val arrListTypeRef = newTypeReference(typeof(ArrayList), listenerType)
		val _changeListeners = '_' + value.simpleName.toFirstLower + 's'
		if(cls.findField(_changeListeners) != null) 
			return;
		cls.addField(_changeListeners) [
			type = newTypeReference(typeof(List), listenerType);
			initializer = ['''new «toJavaCode(arrListTypeRef)»()''']
		]
		val listenerClass = Class::forName(listenerType.name)
		listenerClass.declaredMethods.forEach [method|
			cls.addMethod('fire' + method.name.toFirstUpper) [result|
				method.parameterTypes.forEach[param|
					result.addParameter(param.simpleName.toFirstLower, newTypeReference(param))	
				]					
				result.body = ['''
					if(«_changeListeners» == null) return;
					for(«toJavaCode(listenerType)» listener : «_changeListeners») {
						listener.«method.name»(«FOR p : method.parameterTypes SEPARATOR ','»«p.simpleName.toFirstLower»«ENDFOR»);
					}
				''']
			]
		]
		cls.addMethod('add'+listenerType.simpleName) [
			addParameter('listener', listenerType)
			body = ['''
				«_changeListeners».add(listener);
			''']
		]			
		cls.addMethod('remove'+listenerType.simpleName) [
			addParameter('listener', listenerType)
			body = ['''
				«_changeListeners».remove(listener);
			''']
		]			
	}
}
