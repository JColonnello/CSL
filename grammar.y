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

%token FLOAT VEC MAT VOID
%token RETURN
%token IDENT
%token DOT PROD DIV MINUS PLUS DOUBLE_BARS MAX MIN
%token ASSIGN PROD_ASSIGN DIV_ASSIGN PLUS_ASSIGN MINUS_ASSIGN
%token FOR IF ELSE BREAK LT GT LE GE AND
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
%nonassoc FLOAT VEC MAT
%nonassoc LENGTH
%left DOT

%%

S:		S translation_unit
 	|	/* empty */;

translation_unit:	function_declaration;

function_declaration:		TYPE IDENT '(' params_decl ')' ASSIGN ret_declaration
						|	TYPE IDENT '(' params_decl ')' ASSIGN ret_declaration block
						|	VOID IDENT '(' params_decl ')' block;

TYPE:	FLOAT | VEC | MAT;

params_decl:		params_decl ',' param_decl
				|	param_decl
				|	/* empty */;
param_decl:	TYPE IDENT;

ret_declaration:		expression
					|	'['  param_decl ']'
					|	'['  params_decl ',' param_decl ']';

block:	'{' statements '}';

simple_statement:		';'
					|	RETURN ';'
					|	declaration ';'
					|	assignment ';';
statements:		statements statement
			|	/* empty */;
statement:		simple_statement
			|	block
			|	IF '(' expression ')' statement %prec IF
			|	IF '(' expression ')' statement ELSE statement
			|	FOR '(' declaration ';' expression ';' assignment ')' statement_break;

statement_break:		simple_statement
					|	block_break
					|	IF '(' expression ')' statement_break %prec IF
					|	IF '(' expression ')' statement_break ELSE statement_break
					|	FOR '(' declaration ';' expression ';' assignment ')' statement_break
					|	BREAK ';';
block_break:	'{' statements_break '}';
statements_break:		statements_break statement_break
					|	/* empty */;

assignment:		member ASSIGN expression
			|	member PROD_ASSIGN expression
			|	member DIV_ASSIGN expression
			|	member PLUS_ASSIGN expression
			|	member MINUS_ASSIGN expression;

declaration:	TYPE IDENT
			|	TYPE IDENT ASSIGN expression;

expression:		unary_operation
			|	binary_operation
			|	ternary_operation;
member:			member DOT IDENT
			|	IDENT;

unary_operation:	MINUS unary_operation
				|	PLUS unary_operation
				|	'(' expression ')'
				|	function_call
				|	unary_operation DOT member
				|	FLOAT_CONST
				|	IDENT;


binary_operation:	expression	PLUS		expression
				|	expression	MINUS		expression
				|	expression	PROD		expression
				|	expression	DIV			expression
				|	expression	MAX			expression
				|	expression	MIN			expression
				|	expression	LT			expression
				|	expression	GT			expression
				|	expression	LE			expression
				|	expression	GE			expression
				|	expression	DOUBLE_BARS	expression
				|	expression	AND			expression;

ternary_operation:	expression '?' expression ':' expression;

function_call:		IDENT '(' params ')'
				|	constructor
				|	DOUBLE_BARS expression DOUBLE_BARS %prec LENGTH;
params:		params ',' expression
		|	expression
		|	/* empty */;
constructor:		FLOAT '(' expression ')'
				|	VEC '(' params ')'
				|	MAT '(' params ')';

%%

void main()
{
	yyparse();
	yylex_destroy();
}