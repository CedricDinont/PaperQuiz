package src;

public class Paire<T extends Object, S extends Object> implements
		Comparable<Paire<T, S>> {
	private T first;
	private S second;

	public Paire(T t, S s) {
		this.first = t;
		this.second = s;
	}

	public T getFirst() {
		return this.first;
	}

	public S getSecond() {
		return this.second;
	}

	public boolean equals(Object obj) {
		// pfff mal fait les types génériques alors que je veux justement faire
		// une comparaison indépendante du type
		@SuppressWarnings("unchecked")
		Paire<T, S> pair = (Paire<T, S>) obj;
		if (pair != null) {
			return pair.first.equals(this.first)
					&& pair.second.equals(this.second);
		} else {
			return super.equals(obj);
		}
	}
	
	public int hashCode() {
		return this.first.hashCode()+this.second.hashCode();
	}

	public int compareTo(Paire<T, S> o) {
		if (o.first.equals(this.first) && o.second.equals(this.second)) {
			return 0;
		} else {
			return 1;
		}
	}
}
