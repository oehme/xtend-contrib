package xtend;

import org.gradle.api.*;
import org.gradle.api.file.FileCollection
import org.gradle.api.tasks.*;
import org.apache.log4j.BasicConfigurator
import org.eclipse.xtend.core.XtendStandaloneSetup
import org.eclipse.xtend.core.compiler.batch.XtendBatchCompiler

class XtendPlugin implements Plugin<Project> {
	void apply(Project project) {
		project.repositories { mavenCentral() }
		project.dependencies {
			compile 'org.eclipse.xtend:org.eclipse.xtend.lib:2.4.2'
			testCompile 'org.eclipse.xtend:org.eclipse.xtend.standalone:2.4.2'
		}
		project.sourceSets {
			main {
				java {
					srcDir project.file('src/main/xtend-gen')
				}
			}
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
		project.task('compileXtend', type: CompileXtendTask) {
			srcDir = project.file('src/main/java')
			targetDir = project.file('src/main/xtend-gen')
			classpath = project.sourceSets.main.compileClasspath
		}
		project.tasks.compileJava.dependsOn('compileXtend')
		project.task('compileTestXtend', type: CompileXtendTask) {
			srcDir = project.file('src/test/java')
			targetDir = project.file('src/test/xtend-gen')
			classpath = project.sourceSets.test.compileClasspath
		}
		project.tasks.compileTestJava.dependsOn('compileTestXtend')
		project.tasks.clean.dependsOn('cleanCompileXtend', 'cleanCompileTestXtend')
	}
}

class CompileXtendTask extends DefaultTask {
	@InputDirectory
	def File srcDir

	@InputFiles
	def FileCollection classpath

	@OutputDirectory
	def File targetDir

	@TaskAction
	def compile() {
		XtendBatchCompiler compiler = new XtendStandaloneSetup().createInjectorAndDoEMFRegistration().getInstance(XtendBatchCompiler.class)
		compiler.setOutputPath(targetDir.absolutePath)
		compiler.setClassPath(classpath.asPath)
		compiler.setSourcePath(srcDir.absolutePath)
		compiler.setFileEncoding("UTF-8")
		if (!compiler.compile()) {
			throw new GradleException("Xtend compilation failed.");
		}
	}
}