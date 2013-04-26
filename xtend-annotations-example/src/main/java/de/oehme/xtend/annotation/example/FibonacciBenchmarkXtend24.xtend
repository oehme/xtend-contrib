package de.oehme.xtend.annotation.example

import de.oehme.xtend.annotation.benchmark.Benchmark
import java.util.List

@Benchmark
class FibonacciBenchmarkXtend24 {

	List<Integer> nValues = #[5, 10, 20]

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
