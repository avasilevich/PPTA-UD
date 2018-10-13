#ifndef DEFS_H
#define DEFS_H

namespace YY_F {
	struct Variable {
		std::string name;
		std::string type;
		std::string modificator;
		double value;
		bool initizalized;
	};

	struct OwnClass {
		std::string name;
		std::map<std::string, Variable> vars;
	};
}

#endif // DEFS_H