flex scanner.l

bison -vd parser.y

gcc lex.yy.c parser.tab.c -o compiler -lfl

./compiler < entrada