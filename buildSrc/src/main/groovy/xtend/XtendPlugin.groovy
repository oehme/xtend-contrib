package xtend;

import javax.inject.Inject;

import org.gradle.api.*;
import org.gradle.api.file.FileCollection
import org.gradle.api.file.FileTreeElement;
import org.gradle.api.file.SourceDirectorySet;
import org.gradle.api.internal.file.DefaultSourceDirectorySet
import org.gradle.api.internal.file.FileResolver;
import org.gradle.api.plugins.JavaPlugin;
import org.gradle.api.plugins.JavaPluginConvention;
import org.gradle.api.tasks.*;
import org.gradle.plugins.ide.eclipse.EclipsePlugin;
import org.gradle.plugins.ide.eclipse.model.EclipseModel;

class XtendPlugin implements Plugin<Project> {

	FileResolver fileResolver

	@Inject
	XtendPlugin(FileResolver fileResolver) {
		this.fileResolver = fileResolver
	}

	void apply(Project project) {
		project.configurations.create("xtend")
		project.extensions.create("xtend", XtendExtension)

		project.plugins.apply(JavaPlugin)
		JavaPluginConvention java = project.convention.getPlugin(JavaPluginConvention)
		java.sourceSets.all{SourceSet sourceSet ->
			def xtendSources = new DefaultSourceDirectorySet("xtend", fileResolver)
			xtendSources.srcDirs(* sourceSet.getJava().srcDirs.toList())

			def xtendGen = project.file("src/${sourceSet.getName()}/xtend-gen")
			sourceSet.getJava().srcDir(xtendGen)

			def compileTaskName = sourceSet.getCompileTaskName("xtend")
			XtendCompile compileTask = project.task(type: XtendCompile, compileTaskName) {XtendCompile it ->
				it.srcDirs = xtendSources
				it.targetDir = xtendGen
				it.classpath = sourceSet.compileClasspath
				it.setDescription("Compiles the ${sourceSet.getName()} Xtend sources")
			}
			project.tasks[sourceSet.compileJavaTaskName].dependsOn(compileTask)
			project.tasks["clean"].dependsOn("clean" + compileTaskName.capitalize())
		}

		project.plugins.apply(EclipsePlugin)
		def EclipseModel eclipse = project.extensions.getByType(EclipseModel)
		eclipse.getProject().buildCommand("org.eclipse.xtext.ui.shared.xtextBuilder")
		eclipse.getProject().natures("org.eclipse.xtext.ui.shared.xtextNature")
	}
}

class XtendCompile extends DefaultTask {
	@InputFiles
	SourceDirectorySet srcDirs

	@InputFiles
	FileCollection classpath

	@OutputDirectory
	File targetDir

	String encoding

	@TaskAction
	def compile() {
		if (encoding == null) {
			encoding = project.extensions.xtend.encoding
			if (encoding == null) {
				encoding = "UTF-8"
			}
		}
		def sourcePath = srcDirs.srcDirTrees.collect{it.dir.absolutePath}.join(File.pathSeparator)
		def process = Runtime.runtime.exec("java -cp ${project.configurations.xtend.asPath} org.eclipse.xtend.core.compiler.batch.Main -cp ${classpath.asPath} -d ${targetDir.absolutePath} -encoding ${encoding} ${sourcePath}")
		def exitCode = process.waitFor()
		if (exitCode != 0) {
			throw new GradleException("Xtend Compilation failed");
		}
	}
}

class XtendExtension {
	String encoding
}