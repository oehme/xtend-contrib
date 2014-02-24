package jnario;

import javax.inject.Inject

import org.gradle.api.*
import org.gradle.api.file.FileCollection
import org.gradle.api.file.SourceDirectorySet
import org.gradle.api.internal.file.DefaultSourceDirectorySet
import org.gradle.api.internal.file.FileResolver
import org.gradle.api.plugins.JavaPluginConvention
import org.gradle.api.tasks.*
import org.gradle.plugins.ide.eclipse.EclipsePlugin
import org.gradle.plugins.ide.eclipse.model.EclipseModel
import org.jnario.compiler.CompilerMain

import xtend.XtendCompilerMain
import xtend.XtendPlugin

class JnarioPlugin implements Plugin<Project> {

	FileResolver fileResolver

	@Inject
	JnarioPlugin(FileResolver fileResolver) {
		this.fileResolver = fileResolver
	}

	void apply(Project project) {
		project.repositories { mavenCentral() }
		project.dependencies { testCompile 'org.jnario:org.jnario.lib.maven:0.7.2' }

		project.plugins.apply(XtendPlugin)

		/*TODO eliminate duplication between this and XtendPlugin (probably by Introducing a
		 * XtendSource class.
		 */
		JavaPluginConvention java = project.convention.getPlugin(JavaPluginConvention)
		java.sourceSets.all{SourceSet sourceSet ->
			def jnarioSources = new DefaultSourceDirectorySet("jnario", fileResolver)
			jnarioSources.srcDirs(* sourceSet.getJava().srcDirs.toList())

			def jnarioGen = project.file("src/${sourceSet.getName()}/jnario-gen")
			sourceSet.getJava().srcDir(jnarioGen)
			def compileTaskName = sourceSet.getCompileTaskName("jnario")
			JnarioCompile compileTask = project.task(type: JnarioCompile, compileTaskName) {JnarioCompile it ->
				it.srcDirs = jnarioSources
				it.targetDir = jnarioGen
				it.classpath = sourceSet.compileClasspath
				it.setDescription("Compiles the ${sourceSet.getName()} Jnario sources")
			}

			def xtendCompileTaskName = sourceSet.getCompileTaskName("xtend")
			compileTask.dependsOn(xtendCompileTaskName)
			project.tasks[sourceSet.compileJavaTaskName].dependsOn(compileTask)
			project.tasks["clean"].dependsOn("clean" + compileTaskName.capitalize())
		}

		project.plugins.apply(EclipsePlugin)
		def EclipseModel eclipse = project.extensions.getByType(EclipseModel)
		eclipse.getProject().buildCommand("org.eclipse.xtext.ui.shared.xtextBuilder")
		eclipse.getProject().natures("org.eclipse.xtext.ui.shared.xtextNature")
		//TODO write preferences, telling Jnario to compile to jnario-gen instead of the default xtend-gen
	}
}

class JnarioCompile extends DefaultTask {
	@InputFiles
	SourceDirectorySet srcDirs

	@InputFiles
	FileCollection classpath

	@OutputDirectory
	File targetDir

	@Input
	boolean useDaemon

	@TaskAction
	def compile() {
		def sourcePath = srcDirs.srcDirTrees.collect{it.dir.absolutePath}.join(File.pathSeparator)
		def args = [
			XtendCompilerMain.CLASSPATH_OPTION,
			classpath.asPath,
			XtendCompilerMain.SOURCE_OPTION,
			sourcePath,
			XtendCompilerMain.OUTPUT_OPTION,
			targetDir.absolutePath
		]
		if (useDaemon) {
			compileWithDaemon(args)
		} else {
			compileWithoutDaemon(args)
		}
	}
	
	def compileWithoutDaemon(args) {
		JnarioCompilerMain.main(args as String[]);
	}

	def compileWithDaemon(args) {
		def client = new JnarioCompilerClient();
		def runtimeClasspath = getClass().getClassLoader().getURLs().collect{it.getFile().toString()}.join(File.pathSeparator)
		client.requireServer(runtimeClasspath);
		
		if (!client.compile(args)) {
			throw new GradleException("Jnario compilation failed.")
		}
	}
}