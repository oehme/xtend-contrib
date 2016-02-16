package de.oehme.xtend.contrib.logging

import com.google.common.annotations.Beta
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * Adds a Logger field to this class  
 */
@Beta
@Target(TYPE)
@Active(Slf4jProcessor)
annotation Slf4j {
}

class Slf4jProcessor extends AbstractClassProcessor {

    override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
        cls.addField("log") [
            static = true
            final = true
            type = Logger.newTypeReference
            initializer = '''
                «LoggerFactory».getLogger("«cls.qualifiedName»")
            '''
            primarySourceElement = cls
        ]
    }
}
