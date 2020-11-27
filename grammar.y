%{
#include <stdio.h>
#include <expressions.h>
#include <functions.h>

#define check(x) do { if(!x) \
{ yyerror("Semantic error"); YYERROR; } } while(0)

void yyerror (char const *s);
int yylex_destroy();
int yylex();
extern int yylineno;
extern FILE *yyin;

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
	Expression *expression;
	List *list;
    char *str;
	float num;
}
%type <str> IDENT
%type <expression> constructor
%type <expression> expression
%type <expression> unary_operation
%type <expression> binary_operation
%type <expression> ternary_operation
%type <expression> function_call
%type <list> params

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

function_declaration:		type IDENT '(' params_decl ')' ASSIGN ret_declaration
						|	type IDENT '(' params_decl ')' ASSIGN ret_declaration block
						|	VOID IDENT '(' params_decl ')' block;

type:	FLOAT | VEC | MAT;

params_decl:		params_decl ',' param_decl
				|	param_decl
				|	/* empty */;
param_decl:	type IDENT;

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

declaration:	type IDENT
			|	type IDENT ASSIGN expression;

expression:		unary_operation
			|	binary_operation
			|	ternary_operation;
member:			member DOT IDENT
			|	IDENT;

unary_operation:	MINUS unary_operation
						{ $$ = createOperation(OP_UMINUS, $2); }
				|	PLUS unary_operation
						{ $$ = createOperation(OP_UPLUS, $2); }
				|	'(' expression ')'
						{ $$ = createOperation(OP_PARENTHESIS, $2); }
				|	function_call
				|	DOUBLE_BARS expression DOUBLE_BARS %prec LENGTH
						{ $$ = createOperation(OP_LENGTH, $2); }
				|	unary_operation DOT IDENT
						{ $$ = createMember($1, $3); }
				|	FLOAT_CONST
						{ $$ = createFloat($1); }
				|	IDENT
						{ $$ = createSymbol($1); };


binary_operation:	expression	PLUS		expression
						{ $$ = createOperation(OP_PLUS, $1, $3); }
				|	expression	MINUS		expression
						{ $$ = createOperation(OP_MINUS, $1, $3); }
				|	expression	PROD		expression
						{ $$ = createOperation(OP_PROD, $1, $3); }
				|	expression	DIV			expression
						{ $$ = createOperation(OP_DIV, $1, $3); }
				|	expression	MAX			expression
						{ $$ = createOperation(OP_MAX, $1, $3); }
				|	expression	MIN			expression
						{ $$ = createOperation(OP_MIN, $1, $3); }
				|	expression	LT			expression
						{ $$ = createOperation(OP_LT, $1, $3); }
				|	expression	GT			expression
						{ $$ = createOperation(OP_GT, $1, $3); }
				|	expression	LE			expression
						{ $$ = createOperation(OP_LE, $1, $3); }
				|	expression	GE			expression
						{ $$ = createOperation(OP_GE, $1, $3); }
				|	expression	DOUBLE_BARS	expression
						{ $$ = createOperation(OP_DOUBLE_BARS, $1, $3); }
				|	expression	AND			expression
						{ $$ = createOperation(OP_AND, $1, $3); };

ternary_operation:	expression '?' expression ':' expression
						{ $$ = createOperation(OP_CONDITIONAL, $1, $3, $5); };

function_call:		IDENT '(' params ')'
						{ $$ = createCall($1, $3); }
				|	constructor
						{ $$ = $1; };

params:		params ',' expression
				{ List_add($1, $3);	}
		|	expression
				{ $$ = List_init(); List_add($$, $1); }
		|	/* empty */
				{ $$ = List_init(); };

constructor:		FLOAT '(' expression ')'
						{ $$ = createConstructorSingle(TYPE_FLOAT, $3); check($$); }
				|	VEC '(' params ')'
						{ $$ = createConstructor(TYPE_VECTOR, $3); check($$); }
				|	MAT '(' params ')'
						{ $$ = createConstructor(TYPE_MATRIX, $3); check($$); };

%%

void main(int argc, char *args[])
{
	if(argc > 1)
	{
		yyin = fopen(args[1], "r");
	}

	yyparse();
	yylex_destroy();
}