%option case-insensitive

%{
#include "calc.tab.h"
%}

%%

"+" { return ADD; }
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
[0-9]+ { yylval = atoi(yytext); return NUMBER; }
\n { return EOL; }
[ \t] { /* ignore whitespace */ }
"(" { return OP; }
")" { return CP; }
"//".* { /* ignore comments */ }
"a" { printf("> %c\n", *yytext); }
. { printf("INVALID CHAR: %c\n", *yytext); }
%%