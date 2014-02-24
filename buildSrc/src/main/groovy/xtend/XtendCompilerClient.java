package xtend;

import java.io.File;
import java.util.List;

import scala.collection.JavaConverters;

import com.google.common.base.Throwables;
import com.typesafe.zinc.ZincClient;

public class XtendCompilerClient {

	private ZincClient zinc = new ZincClient(XtendCompilerServer.DEFAULT_PORT);

	public boolean compile(List<String> args) {
		return zinc.send("xtend", 
				JavaConverters.asScalaBufferConverter(args).asScala(),
				new File(""), System.out, System.err)
			== 0;
	}

	public void requireServer(String classpath) {
		if (!isServerRunning()) {
			startServer(classpath);
		}
	}

	private boolean isServerRunning() {
		return zinc.serverAvailable();
	}

	private void startServer(String classpath) {
		XtendCompilerServer.fork(classpath);
		int count = 0;
		while (!isServerRunning() && count < 50) {
			try {
				Thread.sleep(100);
				count++;
			} catch (InterruptedException e) {
				Throwables.propagate(e);
			}
		};
	}
}
