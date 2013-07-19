package de.oehme.xtend.contrib.querydsl;

public interface ResultHandler<T> {
	void handle(T result);
}
