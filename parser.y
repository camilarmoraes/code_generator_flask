%{
#include <stdio.h>
extern int yylineno;
%}
%start program
%token LET INTEGER IN
%token SKIP IF THEN ELSE END WHILE DO READ WRITE
%token NUMBER
%token IDENTIFIER
%token ASSGNOP FI
%left '-' '+'
%left '*' '/'
%right '^'

%%

program : LET declarations IN commands END
;
declarations : /* empty */
| INTEGER id_seq IDENTIFIER ';'
;
id_seq : /* empty */
| id_seq IDENTIFIER ','
;
commands : /* empty */
| commands command ';'
;
command : SKIP
| READ IDENTIFIER
| WRITE exp
| IDENTIFIER ASSGNOP exp
| IF exp THEN commands FI
| WHILE exp DO commands END
;
exp : NUMBER
| IDENTIFIER
| exp '<' exp
| exp '=' exp
| exp '>' exp
| exp '+' exp
| exp '-' exp
| exp '*' exp
| exp '/' exp
| exp '^' exp
| '(' exp ')'
;


%%


main( int argc, char *argv[] )
{


if ( yyparse () == 0) printf("codigo sem erros");

}

yyerror (char *s) /* Called by yyparse on error */
{
printf ("%s  na linha %d\n", s, yylineno );
}


