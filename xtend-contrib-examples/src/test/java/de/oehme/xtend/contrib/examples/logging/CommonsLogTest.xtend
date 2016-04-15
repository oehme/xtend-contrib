package de.oehme.xtend.contrib.examples.logging

import de.oehme.xtend.contrib.commonslog.CommonsLog
import org.junit.Test

class CommonsLogTest extends AbstractLogTest {

	@Test
	def void testLog() {
		testLogger(new TestLoggerImpl)
	}

	@CommonsLog
	static class TestLoggerImpl implements TestLogger {
		override void doLog(String msg) {
			log.warn(msg)
		}
	}

}
