package jnario;

import java.util.Iterator;
import java.util.List;

import org.eclipse.emf.ecore.resource.ResourceSet;
import org.jnario.compiler.JnarioBatchCompiler;
import org.jnario.feature.FeatureStandaloneSetup;
import org.jnario.spec.SpecStandaloneSetup;
import org.jnario.suite.SuiteStandaloneSetup;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.inject.Injector;
import com.google.inject.Provider;

public class JnarioCompilerMain {

	public static final String SOURCE_OPTION = "-s";
	public static final String OUTPUT_OPTION = "-o";
	public static final String CLASSPATH_OPTION = "-cp";

	private static List<Injector> injectors;

	public static void main(String[] args) {
		if (injectors == null) {
			injectors = ImmutableList.of(new SpecStandaloneSetup().createInjectorAndDoEMFRegistration(),
					new FeatureStandaloneSetup().createInjectorAndDoEMFRegistration(),
					new SuiteStandaloneSetup().createInjectorAndDoEMFRegistration());
		}
		final ResourceSet resourceSet = injectors.get(0).getInstance(ResourceSet.class);
		for (Injector injector : injectors) {
			JnarioBatchCompiler compiler = injector.getInstance(JnarioBatchCompiler.class);
			Iterator<String> iterator = Lists.newArrayList(args).iterator();
			while (iterator.hasNext()) {
				switch (iterator.next()) {
				case CLASSPATH_OPTION:
					compiler.setClassPath(iterator.next());
					break;
				case OUTPUT_OPTION:
					compiler.setOutputPath(iterator.next());
					break;
				case SOURCE_OPTION:
					compiler.setSourcePath(iterator.next());
					break;
				}
			}
			compiler.setFileEncoding("UTF-8");
			compiler.setResourceSetProvider(new Provider<ResourceSet>() {
				public ResourceSet get() {
					return resourceSet;
				}
			});
			if (!compiler.compile()) {
				throw new IllegalStateException("Jnario Compilation failed");
			}
		}
	}
}
