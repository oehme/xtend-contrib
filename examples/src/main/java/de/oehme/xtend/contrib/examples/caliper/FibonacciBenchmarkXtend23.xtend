package de.oehme.xtend.contrib.examples.caliper

import com.google.caliper.Param
import com.google.caliper.Runner
import com.google.caliper.SimpleBenchmark
import com.google.common.collect.ImmutableList
import de.oehme.xtend.contrib.examples.base.Fibonaccis

class FibonacciBenchmarkXtend23 extends SimpleBenchmark {

	val extension Fibonaccis fib = new Fibonaccis

	@Param
	int n

	public val nValues = ImmutableList::of(5, 10, 20)

	def timeMemoizedFibonacci(int iterations) {
		(1 .. iterations).forEach [
			n.memoizedFibonacci
		]
	}

	def timeDumbFibonacci(int iterations) {
		(1 .. iterations).forEach [
			n.dumbFibonacci
		]
	}

	def timeiterativeFibonacci(int iterations) {
		(1 .. iterations).forEach [
			n.iterativeFibonacci
		]
	}

	def static void main(String[] args) {
		Runner::main(typeof(FibonacciBenchmarkXtend23), newArrayList)
	}
}
