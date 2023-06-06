%{
#include "parser.tab.h"
char *stringpools(char *);
%}
%option yylineno

DIGIT    [0-9]
ID       [_a-zA-Z][_A-Za-z0-9]*

%%

{DIGIT}+      {     printf("inteiro "); yylval.yint = atoi(yytext);  return(NUMINT); }

crie          {     printf("crie"); return(CRIE);}

model         {     printf("model"); return(MODEL);}
controller    {     printf("controller"); return(CONTROLLER);}
view          {     printf("view"); return(VIEW);}

campo         {     printf("campo"); return(CAMPO);}
relacao       {     printf("relação"); return(RELACAO);}

Integer       {     printf("inteiro"); return(INTEGER);}
String        {     printf("string"); return(STRING);}
Float         {     printf("float"); return(FLOAT);}
Boolean       {     printf("bool"); return(BOOL);}
Datetime      {     printf("data"); return(DATE);}
Time          {     printf("time"); return(TIME);}
Text          {     printf("texto"); return(TEXT);}

rota          {     printf("rota"); return(ROUTE);}
func          {     printf("função"); return(FUNC);}
retorne       {     printf("return"); return(RETURN);}

{ID}+         {     return(IDENTIFIER);}
"#"[A-Za-z0-9_ ]* {printf("Comentário"); } 
"\n"          {     printf("\n");}
[ \t]+ /* blank, tab, new line: eat up whitespace */
.             {     printf("%c",yytext[0]); return(yytext[0]); }

%%
