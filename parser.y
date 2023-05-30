%{
#include <stdio.h>
#include <string.h>
extern int yylineno;
#define ASSERT(x,y) if(!(x)) printf("%s na  linha %d\n",(y),yylineno)
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



%%
program : statements
        ;

statements : statement
            | statements statement
            ;
            
statement : model_declaration
          | field_declaration
          | relation_declaration
          | controller_declaration
          | view_declaration
          ;

model_declaration : CRIE MODEL IDENTIFIER ';' {
                        
                    }
                  ;

field_declaration : CRIE CAMPO IDENTIFIER ':' INTEGER ';'
                    {  
                    }
                  ;

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
	if( yyparse () == 0) 
		printf("codigo sem erros");
}

yyerror (char *s) /* Called by yyparse on error */
{
printf ("%s  na linha %d\n", s, yylineno );
}


