package de.oehme.xtend.contrib.examples.logging

import de.oehme.xtend.contrib.slf4j.Slf4j
import org.junit.Test

class Slf4jLogTest extends AbstractLogTest {

	@Test
	def void testLog() {
		testLogger(new TestLoggerImpl)
	}

	@Slf4j
	static class TestLoggerImpl implements TestLogger {
		override void doLog(String msg) {
			log.warn(msg)
		}
	}

}