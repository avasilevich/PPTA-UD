CC		?= clang
CXX		?= clang++

CDEBUG 		= -g -Wall
CXXDEBUG 	= -g -Wall

CSTD 	= -std=c99
CXXSTD	= -std=c++11

CXXFLAGS	= $(CXXDEBUG) -lm -lfl

CLEANLIST = lex.yy.c parser.tab.c parser.tab.h a.out parser.output

OBJS = parser.tab.c lex.yy.c

all:
	$(MAKE) parser
	$(MAKE) vocabulary
	$(CXX) $(OBJS) $(CXXFLAGS)

parser:
	bison -d -v parser.y

vocabulary:
	flex vocabulary.l

clean:
	rm -rf $(CLEANLIST)