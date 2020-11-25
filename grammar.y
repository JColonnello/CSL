%{
#include <stdio.h>

void yyerror (char const *s);
int yylex_destroy();
int yylex();
extern int yylineno;

int yywrap()
{
	return 1;
}

void yyerror (char const *s)
{
	fprintf (stderr, "%s at line %d\n", s, yylineno);
}

int yydebug=1;
%}
%define parse.error verbose
%locations

%union {
    char *str;
	float num;
}
%type <str> IDENT

%token FLOAT QUAT VOID
%token RETURN
%token IDENT
%token DOT PROD DIV MINUS PLUS DOUBLE_BARS MAX MIN
%token <num> FLOAT_CONST

%left MAX MIN
%left PLUS MINUS
%left PROD DIV

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
			| declaration ';'

declaration:	TYPE IDENT
				| TYPE IDENT '=' expression

expression:	member
			| function_call
			| binary_operation
			| const
const:	FLOAT_CONST
member: member DOT IDENT
		| IDENT

binary_operation:	expression	PLUS	expression
				|	expression	MINUS	expression
				|	expression	PROD	expression
				|	expression	DIV		expression
				|	expression	MAX		expression
				|	expression	MIN		expression

function_call:	IDENT params
				| DOUBLE_BARS expression DOUBLE_BARS
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