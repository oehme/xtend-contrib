package de.oehme.xtend.contrib.examples.logging

import de.oehme.xtend.contrib.logging.Log4j2
import org.junit.Test

class Log4j2Test extends AbstractLogTest {

	@Test
	def void testLog() {
		testLogger(new TestLoggerImpl)
	}

	@Log4j2
	static class TestLoggerImpl implements TestLogger {
		override doLog(String msg) {
			log.warn(msg)
		}
	}
}
