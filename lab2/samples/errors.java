package package_name;

public class ClassName {

	/* error here */
	public int first = 10 + (1 - 1) / 0;
	private int second = unknown_var;  // here too

	int third = first + 8;

	errorDeclarationFunc() { // one more compilation error
		System.out.println(third);
	}
}