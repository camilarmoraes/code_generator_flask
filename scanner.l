%{
#include "parser.tab.h"
char *stringpools(char *);
%}
%option yylineno

DIGIT    [0-9]
ID       [_a-zA-Z][_A-Za-z0-9]*

%%

{DIGIT}+      {      yylval.yint = atoi(yytext);  return(NUMINT); }

crie          {      return(CRIE);}

model         {      return(MODEL);}
controller    {      return(CONTROLLER);}
view          {      return(VIEW);}

campo         {      return(CAMPO);}
relacao       {     return(RELACAO);}

Integer       {      return(INTEGER);}
String        {      return(STRING);}
Float         {      return(FLOAT);}
Boolean       {      return(BOOL);}
Datetime      {      return(DATE);}
Time          {      return(TIME);}
Text          {      return(TEXT);}

rota          {      return(ROUTE);}
func          {      return(FUNC);}
retorne       {      return(RETURN);}
template      {      return(TEMPLATE);}
redirecionar  {      return(REDIRECT);}

FK            {     return(FK);}
PK            {      return(PK);}
nulo          {      return(NULO);}
special        {     return(SPECIAL);}
addbanco       {    return(ADDBANCO);}
deletebanco    {     return(DELETEBANCO);}
readbanco      {    return(READBANCO);}
updatebanco    {    return(UPDATEBANCO);}



{ID}+         {     yylval.ystr = stringpool(yytext); return(IDENTIFIER);}
"#".*         {     yylval.ystr = stringpool(yytext); return(COMENTARIO);} 
"#"[^#]*"#"    { return (COMMENT_BLOCK); }


"\n"          {     }
[ \t]+ /* blank, tab, new line: eat up whitespace */
.             {      return(yytext[0]); }

%%
