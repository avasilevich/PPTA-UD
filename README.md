## Compile and execute

### Laba 1
1. flex vocabulary.l
2. gcc lex.yy.c -lfl
3. ./a.out sample.java

### Laba 2
1. bison -d parser.y
2. flex vocabulary.l
3. g++ parser.tab.c lex.yy.c -lm -lfl
4. ./a.out ./samples/success.java || ./a.out ./samples/errors.java

### Laba 3
1. make all - compile
2. make clean - clean output files
3. ./a.out ./samples/success.java