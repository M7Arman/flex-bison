%{

%}

%%
"colour" { printf("color"); }
"flavour" { printf("flavor"); }
. { printf("%s", yytext); }
%%


int main() {
    yylex();
}