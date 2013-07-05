package de.oehme.xtend.contrib.base

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester

describe ExtractInterface {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(
		typeof(ExtractInterface)
	)

	val example = '''
		package foo

		import de.oehme.xtend.contrib.base.ExtractInterface

		@ExtractInterface
		class DefaultFoo {
			override int bar(String bar, int... baz) throws Exception{
				new Integer(1)
			}
		}
	'''

		fact "an interface is generated" {
			example.compile[
				getCompiledClass("foo.Foo") should not be null
			]
		}
		
		fact "the class implements the interface" {
			example.compile[
				getCompiledClass.interfaces should contain getCompiledClass("foo.Foo") 
			]
		}

		fact "basic method signatures are copied" {
			example.compile[
				val iface = getCompiledClass("foo.Foo")
				iface.bar
			]
		}
		
		fact "declared exceptions are copied" {
			example.compile[
				val iface = getCompiledClass("foo.Foo")
				iface.bar.exceptionTypes should contain typeof(Exception)
			]
		}

		
		fact "the return type is copied" {
			example.compile[
				val iface = getCompiledClass("foo.Foo")
				iface.bar.returnType should be typeof(int)
			]
		}
		
		fact "varargs declarations are copied" {
			example.compile[
				val iface = getCompiledClass("foo.Foo")
				assert iface.bar.varArgs
			]
		}
		
		def bar(Class<?> iface) {
			iface.getMethod("bar", typeof(String), typeof(int[]))
		}
}