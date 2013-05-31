package de.oehme.xtend.contrib.examples;

import java.util.List;

import com.google.caliper.Param;
import com.google.caliper.Runner;
import com.google.caliper.SimpleBenchmark;
import com.google.common.collect.ImmutableList;

public class FibonacciBenchmarkJava extends SimpleBenchmark {

	@Param
	private int n;

	public static List<Integer> nValues = ImmutableList.of(5, 10, 20 );

	public void timeMemoizedFibonacci(int iterations) {
		for (int i = 0; i < iterations; i++) {
			new Fibonaccis().memoizedFibonacci(n);
		}
	}

	public void timeDumbFibonacci(int iterations) {
		for (int i = 0; i < iterations; i++) {
			new Fibonaccis().dumbFibonacci(n);
		}
	}

	public void timeIterativeFibonacci(int iterations) {
		for (int i = 0; i < iterations; i++) {
			new Fibonaccis().iterativeFibonacci(n);
		}
	}

	public static void main(String[] args) {
		Runner.main(FibonacciBenchmarkJava.class, args);
	}
}
