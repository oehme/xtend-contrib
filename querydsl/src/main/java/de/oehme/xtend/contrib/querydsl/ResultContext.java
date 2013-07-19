package de.oehme.xtend.contrib.querydsl;

public interface ResultContext<T> {
	T getResult();
	long getResultNumber();
	void stop();
}
