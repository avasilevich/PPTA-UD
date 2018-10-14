package package_name;

public class ClassName {

	public int first = 10 + (1 - 1);
	private int second = first - 1;
	
	protected double nonInitVar;
	int secondNonInitVar;

	int third = first + 8;

	private void firstFunc() {
		int fourth = second;
		int a = 1;
		int b = 1;
		int c = 99;

		if(a != b) {
			c = 88;
		} 

		System.out.println(c);
	}

	int secondFunc() {
		int five = first + second / 2;
		System.out.println(five);

		return five;
	}

	public static void main() {
		int a = this->secondFunc() + 1;
	}
}