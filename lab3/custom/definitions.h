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

	struct Method {
		std::string name;
		std::string returnType;
		std::string modificator;
		std::map<std::string, Variable> vars;
	};

	struct OwnClass {
		std::string name;
		std::string package;
		std::map<std::string, Variable> vars;
		std::map<std::string, Method> methods;
	};
}

#endif // DEFS_H