package de.oehme.xtend.contrib

import com.google.common.base.Objects
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtext.xbase.lib.Procedures$Procedure1
import com.google.common.base.CharMatcher

describe ValueObject {
	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(ValueObject, Objects, Procedure1)

	context "without customization" {
		val example = '''
			package foo

			import de.oehme.xtend.contrib.ValueObject

			@ValueObject
			class Thing {
				String a
				Integer b
			}
		'''

		fact "a builder class is generated" {
			example.compile[
				getCompiledClass("foo.ThingBuilder") should not be null
			]
		}

		fact "the builder has a setter for each property" {
			example.compile[
				val builder = getCompiledClass("foo.ThingBuilder")
				builder.getDeclaredMethod("a", String)
				builder.getDeclaredMethod("b", Integer)
			]
		}

		fact "the class has a getter for each property" {
			example.compile[
				val cls = getCompiledClass
				val getA = cls.getDeclaredMethod("getA")
				getA.returnType should be String
				val getB = cls.getDeclaredMethod("getB")
				getB.returnType should be Integer
			]
		}

		fact "the class has a data-constructor" {
			example.compile[
				getCompiledClass.getConstructor(String, Integer)
			]
		}

		fact "the class has a builder method" {
			example.compile[
				val builderMethod = getCompiledClass.getDeclaredMethod("builder")
				builderMethod.returnType should be getCompiledClass("foo.ThingBuilder")
			]
		}

		fact "the class has a build method" {
			example.compile[
				val buildMethod = getCompiledClass.getDeclaredMethod("build", Procedure1)
				buildMethod.returnType should be getCompiledClass
			]
		}

		fact "the class has a custom hashCode method" {
			example.compile[
				val hashCode = getCompiledClass.getDeclaredMethod("hashCode")
				hashCode.returnType should be int
			]
		}

		fact "the class has a custom toString method" {
			example.compile[
				val toString = getCompiledClass.getDeclaredMethod("toString")
				toString.returnType should be String
			]
		}

		fact "the class has a custom equals method" {
			example.compile[
				val equals = getCompiledClass.getDeclaredMethod("equals", Object)
				equals.returnType should be boolean
			]
		}
	}

	context "with custom methods" {
		val example = '''
			package foo

			import de.oehme.xtend.contrib.ValueObject

			@ValueObject
			class Thing {
				String a

				new(String x) {
				}

				override equals(Object o) {
					true
				}

				override hashCode() {
					0
				}

				override toString() {
					null
				}
			}
		'''

		fact "equals can be customized" {
			example.compile[
				val code = getGeneratedCode("foo.Thing")
				assert (code).containsIgnoringWhiteSpace('''
					public boolean equals(final Object o) {
						return true;
					}
				''')
			]
		}

		fact "hashCode can be customized" {
			example.compile[
				val code = getGeneratedCode("foo.Thing")
				assert (code).containsIgnoringWhiteSpace('''
					public int hashCode() {
						return 0;
					}
				''')
			]
		}

		fact "toString can be customized" {
			example.compile[
				val code = getGeneratedCode("foo.Thing")
				assert (code).containsIgnoringWhiteSpace('''
					public String toString() {
						return null;
					}
				''')
			]
		}

		fact "constructor can be customized" {
			example.compile[
				val code = getGeneratedCode("foo.Thing")
				assert (code).containsIgnoringWhiteSpace('''
					public Thing(final String x) {
					}
				''')
			]
		}
	}

	def containsIgnoringWhiteSpace(String code, String fragment) {
		val strippedCode = CharMatcher::WHITESPACE.removeFrom(code)
		val strippedFragment = CharMatcher::WHITESPACE.removeFrom(fragment)
		strippedCode.contains(strippedFragment)
	}
}
