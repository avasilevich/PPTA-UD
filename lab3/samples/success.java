package package_name;

public class ClassName {

	public int first = 10 + (1 - 1);
	private int second = first - 1;
	
	protected double nonInitVar;
	int secondNonInitVar;

	int third = first + 8 - secondNonInitVar;

	private void firstFunc() {
		int fourth = second;
		System.out.println(fourth);
	}

	void secondFunc() {
		int five = first + second;
		System.out.println(five);
	}
}