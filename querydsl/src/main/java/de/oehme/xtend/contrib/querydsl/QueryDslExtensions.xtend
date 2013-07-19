package de.oehme.xtend.contrib.querydsl

import com.mysema.commons.lang.CloseableIterator
import com.mysema.query.types.Expression
import com.mysema.query.types.Predicate
import com.mysema.query.types.expr.BooleanExpression
import com.mysema.query.types.expr.ComparableExpression
import com.mysema.query.types.expr.MathExpressions
import com.mysema.query.types.expr.NumberExpression
import com.mysema.query.types.expr.SimpleExpression
import com.mysema.query.types.expr.StringExpression
import com.mysema.query.types.ConstantImpl

class QueryDslExtensions {

	////////////////////////////////////////////////
	//////////////////SimpleExpression//////////////
	///////////////////////////////////////////////
	def static <T> operator_equals(SimpleExpression<T> left, T right) {
		left.eq(right)
	}

	def static <T> operator_equals(SimpleExpression<T> left, Expression<? super T> right) {
		left.eq(right)
	}

	def static <T> operator_notEquals(SimpleExpression<T> left, T right) {
		left.ne(right)
	}

	def static <T> operator_notEquals(SimpleExpression<T> left, Expression<? super T> right) {
		left.ne(right)
	}

	////////////////////////////////////////////////
	///////////////ComparableExpression/////////////
	///////////////////////////////////////////////
	def static <T extends Comparable<?>> operator_lessThan(ComparableExpression<T> left, T right) {
		left.lt(right)
	}

	def static <T extends Comparable<?>> operator_lessThan(ComparableExpression<T> left, Expression<T> right) {
		left.lt(right)
	}

	def static <T extends Comparable<?>> operator_lessEqualsThan(ComparableExpression<T> left, T right) {
		left.loe(right)
	}

	def static <T extends Comparable<?>> operator_lessEqualsThan(ComparableExpression<T> left, Expression<T> right) {
		left.loe(right)
	}

	def static <T extends Comparable<?>> operator_greaterThan(ComparableExpression<T> left, T right) {
		left.gt(right)
	}

	def static <T extends Comparable<?>> operator_greaterThan(ComparableExpression<T> left, Expression<T> right) {
		left.gt(right)
	}

	def static <T extends Comparable<?>> operator_greaterEqualsThan(ComparableExpression<T> left, T right) {
		left.goe(right)
	}

	def static <T extends Comparable<?>> operator_greaterEqualsThan(ComparableExpression<T> left, Expression<T> right) {
		left.goe(right)
	}

	////////////////////////////////////////////////
	//////////////////StringExpression//////////////
	///////////////////////////////////////////////
	def static operator_plus(StringExpression left, CharSequence right) {
		left.append(right.toString)
	}

	def static operator_plus(StringExpression left, Expression<String> right) {
		left.append(right)
	}

	def static operator_plus(CharSequence left, StringExpression right) {
		right.prepend(left.toString)
	}

	////////////////////////////////////////////////
	//////////////////NumberExpression//////////////
	///////////////////////////////////////////////
	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_plus(
		NumberExpression<A> left, Expression<B> right) {
		left.add(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_plus(NumberExpression<A> left, B right) {
		left.add(new ConstantImpl(right))
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_minus(
		NumberExpression<A> left, Expression<B> right) {
		left.subtract(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_minus(
		NumberExpression<A> left, B right) {
		left.subtract(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_divide(
		NumberExpression<A> left, Expression<B> right) {
		left.divide(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_divide(
		NumberExpression<A> left, B right) {
		left.divide(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_multiply(
		NumberExpression<A> left, Expression<B> right) {
		left.multiply(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_multiply(
		NumberExpression<A> left, B right) {
		left.multiply(new ConstantImpl(right))
	}

	def static <A extends Number & Comparable<?>> operator_power(NumberExpression<A> left, int right) {
		MathExpressions.power(left, right)
	}

	def static <N extends Number & Comparable<?>> operator_modulo(NumberExpression<N> left, Expression<N> right) {
		left.mod(right)
	}

	def static <N extends Number & Comparable<?>> operator_modulo(NumberExpression<N> left, N right) {
		left.mod(right)
	}

	def static <N extends Number & Comparable<?>> operator_minus(NumberExpression<N> expr) {
		expr.negate
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_lessThan(
		NumberExpression<A> left, B right) {
		left.lt(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_lessThan(
		NumberExpression<A> left, Expression<B> right) {
		left.lt(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_lessEqualsThan(
		NumberExpression<A> left, B right) {
		left.loe(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_lessEqualsThan(
		NumberExpression<A> left, Expression<B> right) {
		left.loe(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_greaterThan(
		NumberExpression<A> left, B right) {
		left.gt(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_greaterThan(
		NumberExpression<A> left, Expression<B> right) {
		left.gt(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_greaterEqualsThan(
		NumberExpression<A> left, B right) {
		left.goe(right)
	}

	def static <A extends Number & Comparable<?>, B extends Number & Comparable<?>> operator_greaterEqualsThan(
		NumberExpression<A> left, Expression<B> right) {
		left.goe(right)
	}

	////////////////////////////////////////////////
	///////////BooleanExpression/Predicate//////////
	///////////////////////////////////////////////
	def static operator_not(Predicate pred) {
		pred.not()
	}

	def static operator_and(BooleanExpression left, Predicate right) {
		left.and(right)
	}

	def static operator_or(BooleanExpression left, Predicate right) {
		left.or(right)
	}

	/////////////////////////////////////////
	//////////CloseableIterator//////////////
	////////////////////////////////////////
	def static <T> process(CloseableIterator<T> iterator, ResultHandler<ResultContext<T>> handler) {
		val ctx = new ResultContextImpl
		try {
			while (iterator.hasNext && !ctx.stopped) {
				ctx.result = iterator.next
				ctx.resultNumber = ctx.resultNumber + 1
				handler.handle(ctx)
			}
		} finally {
			iterator.close
		}
	}

	def static <T> forEach(CloseableIterator<T> iterator, ResultHandler<? super T> handler) {
		iterator.process[handler.handle(result)]
	}
}
