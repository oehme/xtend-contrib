package de.oehme.xtend.contrib.examples.logging

import de.oehme.xtend.contrib.logging.Log4j
import org.junit.Test

class Log4jTest extends AbstractLogTest {

	@Test
	def void testLog() {
		testLogger(new TestLoggerImpl)
	}

	@Log4j
	static class TestLoggerImpl implements TestLogger {
		override void doLog(String msg) {
			log.warn(msg)
		}
	}

}