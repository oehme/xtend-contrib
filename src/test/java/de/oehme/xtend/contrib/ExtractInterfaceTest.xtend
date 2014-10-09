package de.oehme.xtend.contrib

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

import static org.junit.Assert.*

class ExtractInterfaceTest {
	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(
		ExtractInterface
	)

	@Test
	def void test() {
		'''
			package foo
			
			import de.oehme.xtend.contrib.ExtractInterface
			
			@ExtractInterface
			class DefaultFoo {
				override int bar(String bar, int... baz) throws Exception{
					new Integer(1)
				}
			}
		'''.compile [
			val iface = getCompiledClass("foo.Foo")
			assertTrue(getCompiledClass("foo.DefaultFoo").interfaces.contains(getCompiledClass("foo.Foo")))
			assertNotNull(iface)
			val bar = iface.getMethod("bar", String, typeof(int[]))
			assertTrue(bar.exceptionTypes.contains(Exception))
			assertEquals(int, bar.returnType)
			assertTrue(bar.varArgs)
		]
	}
}
