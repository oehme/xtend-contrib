package de.oehme.xtend.contrib.examples.base

import de.oehme.xtend.contrib.base.Decorator

@Decorator(CharSequence)
class BuggyCharSequence {

	override char charAt(int i) {
		delegate.charAt(i + 1)
	}
} 