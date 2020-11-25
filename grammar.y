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

int yydebug=1;
%}

%union {
    char *str;
}
%type <str> IDENT

%token FLOAT QUAT VOID
%token RETURN
%token IDENT
%define parse.error verbose

%%

S: S translation_unit
 | /* empty */

translation_unit: function_declaration

function_declaration:	TYPE IDENT params_decl '=' ret_declaration
						| TYPE IDENT params_decl '=' ret_declaration block
						| VOID IDENT params_decl block

TYPE: FLOAT | QUAT

params_decl:	 '(' params_decl_c param_decl ')'
				| "()"
params_decl_c:	params_decl_c param_decl ','
			| /* empty */
param_decl: TYPE IDENT

ret_declaration:	expression
					| params

block:	'{' statements '}'

statements:	statements statement
			| /* empty */
statement:	expression ';'
			| ';'
			| block
			| RETURN expression ';'
expression:	IDENT
			| function_call

function_call:	IDENT params
params:	'(' params_c expression ')'
		| '(' ')'

params_c:	params_c expression ','
			| /* empty */

%%

void main()
{
	yyparse();
	yylex_destroy();
}