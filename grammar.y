%{
#include <stdio.h>

void yyerror (char const *s);
int yylex_destroy();
int yylex();

int yywrap()
{
	return 1;
}

void yyerror (char const *s)
{
	fprintf (stderr, "%s\n", s);
}
%}

%union {
    char *str;
}
%type <str> IDENT
%token IDENT
%define parse.error verbose

%%

S: S WORD
 | /* empty */

WORD: IDENT
{
	printf("Word: %s\n", $1);
	free($1);
}

%%

void main()
{
	yyparse();
	yylex_destroy();
}