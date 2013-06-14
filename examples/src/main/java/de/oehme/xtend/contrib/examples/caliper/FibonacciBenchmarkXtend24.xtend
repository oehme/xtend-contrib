package de.oehme.xtend.contrib.examples.caliper

import de.oehme.xtend.contrib.caliper.Benchmark
import de.oehme.xtend.contrib.examples.base.Fibonaccis
import java.util.List

@Benchmark
class FibonacciBenchmarkXtend24 {

	val List<Integer> nValues = #[5, 10, 20]

	def timeDumbFibonacci() {
		for (i : 1 .. iterations) {
			new Fibonaccis().dumbFibonacci(n)
		}
	}

	def loopMemoizedFibonacci() {
		new Fibonaccis().memoizedFibonacci(n)
	}

	def loopIterativeFibonacci() {
		new Fibonaccis().iterativeFibonacci(n)
	}
}
