package xtend;

import java.util.Iterator;

import org.eclipse.xtend.core.XtendStandaloneSetup;
import org.eclipse.xtend.core.compiler.batch.XtendBatchCompiler;

import com.google.common.collect.Lists;
import com.google.inject.Injector;

public class XtendCompilerMain {

	public static final String SOURCE_OPTION = "-s";
	public static final String OUTPUT_OPTION = "-o";
	public static final String CLASSPATH_OPTION = "-cp";

	private static Injector injector;

	public static void main(String[] args) {
		
		if (injector == null) {
			injector = new XtendStandaloneSetup().createInjectorAndDoEMFRegistration();
		}
		XtendBatchCompiler compiler = injector.getInstance(XtendBatchCompiler.class);
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
		if (!compiler.compile()) {
			throw new IllegalStateException("Xtend Compilation failed");
		}
	}

}
