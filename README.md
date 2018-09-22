## Compile and execute

### Laba 1
1. flex vocabulary.l
2. gcc lex.yy.c -lfl
3. ./a.out sample.java

### Laba 2
1. bison -d parser.y
2. flex vocabulary.l
3. gcc parser.tab.c lex.yy.c -lm