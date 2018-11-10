package package_name;

public class ClassName {

	public int first = 10;
	private int second = 1;
	
	protected int nonInitVar;

	int secondNonInitVar;
	int third = 8;

	private void firstFunc() {	
		int a = 2;


		while(a < 5) {
			a = a + 1;
		}

		System.out.println(a);
	}

	public static void main() {
		int b = 3;
		int c = 1;

		c = b + 1;

		if(c > 3) {
			c = c + 10;
		} else {
			c = c + 20;
		}

		System.out.println(c);
		this->firstFunc();
	}
}