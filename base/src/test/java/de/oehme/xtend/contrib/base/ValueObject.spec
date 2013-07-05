package de.oehme.xtend.contrib.base

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import com.google.common.base.Objects
import org.eclipse.xtext.xbase.lib.Procedures$Procedure1

describe ValueObject {
	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(typeof(ValueObject), typeof(Objects), typeof(Procedure1))

	val example = '''
		package foo
		
		import de.oehme.xtend.contrib.base.ValueObject
		
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
			builder.getDeclaredMethod("a", typeof(String))
			builder.getDeclaredMethod("b", typeof(Integer))
		]
	}
	
	fact "the class has a getter for each property" {
		example.compile[
			val cls = getCompiledClass
			val getA = cls.getDeclaredMethod("getA")
			getA.returnType should be typeof(String)
			val getB = cls.getDeclaredMethod("getB")
			getB.returnType should be typeof(Integer)
		]
	}
	
	fact "the class has a data-constructor" {
		example.compile[
			getCompiledClass.getConstructor(typeof(String), typeof(Integer))
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
			val buildMethod = getCompiledClass.getDeclaredMethod("build", typeof(Procedure1))
			buildMethod.returnType should be getCompiledClass
		]
	}
	
	fact "the class has a custom hashCode method" {
		example.compile[
			val hashCode = getCompiledClass.getDeclaredMethod("hashCode")
			hashCode.returnType should be typeof(int)
		]
	}
	
	fact "the class has a custom toString method" {
		example.compile[
			val toString = getCompiledClass.getDeclaredMethod("toString")
			toString.returnType should be typeof(String)
		]
	}
	
	fact "the class has a custom equals method" {
		example.compile[
			val equals = getCompiledClass.getDeclaredMethod("equals", typeof(Object))
			equals.returnType should be typeof(boolean)
		]
	}
}
