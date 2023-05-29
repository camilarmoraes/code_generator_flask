%{
#include "parser.tab.h"
%}
%option yylineno

DIGIT    [0-9]
ID       [a-z][a-z0-9]*

%%

":="     { printf("Atribuição "); return(ASSGNOP);  }
{DIGIT}+ { printf("NUMERO");return(NUMBER);   }
[-+]?{DIGIT}*"."{DIGIT}+ { printf("Real");return(NUMBER);   }
do       { printf("do "); return(DO);       }
else     { printf("else "); return(ELSE);     }
end      { return(END);      }
fi       { return(FI);       }
if       { return(IF);       }
in       { return(IN);       }
integer  { printf("tipo "); return(INTEGER);  }
let      { printf("let "); return(LET);      }
read     { return(READ);     }
skip     { return(SKIP);     }
then     { return(THEN);     }
while    { return(WHILE);    }
write    { return(WRITE);    }
{ID}     { printf("Identificador ");return(IDENTIFIER); }
"//"[A-Za-z0-9_ ]* {printf("Comentário"); }
[ \t]+ /* blank, tab, new line: eat up whitespace */
.        { printf("%c",yytext[0]); return(yytext[0]); }

%%


