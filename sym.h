/* (Simple) Symbol Table Definitions */
#pragma once
char *stringpool(char *);
void init_stringpool(int);
#define NEW(type) (type *) calloc(1,sizeof(type))

typedef struct VAR {
	char *name;
	char *type;
	struct VAR *next;
	} VAR;

VAR *MakeVAR(char *, char *, VAR *);
void imprimi();




