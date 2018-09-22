package com.danilchican.ppta.lab1;

public class ClassName {
	/**
	 * multi-line comment 
	 * multi-line subcomment
	 */
	private static Integer intVar = 10; // single line comment
	protected String myStrng = "....string....";

	public void main() {
		// define variable
		Double doubVar = 10.2 + 10.5 - 1.2 / 2.0 * 1.0;
		doubVar++;
		doubVar--;

		String strVar = "short string";
		strVar += "substr";

		doubVar -= 1.0;
		doubVar *= 614.10;
		doubVar /= 10.15;

		if (a == b && 1 != 2 || 2 >= 0 && 1 <= 1) {
			doubVar = 10;
		} else {
			doubVar = 11;
		}

		Integer mas[10] = {...};
	}
}
