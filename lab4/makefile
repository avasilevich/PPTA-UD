CC		?= clang
CXX		?= clang++

CDEBUG 		= -g -Wall
CXXDEBUG 	= -g -Wall

CSTD 	= -std=c99
CXXSTD	= -std=c++11

CXXFLAGS	= $(CXXDEBUG) -lm -lfl

CLEANLIST = lex.yy.c parser.tab.c parser.tab.h a.out parser.output generator lab4.asm lab4.o lab4

OBJS = parser.tab.c lex.yy.c

all:
	$(MAKE) clean
	$(MAKE) parser
	$(MAKE) vocabulary
	$(MAKE) generator
	$(MAKE) compile

parser:
	bison -d -v parser.y

vocabulary:
	flex vocabulary.l

generator:
	$(CXX) $(OBJS) -o generator $(CXXFLAGS)
	./generator ./samples/success.java

compile:
	nasm -f elf lab4.asm -o lab4.o
	gcc -m32 -o lab4 lab4.o

clean:
	rm -rf $(CLEANLIST)

	# elf32     ELF32 (i386) object files (e.g. Linux)
    # elf64     ELF64 (x86_64) object files (e.g. Linux)
    # elfx32    ELFX32 (x86_64) object files (e.g. Linux)