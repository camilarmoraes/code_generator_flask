/* (Simple) Symbol Table Definitions */
#pragma once
char *stringpool(char *);
void init_stringpool(int);
#define NEW(type) (type *) calloc(1,sizeof(type))

typedef struct VAR {
	char *name;
	int type;
	int scope;
	struct VAR *next;
	} VAR;

VAR *MakeVAR(char *, int, VAR *);
VAR *FindVAR(char *);



