package xtend;

import java.util.List;

import com.google.common.base.Throwables;
import com.google.common.collect.Lists;
import com.martiansoftware.nailgun.Alias;
import com.martiansoftware.nailgun.NGContext;
import com.martiansoftware.nailgun.NGServer;

public class XtendCompilerServer {

	public static final int DEFAULT_PORT = 3032;

	public static void fork(String classpath) {
		List<String> command = Lists.newArrayList("java");
		command.add("-classpath");
		command.add(classpath);
		command.add(XtendCompilerServer.class.getName());
		try {
			Runtime.getRuntime().exec(command.toArray(new String[command.size()]));
		} catch (Exception e) {
			Throwables.propagate(e);
		}
	}

	public static void main(String[] args) {
		NGServer server = new NGServer(null, DEFAULT_PORT);
		server.getAliasManager().addAlias(new Alias("xtend", "Compile Xtend files", XtendCompilerServer.class));

		Thread thread = new Thread(server);
		thread.setName("Xtend compiler server");
		thread.start();
	}

	public static void nailMain(NGContext context) {
		XtendCompilerMain.main(context.getArgs());
	}

}