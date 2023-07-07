%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "sym.h"
extern int yylineno;
extern VAR *SymTab;
int semerro=0;
char nomeModel[100]; // variável para armazenar o nome do Model e ser utilizado nas funções do Controller
char idModel[100]; // identificador do model para ser utilizado nas rotas especiais
int asController = 0; // flag que verifica se já houve a criação de um controller
int onRoute = 0; // flag para verificar se houve a criação de uma rota
int routeSpecial = 0; // flag para verificar se a rota criada é uma rota especial
int checkImportModel = 0; // flag para verificar se já houve importação das bibliotecas para o model
int checkImportController; // flag para verificar se já houve importação das bibliotecas para o controller
int nulo = 0; // flag que verifica se o token NULO foi acionado

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
%token ROUTE FUNC RETURN SPECIAL UNIQUE
%token PK FK REDIRECT TEMPLATE
%token ADDBANCO DELETEBANCO UPDATEBANCO READBANCO

%type <ystr> type_specifier 

%%
/* 
 TRABALHO DA DISCIPLINA DE GRAMÁTICA E COMPILADORES - IFG(ANÁPOLIS)
 CAMILA RIBEIRO DE MORAES
 *** GERADOR DE CÓDIGO DO MICROFRAMEWORK FLASK A PARTIR DA CRIAÇÃO DE UMA GRAMÁTICA ESPECÍFICA ***
 *** GERAÇÃO DE CÓDIGOS BÁSICOS DE CRIAÇÃO DE MODELS E CONFIGURAÇÃO DOS CONTROLLERS ***

*/
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

//COMENTÁRIOS
comentario_declaration : COMENTARIO { // O COMENTÁRIO EM LINHA ÚNICA
      if (asController == 0){
        fprintf(output_model,"%s\n",$1);
      }else{
        fprintf(output_controller,"%s\n",$1);
      }
      }
      | COMMENT_BLOCK { // COMENTÁRIO EM BLOCO
        if (asController == 0){
        fprintf(output_model,"%s",$1);
        
      }else{
        fprintf(output_controller,"%s",$1);
      }
      }

      
;
//CHAVES (PK, FK)
// CHAVES -> ARGUMENTOS DE POSIÇÃO.
// UM VALOR NULO NÃO PODE ANTECEDER O VALOR DE UMA FK.
// A CRIAÇÃO DE UMA FK, JUNTO A UMA PK, DEVE ANTECEDER A MESMA.
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
// NULO
// NULLABLE -> VALORES-CHAVE (DEVE SEGUIR UMA ORDEM ESPECÍFICA DENTRO DOS ARGUMENTOS)
null : {fprintf(output_model,"");}
      |',' NULO{ nulo = 1; fprintf(output_model,", nullable = False");}
      ;

// REGRA PARA A ORDEM DE CHAVE E NULL
specciais : key null { fprintf(output_model,""); nulo = 0;}
          | null key{ fprintf(output_model,""); nulo = 0;}
          ;

//DECLARAÇÃO DE MODELO
model_declaration : CRIE MODEL IDENTIFIER {
                        asController = 0;
                        //ORGANIZAÇÃO DOS IMPORTS BÁSICOS JÁ SE ENCONTRA NA CRIAÇÃO DO MODELO
                        if(checkImportModel == 0){
                          fprintf(output_model,"import sqlalchemy as sa\n");
                          fprintf(output_model,"from flask_sqlalchemy import SQLAlchemy\n");
                          fprintf(output_model,"\ndb = SQLAlchemy()\n");
                          strcpy(nomeModel,$3);
                        }
                        checkImportModel = 1;
                        // CASO JÁ TENHA TIDO ALGUM OUTRO MODELO CRIADO E DESEJA-SE CRIAR OUTRO,
                        // NÃO HÁ A NECESSIDADE DE FAZER OS IMPORTS NOVAMENTE.
                        fprintf(output_model,"\nclass %s (db.Model):\n",$3);
                    }
                  ;

unico : { fprintf(output_model,")\n");}
      | '*' UNIQUE {fprintf(output_model,", unique=True)\n");}
;
//DECLARAÇÃO DE CAMPOS DO MODEL
field_declaration : CRIE CAMPO IDENTIFIER ':' type_specifier {
                          // A CRIAÇÃO DOS CAMPOS DE UM MODEL SÓ PODEM SER FEITAS 
                          // AO SE CRIAR O PRÓPRIO MODELO
                          if (asController == 0){
                              fprintf(output_model,"\t%s = sa.Column(sa.%s",$3,$5);
                              AddVAR($3,$5);
                          }
                          if (strcmp($3,"id") == 0){
                            strcpy(idModel,$3);
                          }
                          } specciais unico 
;

// ESPECIFICAÇÃO DOS TIPOS DOS CAMPOS
type_specifier : STRING {$$="String(200)";}
                |INTEGER {$$="Integer";}
                |FLOAT {$$="Float";}
                |DATE {$$="Date";}
                |BOOL {$$="Boolean";}
                |TEXT {$$="Text";}
                ;

// DECLARAÇÃO DO RELACIONAMENTO DE UM MODEL
relation_declaration: CRIE RELACAO IDENTIFIER ':' IDENTIFIER{
                if (asController == 0){
                  fprintf(output_model,"\t%s = db.relanshionship('%s')\n",$3,$5);
                }
}; 

// OPERAÇÕES BÁSICAS PELO BANCO DE DADOS
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
                    // AS ROTAS ESPECIAIS SÃO AQUELAS QUE NECESSITAM DE ALGUM VALOR CHAVE
                    // PROVENIENTE DO MODEL.
                    if(routeSpecial == 1)
                      fprintf(output_controller,"\ndef %s(%s):\n\t",$2,idModel);
                    else
                      ASSERT((NULL),"ROTA NÃO DEFINIDA ADEQUADAMENTE");
                    fprintf(output_controller,"_ex = %s.query.get(%s)\n",nomeModel,idModel);
                    fprintf(output_controller,"\tdb.session.delete(_ex)\n");
                    fprintf(output_controller,"\tdb.session.commit()");
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
                   fprintf(output_controller,"\t\t_ex._ex2 = request.form['__ex2']\n\t\tdb.session()");
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
                  fprintf(output_controller,"\t_ex = %s.query.all(%s)",nomeModel,idModel);
                  }else{
                      ASSERT((NULL),"ROTA NÃO FOI DEFINIDA");
                    }
                    routeSpecial = 0;
                 }
                 ;

// RETORNOS DAS FUNÇÕES DO CONTROLLER
// BASICAMENTE SE PODE RETORNAR ALGUM TEMPLATE (HTML, JINJA) APÓS A EXECUÇÃO DE ALGUMA FUNÇÃO DO CONTROLLER
// E E REALIZAR UM REDIRECT, QUE REDIRECIONA A PÁGINA PARA ALGUMA ROTA EM ESPECÍFICO
return_declaration :  TEMPLATE {fprintf(output_controller,"\n\treturn render_template()\n");}
                    | REDIRECT {fprintf(output_controller,"\n\treturn redirect(url_for(__))\n");}

arguments : IDENTIFIER{
            if(asController == 1){
              if(onRoute == 1){
              fprintf(output_controller,"\ndef %s(*args, **kwargs):\n\tpass\n",$1);
            }else{
              ASSERT((NULL),"Deve ser especificado alguma rota!");
            }
            }else{
              ASSERT((NULL),"O controller não foi iniciado!");
            }
            
            }
            |CRIE operation_banco RETURN return_declaration
            ;

// DECLARAÇÃO DE FUNÇÃO -> DIFERENCIÁVEL DE MODEL E CONTROLLER
// AMBAS AS ESTRUTURAS NECESSITAM DE SUAS PRÓPRIAS REGRAS
function_declation : FUNC CONTROLLER  arguments{onRoute = 0;}
                    |FUNC MODEL IDENTIFIER{fprintf(output_model,"\ndef %s(*args, **kwargs):\n\tpass\n",$3);}
;

// CRIAÇÃO DE ENDPOINTS MAIORES
other_identifier : { fprintf(output_controller,"");}
                  | IDENTIFIER {fprintf(output_controller,"/%s",$1);} other_identifier
                   
;
// PARTES DO CONTROLLER  -> CRIAÇÃO DE ROTAS É OBRIGATÓRIO
route_declation : CRIE ROUTE SPECIAL IDENTIFIER {
              onRoute=1;
              routeSpecial = 1;
              if (asController == 1 && strcmp(idModel,"id") == 0)
                fprintf(output_controller,"\n@app.route('/%s",$4);
              else{
                ASSERT((NULL),"Problema no modelo");
              }
              // TAMBÉM É POSSÍVEL REALIZAR A ADIÇÃO NA ROTA, DO IDENTIFICADOR NECESSÁRIO NO 
              // CONTROLLER, PROVENIENTE DO MODEL.
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

// DECLARAÇÃO DO CONTROLLER
// CRIAÇÃO DO CONTROLLER VEM COM AS IMPORTAÇÕES MÍNIMAS NECESSÁRIAS
// TAMBÉM HÁ UMA CHECAGEM CASO JÁ SE TENHA IMPORTADO ANTES.
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
  // um arquivo separado para model e outro para controller
  output_model= fopen("output_model.py", "w"); 
  output_controller= fopen("output_controller.py", "w");

  init_stringpool(10000);
  if ( yyparse () == 0 && semerro==0 ) printf("CÓDIGO SEM ERROS\n");
  //imprimi();

}

yyerror (char *s) /* Called by yyparse on error */
{
  printf ("%s  na linha %d\n", s, yylineno );
}
