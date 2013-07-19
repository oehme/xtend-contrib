package de.oehme.xtend.contrib.querydsl;

class ResultContextImpl<T> implements ResultContext<T> {
	private T result;
	private long resultNumber;
	private boolean stopped;

	public T getResult() {
		return result;
	}

	public void setResult(T result) {
		this.result = result;
	}

	public long getResultNumber() {
		return resultNumber;
	}

	public void setResultNumber(long resultNumber) {
		this.resultNumber = resultNumber;
	}

	public void stop() {
		stopped = true;
	}

	public boolean isStopped() {
		return stopped;
	}

}
