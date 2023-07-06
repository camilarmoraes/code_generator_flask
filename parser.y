%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "sym.h"
extern int yylineno;
extern VAR *SymTab;
int semerro=0;
int asController = 0;
char nomeModel[100];
char idModel[100];
int onRoute, routeSpecial, checkImportModel, checkImportController, nulo = 0;
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
%token <ystr> IDENTIFIER COMENTARIO NULO COMMENT_BLOCK
%token INTEGER STRING FLOAT DATE TIME BOOL TEXT
%token ROUTE FUNC RETURN SPECIAL
%token PK FK REDIRECT TEMPLATE
%token ADDBANCO DELETEBANCO UPDATEBANCO READBANCO
%type <ystr> type_specifier 

%%

program : statements 
        ;

statements : statement ';'
            | statements statement ';'
            | statements comentario_declaration 
            | comentario_declaration
            ;
            
statement : model_declaration 
          | controller_declaration
          | field_declaration 
          | route_declation
          | function_declation
          | relation_declaration
          ;

comentario_declaration : COMENTARIO {
      if (asController == 0){
        fprintf(output_model,"%s\n",$1);
      }else{
        fprintf(output_controller,"%s\n",$1);
      }
      }
      | COMMENT_BLOCK { 
        if (asController == 0){
        fprintf(output_model,"%s",$1);
      }else{
        fprintf(output_controller,"%s",$1);
      }
      }

      
;

key : { fprintf(output_model,"");}
    | ',' FK '=' IDENTIFIER '.' IDENTIFIER { if(nulo == 0){
                                               fprintf(output_model,",sa.ForeignKey(%s.%s)",$4,$6);
                                               }else{
                                                ASSERT((NULL),"Verifique a ordem de prioridade!");
                                               }
                                               nulo = 0;}      
    | ',' PK { fprintf(output_model,", primary_key=True");}                 
    | ',' FK  '=' IDENTIFIER '.' IDENTIFIER '-' PK{fprintf(output_model,", sa.ForeignKey(%s.%s), primary_key=True",$4,$6);}
    | ',' PK '-' FK '=' IDENTIFIER '.' IDENTIFIER {ASSERT((NULL),"A FK deve ser declarada antes da PK");}
                                         
;

null : {fprintf(output_model,"");}
      |',' NULO{ nulo = 1; fprintf(output_model,", nullable = False");}
      ;

specciais : key null { fprintf(output_model,")\n"); nulo = 0;}
            |null key{ fprintf(output_model,")\n");}
          ;

model_declaration : CRIE MODEL IDENTIFIER {
                        asController = 0;
                        if(checkImportModel == 0){
                          fprintf(output_model,"import sqlalchemy as sa\n");
                          fprintf(output_model,"from flask_sqlalchemy import SQLAlchemy\n");
                          fprintf(output_model,"\ndb = SQLAlchemy()\n");
                          strcpy(nomeModel,$3);
                        }
                        checkImportModel = 1;
                        fprintf(output_model,"\nclass %s (db.Model):\n",$3);
                    }
                  ;

field_declaration : CRIE CAMPO IDENTIFIER ':' type_specifier {
                          if (asController == 0){
                              fprintf(output_model,"\t%s = sa.Column(sa.%s",$3,$5);
                              AddVAR($3,$5);
                          }
                          if (strcmp($3,"id") == 0){
                            strcpy(idModel,$3);
                          }
                          } specciais
;

type_specifier : STRING {$$="String(200)";}
                |INTEGER {$$="Integer";}
                |FLOAT {$$="Float";}
                |DATE {$$="Date";}
                |BOOL {$$="Boolean";}
                |TEXT {$$="Text";}
                ;

relation_declaration: CRIE RELACAO IDENTIFIER ':' IDENTIFIER{
                if (asController == 0){
                  fprintf(output_model,"\t%s = db.relanshionship('%s')\n",$3,$5);
                }
}; 

operation_banco :  ADDBANCO IDENTIFIER {
                    if(onRoute == 1 ){
                      fprintf(output_controller,"\ndef %s():\n\t",$2);
                      fprintf(output_controller,"if request.method=='POST':");
                      fprintf(output_controller,"\n\t\t_ex = %s(request.form['__ex'])",nomeModel);
                      fprintf(output_controller,"\n\t\tdb.session.add(_ex)\n\t\tdb.session.commit()");
                    }else{
                      ASSERT((NULL),"ROTA NÃO FOI DEFINIDA");
                    }
                    
                  }
                 | DELETEBANCO IDENTIFIER{
                  if(onRoute == 1 ){
                    if(routeSpecial == 1)
                      fprintf(output_controller,"\ndef %s(%s):\n\t",$2,idModel);
                    else
                      ASSERT((NULL),"ROTA NÃO DEFINIDA ADEQUADAMENTE");
                    fprintf(output_controller,"_ex = %s.query.get(%s)",nomeModel,idModel);
                    }else{
                      ASSERT((NULL),"ROTA NÃO FOI DEFINIDA");
                    }
                    routeSpecial = 0;
                 }
                 | UPDATEBANCO IDENTIFIER{
                  if(onRoute == 1 ){
                    if(routeSpecial == 1)
                      fprintf(output_controller,"\ndef %s(%s):\n\t",$2,idModel);
                    else
                      ASSERT((NULL),"ROTA NÃO DEFINIDA ADEQUADAMENTE");
                   fprintf(output_controller,"_ex = %s.query.get(%s)\n",nomeModel,idModel);
                   fprintf(output_controller,"\tif request.method == 'POST':\n");
                   fprintf(output_controller,"\t\t_ex._ex2 = request.form['__ex']\n\t\tdb.session()");
                   }else{
                      ASSERT((NULL),"ROTA NÃO FOI DEFINIDA");
                    }
                    routeSpecial = 0;
                 }
                 | READBANCO IDENTIFIER{
                  if(onRoute == 1 ){
                    if(routeSpecial == 1)
                      fprintf(output_controller,"\ndef %s(%s):\n",$2,idModel);
                    else
                      ASSERT((NULL),"ROTA NÃO DEFINIDA ADEQUADAMENTE");
                  fprintf(output_controller,"\n\_ex = %s.query.all(%s)",nomeModel,idModel);
                  }else{
                      ASSERT((NULL),"ROTA NÃO FOI DEFINIDA");
                    }
                    routeSpecial = 0;
                 }
                 ;

return_declaration :  TEMPLATE {fprintf(output_controller,"\n\treturn render_template("__.html")\n");}
                    | REDIRECT {fprintf(output_controller,"\n\treturn redirect(url_for(__))\n");}

arguments : IDENTIFIER{
            if(onRoute == 1){
              fprintf(output_controller,"\ndef %s(*args, **kwargs):\n\tpass\n",$1);
            }else{
              ASSERT((NULL),"Deve ser especificado alguma rota!");
            }
            onRoute = 0;}
            |CRIE operation_banco RETURN return_declaration
            ;

function_declation : FUNC CONTROLLER  arguments
                    //|FUNC CONTROLLER IDENTIFIER{fprintf(output_controller,"\ndef %s(*args, **kwargs):\n\tpass\n",$3);} arguments
                    |FUNC MODEL IDENTIFIER{fprintf(output_model,"\ndef %s(*args, **kwargs):\n\tpass\n",$3);}
;

// Para caso se crie endpoints maiores
other_identifier : { fprintf(output_controller,"");}
                  | IDENTIFIER {fprintf(output_controller,"/%s",$1);} other_identifier
                   
;
// PARTES DO CONTROLLER 
route_declation : CRIE ROUTE SPECIAL IDENTIFIER {
              onRoute, routeSpecial = 1;
              if (asController == 1 && strcmp(idModel,"id") == 0)
                fprintf(output_controller,"\n@app.route('/%s",$4);
              else{
                ASSERT((NULL),"Problema no modelo");
              }
              
              } other_identifier {fprintf(output_controller,"/<int:%s>')",idModel);}
              | CRIE ROUTE IDENTIFIER{
                onRoute = 1;
                routeSpecial = 0;
                if(asController == 1)
                  fprintf(output_controller,"\n@app.route('/%s",$3);
                else{
                  ASSERT((NULL),"Problema no modelo");
                }
              } other_identifier{ fprintf(output_controller,"')");}
;

controller_declaration : CRIE CONTROLLER IDENTIFIER{
                          if(asController == 0 && checkImportController == 0){
                            fprintf(output_controller,"import flask\nfrom flask import render_template,redirect,url_for,request\n");
                            fprintf(output_controller,"from output_model import db, %s\n",nomeModel);
                          }
                            
                          asController = 1;
                          checkImportController = 1;
                          

};

%%

main( int argc, char *argv[] )
{
  output_model= fopen("output_model.py", "w");
  output_controller= fopen("output_controller.py", "w");

  init_stringpool(10000);
  if ( yyparse () == 0 && semerro==0 ) printf("codigo sem erros");
  //imprimi();

}

yyerror (char *s) /* Called by yyparse on error */
{
  printf ("%s  na linha %d\n", s, yylineno );
}
