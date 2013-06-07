package de.oehme.xtend.contrib.examples.base

import de.oehme.xtend.contrib.base.Cached
import java.math.BigInteger

class Fibonaccis {
	def BigInteger dumbFibonacci(int n) {
		switch n {
			case 0: 0bi
			case 1: 1bi
			default: dumbFibonacci(n - 1) + dumbFibonacci(n - 2)
		}
	}

	@Cached
	def BigInteger memoizedFibonacci(int n) {
		switch n {
			case 0: 0bi
			case 1: 1bi
			default: memoizedFibonacci(n - 1) + memoizedFibonacci(n - 2)
		}
	}

	def BigInteger iterativeFibonacci(int n) {
		var x = 0bi
		var y = 1bi
		for (i : 1 .. n) {
			val z = x
			x = y
			y = y + z
		}
		x
	}

	@Cached
	def foo(String a, Integer b) {
		a + b
	}
}
