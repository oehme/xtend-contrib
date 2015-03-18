package de.oehme.xtend.contrib

import org.eclipse.xtend.core.XtendInjectorSingleton
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.core.xtend.XtendFile
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.junit.Test

import static org.junit.Assert.*

import static extension java.lang.reflect.Modifier.*

class BuildableTest {
	extension XtendCompilerTester = XtendCompilerTester::newXtendCompilerTester(
		Buildable,
		Data,
		Exceptions
	)

	extension ParseHelper<XtendFile> = XtendInjectorSingleton.INJECTOR.getInstance(ParseHelper)
	extension ValidationTestHelper = XtendInjectorSingleton.INJECTOR.getInstance(ValidationTestHelper)

	@Test
	def void smokeTest() {
		'''
			import de.oehme.xtend.contrib.Buildable
			import org.eclipse.xtend.lib.annotations.Data
			@Data
			@Buildable
			class Foo {
				String key
				int value
			}
		'''.parse.assertNoErrors
	}

	@Test
	def void testGeneratedCode() {
		'''
			import de.oehme.xtend.contrib.Buildable
			import org.eclipse.xtend.lib.annotations.Data
			@Data
			@Buildable
			class Foo {
				String key
				int value
			}
		'''.compile [
			val builder = compiledClass.classes.head
			assertEquals("Builder", builder.simpleName)

			val simpleMethod1 = builder.getMethod("key", #[String])
			assertEquals(builder, simpleMethod1.returnType)
			assertTrue(simpleMethod1.modifiers.public)

			val setterMethod1 = builder.getDeclaredMethod("setKey", #[String])
			assertEquals(builder, setterMethod1.returnType)
			assertTrue(setterMethod1.modifiers.public)

			val simpleMethod2 = builder.getMethod("value", #[int])
			assertEquals(builder, simpleMethod2.returnType)
			assertTrue(simpleMethod2.modifiers.public)

			val setterMethod2 = builder.getDeclaredMethod("setValue", #[int])
			assertEquals(builder, setterMethod2.returnType)
			assertTrue(setterMethod2.modifiers.public)
		]
	}

	@Test
	def void testBuildAndCopy() {
		'''
			import de.oehme.xtend.contrib.Buildable
			import org.eclipse.xtend.lib.annotations.Data
			@Data
			@Buildable
			class Foo {
				String key
				int value
			}
		'''.compile [
			val builder = compiledClass.classes.head
			val cls = compiledClass

			val buildMethod = cls.getMethod("build", #[Procedure1])
			val foo_0 = buildMethod.invoke(null, new Procedure1 {
				override apply(Object p) {
					builder.getMethod("setKey", #[String]).invoke(p, "akey")
					builder.getMethod("setValue", #[int]).invoke(p, 3)
				}
			})

			assertEquals(cls, foo_0.class)
			assertEquals("akey", cls.getMethod("getKey").invoke(foo_0))
			assertEquals(3, cls.getMethod("getValue").invoke(foo_0))

			val copyMethod = cls.getMethod("copy", #[Procedure1])
			val foo_1 = copyMethod.invoke(foo_0, new Procedure1 {
				override apply(Object p) {
					builder.getMethod("setKey", #[String]).invoke(p, "new_key")
					builder.getMethod("setValue", #[int]).invoke(p, 5)
				}
			})

			assertEquals(cls, foo_1.class)
			assertEquals("new_key", cls.getMethod("getKey").invoke(foo_1))
			assertEquals(5, cls.getMethod("getValue").invoke(foo_1))
		]
	}

}