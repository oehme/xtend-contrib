package de.oehme.xtend.contrib.examples

import de.oehme.xtend.contrib.Cached

class Fibonacci {
	@Cached
	def static long fibonacci(long n) {
		if (n == 0)
			return 0L
		if (n == 1)
			return 1L
		return fibonacci(n -1) + fibonacci(n -2)
	}
	
	def static void main(String[] args) {
		//try this without @Cached =)
		println(fibonacci(50))
	}
	
}