package de.oehme.xtend.contrib.examples.logging

import de.oehme.xtend.contrib.logging.Slf4j
import uk.org.lidalia.slf4jtest.TestLoggerFactory
import org.junit.Assert
import org.junit.Test
import org.junit.Before

@Slf4j
class Slf4jTest {

	@Before
	def void setup() {
		TestLoggerFactory.clear()
	}

	@Test
	def void testLogger() {
		// when
		log.warn("It's a trap!")

		// then
		Assert.assertEquals(
			"It's a trap!",
			TestLoggerFactory.getLoggingEvents().get(0).message
		)
	}
}