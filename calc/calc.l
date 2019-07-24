%{
#include "calc.tab.h"
%}

%%

"+" { return ADD; }
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
[0-9]+ { yylval = atoi(yytext); return NUMBER; }
[ \t] { /* ignore whitespace */ }
. { printf("INVALID CHAR: %c\n", *yytext); }
%%