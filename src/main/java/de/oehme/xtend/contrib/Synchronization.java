package de.oehme.xtend.contrib;

import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

public class Synchronization {

	private Synchronization() {
	}

	public static <T> void synchronize(T lockedObject, Procedure1<? super T> block) {
		synchronized (lockedObject) {
			block.apply(lockedObject);
		}
	}

	public static <T, R> R synchronize(T lockedObject, Function1<? super T, ? extends R> func) {
		synchronized (lockedObject) {
			return func.apply(lockedObject);
		}
	}
}
