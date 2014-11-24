package de.oehme.xtend.contrib

import java.util.regex.Pattern
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.file.Path

@FinalFieldsConstructor
class Reflections {
	
	val extension TransformationContext context
	
	def Iterable<? extends Type> findTypes(Path packageFolder, boolean includeSubPackages) {
		val currentPackage = packageFolder.sourceFolder.relativize(packageFolder).toString.replace("/",".")
		val packagePrefix = if (currentPackage.isEmpty) "" else currentPackage + "."
		val types = newLinkedHashSet
		types += packageFolder.children
			.filter[fileExtension == "xtend" || fileExtension == "java"]
			.map[containedTypes(context)].flatten
			.map[findTypeGlobally(packagePrefix + it)]
			.filterNull
		if (includeSubPackages) {
			types += packageFolder.children.filter[isFolder].map[findTypes(includeSubPackages)].flatten
		}
		types
	}
	
	
	static val TYPE_PATTERN = Pattern.compile(".*(class|interface|enum|annotation)\\s+([^\\s{]+).*")
	
	//TODO this approach breaks for nested classes
	private def containedTypes(Path file, extension TransformationContext context) {
		val matcher = TYPE_PATTERN.matcher(file.contents)
		val typeNames = newLinkedHashSet
		while (matcher.find) {
			typeNames += matcher.group(2)
		}
		typeNames
	}
}