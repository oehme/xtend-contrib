package de.oehme.xtend.contrib.examples.logging

import de.oehme.xtend.contrib.logging.Log
import org.junit.Test
import org.slf4j.bridge.SLF4JBridgeHandler

class JulLogTest extends AbstractLogTest {

	@Test
	def void testLog() {
		SLF4JBridgeHandler::install
		testLogger(new TestLoggerImpl)
	}

	@Log
	static class TestLoggerImpl implements TestLogger {
		override doLog(String msg) {
			log.warning(msg)
		}
	}
}
