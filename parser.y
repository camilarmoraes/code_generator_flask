%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "sym.h"
extern int yylineno;
extern VAR *SymTab;
int semerro=0;
int asController = 0;
#define AddVAR(n,t) SymTab=MakeVAR(n, t, SymTab)
#define ASSERT(x,y) if(!(x)) { printf("%s na  linha %d\n",(y),yylineno); semerro=1; }
FILE * output_model;
FILE * output_controller;
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
%token <ystr> IDENTIFIER COMENTARIO
%token INTEGER STRING FLOAT DATE TIME BOOL TEXT
%token ROUTE FUNC RETURN
%token PK FK
%type <ystr> type_specifier 

%%

program : statements 
        ;

statements : statement ';'
            | statements statement ';'
            | statements comentario_declaration 
            ;
            
statement : model_declaration 
          | controller_declaration
          | field_declaration 
          | route_declation
          | function_declation
          ;

comentario_declaration : COMENTARIO {
      fprintf(output_model,"%s\n",$1);
};

key : { fprintf(output_model,")\n");}
    | ',' PK{ fprintf(output_model,")\n");}
    | ',' FK '=' IDENTIFIER '.' IDENTIFIER { fprintf(output_model,",sa.ForeignKey(%s.%s)",$4,$6);}
;

null : 
      | ',' IDENTIFIER {fprintf(output_model,", nullable=False)\n");}
      ;

model_declaration : CRIE MODEL IDENTIFIER {
                        asController = 0;
                        fprintf(output_model,"class %s (db.Model):\n",$3);
                    }
                  ;

field_declaration : CRIE CAMPO IDENTIFIER ':' type_specifier {
                          if (asController == 0){
                              fprintf(output_model,"\t%s = sa.Column(sa.%s",$3,$5);
                              AddVAR($3,$5);
                          }
                          } key null
                  ;

type_specifier : STRING {$$="String";}
                |INTEGER {$$="Integer";}
                |FLOAT {$$="Float";}
                |DATE {$$="Date";}
                |BOOL {$$="Boolean";}
                |TEXT {$$="Text";}
                ;

function_declation : FUNC CONTROLLER IDENTIFIER{fprintf(output_controller,"def %s(*args, **kwargs):\n\tpass\n",$3);}
                    |FUNC MODEL IDENTIFIER{fprintf(output_model,"\ndef %s(*args, **kwargs):\n\tpass\n",$3);}
              | ;

// PARTES DO CONTROLLER 
route_declation : CRIE ROUTE '/' IDENTIFIER{
              if (asController ==1)
                fprintf(output_controller,"\n@app.route('/%s') \n",$4);
              //else
                //ASSERT("Rotas não podem ser criadas em Models!");

};

controller_declaration : CRIE CONTROLLER IDENTIFIER{
                          asController = 1;
                          fprintf(output_controller,"import flask\nfrom flask import render_template,redirect,url_for,request,abort\n");

};

%%


main( int argc, char *argv[] )
{
  output_model= fopen("output_model.py", "w");
  output_controller= fopen("output_controller.py", "w");

  init_stringpool(10000);
  //create_controller(nome)
  if ( yyparse () == 0 && semerro==0 ) printf("codigo sem erros");
  imprimi();

}

yyerror (char *s) /* Called by yyparse on error */
{
  printf ("%s  na linha %d\n", s, yylineno );
}



