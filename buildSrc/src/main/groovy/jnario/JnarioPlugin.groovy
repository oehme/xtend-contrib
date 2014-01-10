package jnario;

import org.gradle.api.*;
import org.gradle.api.tasks.*;
import org.jnario.compiler.CompilerMain
import org.apache.log4j.BasicConfigurator

class JnarioPlugin implements Plugin<Project> {
	void apply(Project project) {
		project.repositories { mavenCentral() }
		project.dependencies { testCompile 'org.jnario:org.jnario.lib.maven:0.5.1' }
		project.sourceSets {
			test {
				java {
					srcDir project.file('src/test/xtend-gen')
				}
			}
		}
		project.eclipse { eclipse ->
			eclipse.project {
				natures 'org.eclipse.xtext.ui.shared.xtextNature'
				buildCommand 'org.eclipse.xtext.ui.shared.xtextBuilder'
			}
		}
		project.task('compileTestJnario', type: CompileJnarioTask) {
			srcDir = project.file('src/test/java')
			targetDir = project.file('src/test/xtend-gen')
			it.dependsOn("compileTestXtend")
		}
		project.tasks.compileTestJava.dependsOn('compileTestJnario')
		project.tasks.clean.dependsOn('cleanCompileTestJnario')
	}
}

class CompileJnarioTask extends DefaultTask {
	@InputDirectory
	def File srcDir

	@OutputDirectory
	def File targetDir

	@TaskAction
	def compile() {
		def compiler = new CompilerMain()
		compiler.sourcePath = srcDir.absolutePath
		compiler.outputPath = targetDir.absolutePath
		compiler.classPath = project.sourceSets.test.compileClasspath.asPath
		if (compiler.compile() != CompilerMain.OK) {
			throw new GradleException("Jnario compilation failed")
		}
	}
}