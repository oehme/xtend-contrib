package de.oehme.xtend.contrib

import com.google.common.cache.LoadingCache
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtext.xbase.lib.Exceptions

import static org.hamcrest.Matchers.*

import static extension java.lang.reflect.Modifier.*
import java.util.List

describe Cached {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(
		Cached, LoadingCache, Exceptions
	)

	context "with no parameters"{
		val example = '''
			import de.oehme.xtend.contrib.Cached
			class Foo {
				@Cached
				def int bar() {
					//force new instance so we can later test object identity
					new Integer(1)
				}
			}
		'''

		facts "about the outer method" {
			example.compile[
				val outerMethod = compiledClass.getDeclaredMethod("bar")
				outerMethod.returnType should be Integer
			]
		}

		facts "about the init method" {
			example.compile[
				val initMethod = compiledClass.getDeclaredMethod("bar_init")
				initMethod.returnType should be Integer
				assert initMethod.modifiers.private
			]
		}

		facts "about the cache field" {
			example.compile[
				val cacheField = compiledClass.getDeclaredField("_cache_bar")
				cacheField.type should be Integer
				assert cacheField.modifiers.private
			]
		}

		fact "the method caches invocations" {
			example.compile[
				val cls = compiledClass
				val foo = cls.newInstance
				val bar = cls.getMethod("bar")
				val first = bar.invoke(foo)
				val second = bar.invoke(foo)
				first should be theInstance(second)
			]
		}
	}

	context "with one parameter"{
		val example = '''
			import de.oehme.xtend.contrib.Cached
			import java.util.List
			class Foo {
				@Cached
				def Integer bar(List<String> arg) {
					arg.size
				}
			}
		'''

		facts "about the outer method" {
			example.compile[
				val outerMethod = compiledClass.getDeclaredMethod("bar", List)
				outerMethod.returnType should be Integer
			]
		}

		facts "about the init method" {
			example.compile[
				val initMethod = compiledClass.getDeclaredMethod("bar_init", List)
				initMethod.returnType should be Integer
				assert initMethod.modifiers.private
			]
		}

		facts "about the cache field" {
			example.compile[
				val cacheField = compiledClass.getDeclaredField("_cache_bar_java_util_List")
				cacheField.type should be LoadingCache
				assert cacheField.modifiers.private
			]
		}

		fact "the method caches invocations" {
			example.compile[
				val cls = compiledClass
				val foo = cls.newInstance
				val bar = cls.getMethod("bar", List)

				val first = bar.invoke(foo, #[#["a"]])
				val second = bar.invoke(foo, #[#["a"]])
				val third = bar.invoke(foo, #[#["a", "b"]])

				first should be 1
				second should be 1
				third should be 2
				first should be theInstance(second)
			]
		}
	}

	context "with multiple parameters" {
		val example = '''
			import de.oehme.xtend.contrib.Cached
			class Foo {
				@Cached
				def Integer bar(String arg1, Integer arg2) {
					new Integer(arg1.length + arg2)
				}
			}
		'''

		facts "about the outer method" {
			example.compile[
				val outerMethod = compiledClass.getDeclaredMethod("bar", String, Integer)
				outerMethod.returnType should be Integer
			]
		}

		facts "about the init method" {
			example.compile[
				val initMethod = compiledClass.getDeclaredMethod("bar_init", String, Integer)
				initMethod.returnType should be Integer
				assert initMethod.modifiers.private
			]
		}

		facts "about the cache field" {
			example.compile[
				val cacheField = compiledClass.getDeclaredField("_cache_bar_java_lang_String_java_lang_Integer")
				cacheField.type should be LoadingCache
				assert cacheField.modifiers.private
			]
		}

		fact "the method caches invocations" {
			example.compile[
				val cls = compiledClass
				val foo = cls.newInstance
				val bar = cls.getMethod("bar", String, Integer)

				val first = bar.invoke(foo, "a", 0)
				val second = bar.invoke(foo, "a", 0)
				val third = bar.invoke(foo, "a", 1)
				val fourth = bar.invoke(foo, "b", 0)

				first should be 1
				second should be 1
				third should be 2
				fourth should be 1
				first should be theInstance(second)
				first should not be theInstance(fourth)
			]
		}
	}
}
