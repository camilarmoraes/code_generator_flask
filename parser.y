%{
#include <stdio.h>
#include <ctype.h>
#include "sym.h"
extern int yylineno;
extern VAR *SymTab;
int semerro=0;

#define AddVAR(n,t) SymTab=MakeVAR(n,t,SymTab)
#define ASSERT(x,y) if(!(x)) { printf("%s na  linha %d\n",(y),yylineno); semerro=1; }
FILE * output;
%}
%define parse.error verbose
%union {
	char * ystr;
	int   yint;
}
%start program
%token CRIE
%token MODEL CONTROLLER VIEW
%token CAMPO RELACAO

%token <yint> NUMINT
%token <ystr> IDENTIFIER
%token INTEGER STRING FLOAT DATE TIME BOOL TEXT
%token ROUTE FUNC RETURN



%%
program : statements 
        ;

statements : statement ';'
            | statements statement ';'
            ;
            
statement : model_declaration 
          | field_declaration 
          | relation_declaration 
          | controller_declaration 
          | view_declaration
          | route_declation
          | function_declation
          ;

model_declaration : CRIE MODEL IDENTIFIER {
                      //AddVAR("STRINMG",0);
                      MakeVAR("AddVAR",0,SymTab);
                    }
                  ;

field_declaration : CRIE CAMPO IDENTIFIER ':' type_specifier{  

                    }
                  ;
type_specifier : INTEGER 
                | STRING
                | FLOAT
                | BOOL
                | DATE
                | TIME
                | TEXT{

                };

route_declation : CRIE ROUTE '/' IDENTIFIER{

}

function_declation : CRIE FUNC IDENTIFIER{
  
}

relation_declaration : RELACAO IDENTIFIER ':' IDENTIFIER ';'{
                          
                      }
                    ;

controller_declaration : CONTROLLER IDENTIFIER ';'{

                      }            
                    ;
view_declaration : VIEW IDENTIFIER ';'{

                      };



%%


main( int argc, char *argv[] )
{
  init_stringpool(99999);
	if( yyparse () == 0) 
		printf("codigo sem erros");
}

yyerror (char *s) /* Called by yyparse on error */
{
printf ("%s  na linha %d\n", s, yylineno );
}


