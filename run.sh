if flex scanner.l ; then
  if bison -vd parser.y; then
    if gcc lex.yy.c parser.tab.c -o compiler -lfl ; then
      ./compiler < entrada
    fi
  fi
fi