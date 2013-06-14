package de.oehme.xtend.contrib.examples.caliper

import com.google.caliper.Param
import com.google.caliper.Runner
import com.google.caliper.SimpleBenchmark
import com.google.common.collect.ImmutableList
import de.oehme.xtend.contrib.examples.base.Fibonaccis

class FibonacciBenchmarkXtend23 extends SimpleBenchmark {

	@Param
	int n

	public val nValues = ImmutableList::of(5, 10, 20)

	def timeMemoizedFibonacci(int iterations) {
		(1 .. iterations).forEach [
			new Fibonaccis().memoizedFibonacci(n)
		]
	}

	def timeDumbFibonacci(int iterations) {
		(1 .. iterations).forEach [
			new Fibonaccis().dumbFibonacci(n)
		]
	}

	def timeiterativeFibonacci(int iterations) {
		(1 .. iterations).forEach [
			new Fibonaccis().iterativeFibonacci(n)
		]
	}

	def static void main(String[] args) {
		Runner::main(typeof(FibonacciBenchmarkXtend23), newArrayList)
	}
}
