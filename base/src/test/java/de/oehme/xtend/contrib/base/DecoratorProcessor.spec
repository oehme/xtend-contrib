package de.oehme.xtend.contrib.base

import de.oehme.xtend.contrib.base.Decorator
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester

describe Decorator {
	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(
		typeof(Decorator)
	)

	val example = '''
		package foo
		
		import de.oehme.xtend.contrib.base.Decorator
		
		@Decorator(typeof(CharSequence))
		class BuggyCharSequence {
			override char charAt(int i) {
				delegate.charAt(i + 1)
			}
		}
	'''
	
	fact "the class implements the specified interface" {
		example.compile[
			getCompiledClass.interfaces should contain typeof(CharSequence)
		]
	}
	
	facts "about the buggy char sequence" {
		example.compile[
			val CharSequence buggyFoo = getCompiledClass.getConstructor(typeof(CharSequence)).newInstance("Foo") as CharSequence
			buggyFoo.length should be 3
			buggyFoo.toString should be "Foo"
			buggyFoo.subSequence(0,2) should be "Fo"
			buggyFoo.charAt(0) should be 'o'.charAt(0)
		]
	}
}
