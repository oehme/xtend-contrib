package de.oehme.xtend.contrib

import com.google.common.cache.LoadingCache
import java.util.List
import org.eclipse.xtend.core.XtendInjectorSingleton
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtend.core.xtend.XtendFile
import org.eclipse.xtend.core.xtend.XtendPackage
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test

import static org.junit.Assert.*

import static extension java.lang.reflect.Modifier.*

class CachedTest {
	extension XtendCompilerTester = XtendCompilerTester::newXtendCompilerTester(
		Cached,
		LoadingCache,
		Exceptions
	)
	extension ParseHelper<XtendFile> = XtendInjectorSingleton.INJECTOR.getInstance(ParseHelper)
	extension ValidationTestHelper = XtendInjectorSingleton.INJECTOR.getInstance(ValidationTestHelper)

	@Test
	def void testWithInferredReturnType() {
		'''
			import de.oehme.xtend.contrib.Cached
			class Foo {
				@Cached
				def bar() {
					1
				}
			}
		'''.parse.assertError(
			XtendPackage.Literals.XTEND_FUNCTION,
			"user.issue",
			"specify",
			"return type"
		)
	}

	@Test
	def void testParameterless() {
		'''
			import de.oehme.xtend.contrib.Cached
			class Foo {
				@Cached
				def int bar() {
					//force new instance so we can later test object identity
					new Integer(1)
				}
			}
		'''.compile [
			val outerMethod = compiledClass.getDeclaredMethod("bar")
			assertEquals(Integer, outerMethod.returnType)
			val initMethod = compiledClass.getDeclaredMethod("bar_init")
			assertEquals(Integer, initMethod.returnType)
			assertTrue(initMethod.modifiers.private)
			val cacheField = compiledClass.getDeclaredField("_cache_bar")
			assertEquals(Integer, cacheField.type)
			assertTrue(cacheField.modifiers.private)
			val cls = compiledClass
			val foo = cls.newInstance
			val bar = cls.getMethod("bar")
			val first = bar.invoke(foo)
			val second = bar.invoke(foo)
			assertSame(first, second)
		]
	}

	@Test
	def testOneParameter() {
		'''
			import de.oehme.xtend.contrib.Cached
			import java.util.List
			class Foo {
				@Cached
				def Integer bar(List<String> arg) {
					arg.size
				}
			}
		'''.compile [
			val outerMethod = compiledClass.getDeclaredMethod("bar", List)
			assertEquals(Integer, outerMethod.returnType)
			val initMethod = compiledClass.getDeclaredMethod("bar_init", List)
			assertEquals(Integer, initMethod.returnType)
			assertTrue(initMethod.modifiers.private)
			val cacheField = compiledClass.getDeclaredField("_cache_bar_java_util_List")
			assertEquals(LoadingCache, cacheField.type)
			assertTrue(cacheField.modifiers.private)
			val cls = compiledClass
			val foo = cls.newInstance
			val bar = cls.getMethod("bar", List)
			val first = bar.invoke(foo, #[#["a"]])
			val second = bar.invoke(foo, #[#["a"]])
			val third = bar.invoke(foo, #[#["a", "b"]])
			assertEquals(1, first)
			assertEquals(1, second)
			assertEquals(2, third)
			assertSame(first, second)
		]
	}

	@Test
	def testMultipleParameters() {
		'''
			import de.oehme.xtend.contrib.Cached
			class Foo {
				@Cached
				def Integer bar(String arg1, Integer arg2) {
					new Integer(arg1.length + arg2)
				}
			}
		'''.compile [
			val outerMethod = compiledClass.getDeclaredMethod("bar", String, Integer)
			assertEquals(Integer, outerMethod.returnType)
			val initMethod = compiledClass.getDeclaredMethod("bar_init", String, Integer)
			assertEquals(Integer, initMethod.returnType)
			assertTrue(initMethod.modifiers.private)
			val cacheField = compiledClass.getDeclaredField("_cache_bar_java_lang_String_java_lang_Integer")
			assertEquals(LoadingCache, cacheField.type)
			assertTrue(cacheField.modifiers.private)
			val cls = compiledClass
			val foo = cls.newInstance
			val bar = cls.getMethod("bar", String, Integer)
			val first = bar.invoke(foo, "a", 0)
			val second = bar.invoke(foo, "a", 0)
			val third = bar.invoke(foo, "a", 1)
			val fourth = bar.invoke(foo, "b", 0)
			assertEquals(1, first)
			assertEquals(1, second)
			assertEquals(2, third)
			assertEquals(1, fourth)
			assertSame(first, second)
			assertNotSame(first, fourth)
		]
	}
	
	@Test
	def smokeTest() {
		'''
		import de.oehme.xtend.contrib.Cached
		class CachedTest {
			@Cached
			def Integer foo(Integer t, Integer t2) {
				t
			}
			
			@Cached
			def Integer foo(Integer t) {
				t
			}
			
			@Cached
			def <T> T foo(T t, T t2) {
				t
			}
			
			@Cached
			def <T> T foo(T t) {
				t
			}
			
			@Cached
			def <T> T foo() {
				
			}
			
			@Cached
			def Integer foo2() {
				
			}
		}
		'''.parse.assertNoErrors
	}
	
	@Test
	def testExtensionParameter() {
		'''
			import de.oehme.xtend.contrib.Cached
			class CachedTest {
				@Cached
				def String foo(extension String bar) {
					substring(3)
				}
			}
		'''.parse.assertNoErrors
	}
	
	@Test
	def testNameHygiene() {
		'''
			import de.oehme.xtend.contrib.Cached
			class CachedTest {
				@Cached
				def String foo(String e) {
					"Foo"
				}
			}
		'''.compile[
			assertNotNull(compiledClass)
		]
	}
}
