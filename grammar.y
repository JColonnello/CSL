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
%token ASSIGN PROD_ASSIGN DIV_ASSIGN PLUS_ASSIGN MINUS_ASSIGN
%token IF ELSE LT GT LE GE AND
%token <num> FLOAT_CONST

%nonassoc IF
%nonassoc ELSE

%right ASSIGN PROD_ASSIGN DIV_ASSIGN PLUS_ASSIGN MINUS_ASSIGN
%nonassoc ':'
%nonassoc '?'
%left DOUBLE_BARS
%left AND
%left LT GT LE GE
%left MAX MIN
%left PLUS MINUS
%left PROD DIV
%left FLOAT QUAT
%nonassoc LENGTH

%%

S: S translation_unit
 | /* empty */

translation_unit: function_declaration

function_declaration:	TYPE IDENT params_decl ASSIGN ret_declaration
						| TYPE IDENT params_decl ASSIGN ret_declaration block
						| VOID IDENT params_decl block

TYPE: FLOAT | QUAT

params_decl:	 '(' params_decl_c param_decl ')'
				| "()"
params_decl_c:	params_decl_c param_decl ','
			| /* empty */
param_decl: TYPE IDENT

ret_declaration:	expression
					| '[' params_c expression ']'

block:	'{' statements '}'

statements:	statements statement
			| /* empty */
statement:	expression ';'
			| ';'
			| block
			| RETURN ';'
			| declaration ';'
			| assignment ';'
			| IF '(' expression ')' statement %prec IF
			| IF '(' expression ')' statement ELSE statement
assignment:	member ASSIGN expression
			| member PROD_ASSIGN expression
			| member DIV_ASSIGN expression
			| member PLUS_ASSIGN expression
			| member MINUS_ASSIGN expression

declaration:	TYPE IDENT
				| TYPE IDENT ASSIGN expression

expression:	'(' expression ')'
			| member
			| function_call
			| unary_operation
			| binary_operation
			| ternary_operation
			| const
const:	FLOAT_CONST
member: member DOT IDENT
		| IDENT

unary_operation:	MINUS expression
				|	PLUS expression

binary_operation:	expression	PLUS	expression
				|	expression	MINUS	expression
				|	expression	PROD	expression
				|	expression	DIV		expression
				|	expression	MAX		expression
				|	expression	MIN		expression
				|	expression	LT		expression
				|	expression	GT		expression
				|	expression	LE		expression
				|	expression	GE		expression
				|	expression	DOUBLE_BARS		expression
				|	expression	AND		expression

ternary_operation: expression '?' expression ':' expression

function_call:	IDENT params
				| TYPE params
				| DOUBLE_BARS expression DOUBLE_BARS %prec LENGTH
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