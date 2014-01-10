package xtend;

import org.gradle.api.*;
import org.gradle.api.tasks.*;
import org.apache.log4j.BasicConfigurator
import org.eclipse.xtend.core.XtendStandaloneSetup
import org.eclipse.xtend.core.compiler.batch.XtendBatchCompiler

class XtendPlugin implements Plugin<Project> {
	void apply(Project project) {
		project.repositories { mavenCentral() }
		project.dependencies {
			compile 'org.eclipse.xtend:org.eclipse.xtend.lib:2.4.3'
			testCompile 'org.eclipse.xtend:org.eclipse.xtend.standalone:2.4.3'
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
			xtendSrcDir = project.file('src/main/java')
			xtendGenTargetDir = project.file('src/main/xtend-gen')
		}
		project.tasks.compileJava.dependsOn('compileXtend')
		project.task('compileTestXtend', type: CompileXtendTask) {
			xtendSrcDir = project.file('src/test/java')
			xtendGenTargetDir = project.file('src/test/xtend-gen')
		}
		project.tasks.compileTestJava.dependsOn('compileTestXtend')
    project.tasks.clean.dependsOn('cleanCompileXtend', 'cleanCompileTestXtend')
	}
}

class CompileXtendTask extends DefaultTask {
	@InputDirectory
	def File xtendSrcDir

	@OutputDirectory
	def File xtendGenTargetDir

	@TaskAction
	def compile() {
		def srcPath = xtendSrcDir.absolutePath
		def targetPath = xtendGenTargetDir.absolutePath
		def classpath = project.configurations.compile.asPath

		BasicConfigurator.configure()
		XtendBatchCompiler compiler = new XtendStandaloneSetup().createInjectorAndDoEMFRegistration().getInstance(XtendBatchCompiler.class)
		compiler.setOutputPath(targetPath)
		compiler.setClassPath(classpath)
		compiler.setSourcePath(srcPath)
		compiler.setFileEncoding("UTF-8")
		if (!compiler.compile()) {
			throw new GradleException("Xtend compilation failed.");
		}
	}
}