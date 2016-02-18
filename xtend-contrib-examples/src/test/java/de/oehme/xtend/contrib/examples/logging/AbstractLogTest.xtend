package de.oehme.xtend.contrib.examples.logging

import org.junit.Assert
import uk.org.lidalia.slf4jtest.TestLoggerFactory

abstract class AbstractLogTest {

	static val MESSAGE = "It's a trap!"

	def void testLogger(TestLogger logger) {
		// given
		TestLoggerFactory::clear()

		// when
		logger.doLog(AbstractLogTest.MESSAGE)

		// then
		Assert.assertEquals(
			AbstractLogTest.MESSAGE,
			TestLoggerFactory::getLoggingEvents().get(0).message
		)
	}
}

interface TestLogger {
	def void doLog(String msg)
}
