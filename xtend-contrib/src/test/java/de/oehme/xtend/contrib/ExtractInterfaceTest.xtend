package de.oehme.xtend.contrib

import org.eclipse.xtend.core.XtendInjectorSingleton
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.core.xtend.XtendFile
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test

import static org.junit.Assert.*

class ExtractInterfaceTest {
	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(
		ExtractInterface
	)
	extension ParseHelper<XtendFile> = XtendInjectorSingleton.INJECTOR.getInstance(ParseHelper)
	extension ValidationTestHelper = XtendInjectorSingleton.INJECTOR.getInstance(ValidationTestHelper)

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
	
	@Test
	def void smokeTest() {
		'''
		package foo
		import de.oehme.xtend.contrib.ExtractInterface
		@ExtractInterface
		class DefaultExtractInterfaceTest<V extends Exception> {
			override <T, U extends V> T foo(T t, U u) throws V{
				t
			}
		}
		'''.parse.assertNoErrors
	}
}
