%{
#include <stdio.h>
#include <expressions.h>
#include <functions.h>
#include <member.h>
#include <statement.h>

#define check(x) do { if(!x) \
{ yyerror(NULL, "Semantic error"); YYERROR; } } while(0)

void yyerror (List **tree, char const *s);
int yylex_destroy();
int yylex();
extern int yylineno;
extern FILE *yyin, *yyout;

int yywrap()
{
	return 1;
}

void yyerror (List **tree, char const *s)
{
	fprintf (stderr, "%s at line %d\n", s, yylineno);
}

int yydebug=1;
%}
%define parse.error verbose
%locations
%parse-param { List **translations }

%union {
	Expression *expression;
	AssignmentTarget *lvalue;
	Statement *statement;
	List *list;
    char *str;
	float num;
	enum DataType type;
	FunctionDefinition *function;
	ParameterDeclaration *parameter;
}
%type <str> IDENT
%type <expression> constructor
%type <expression> expression
%type <expression> unary_operation
%type <expression> binary_operation
%type <expression> ternary_operation
%type <expression> function_call
%type <lvalue> member
%type <list> params
%type <statement> assignment
%type <statement> declaration
%type <statement> block
%type <statement> block_break
%type <statement> simple_statement
%type <statement> statement
%type <statement> statement_break
%type <list> statements
%type <list> statements_break
%type <type> type
%type <function> function_declaration
%type <list> params_decl
%type <parameter> param_decl
%type <expression> ret_declaration
%type <function> translation_unit
%type <list> S

%token FLOAT VEC MAT VOID
%token RETURN
%token IDENT
%token DOT PROD DIV MINUS PLUS DOUBLE_BARS MAX MIN
%token ASSIGN PROD_ASSIGN DIV_ASSIGN PLUS_ASSIGN MINUS_ASSIGN
%token FOR IF ELSE BREAK LT GT LE GE EQ NE AND
%token <num> FLOAT_CONST

%nonassoc IF
%nonassoc ELSE

%right ASSIGN PROD_ASSIGN DIV_ASSIGN PLUS_ASSIGN MINUS_ASSIGN
%nonassoc ':'
%nonassoc '?'
%left DOUBLE_BARS
%left AND
%left LT GT LE GE
%left PLUS MINUS
%left PROD DIV
%left MAX MIN
%nonassoc FLOAT VEC MAT
%nonassoc LENGTH
%left DOT

%%

S:		S translation_unit
			{ List_add($1, $2); }
 	|	/* empty */
	 		{ $$ = List_init(); *translations = $$; }
	;

translation_unit:	function_declaration;

function_declaration:		type IDENT '(' params_decl ')' ASSIGN ret_declaration
								{ $$ = createFunctionDecl($1, $2, $4, $7, NULL); }
						|	type IDENT '(' params_decl ')' ASSIGN ret_declaration block
								{ $$ = createFunctionDecl($1, $2, $4, $7, $8); }
						|	VOID IDENT '(' params_decl ')' block
								{ $$ = createFunctionDecl(TYPE_NONE, $2, $4, NULL, $6); }
						;

type:		FLOAT
				{ $$ = TYPE_FLOAT; }
		|	VEC
				{ $$ = TYPE_VECTOR; }
		|	MAT
				{ $$ = TYPE_MATRIX; }
		;

params_decl:		params_decl ',' param_decl
						{ List_add($1, $3);	}
				|	param_decl
						{ $$ = List_init(); List_add($$, $1); }
				|	/* empty */
						{ $$ = List_init(); }
				;
param_decl:	type IDENT
				{ $$ = createParamDecl($1, $2); }
			;

ret_declaration:		expression
					// |	'['  param_decl ']'
					// |	'['  params_decl ',' param_decl ']'
				;

block:	'{' statements '}'
			{ $$ = createBlock($2); }
		;

simple_statement:		RETURN ';'
							{ $$ = createSimple(ST_RET); }
					|	declaration ';'
					|	assignment ';'
					;
statements:		statements statement
					{ List_add($1, $2); }
			|	/* empty */
					{ $$ = List_init(); }
			;
statement:		simple_statement
			|	block
			|	IF '(' expression ')' statement %prec IF
					{ $$ = createIf($3, $5, NULL); }
			|	IF '(' expression ')' statement ELSE statement
					{ $$ = createIf($3, $5, $7); }
			|	FOR '(' declaration ';' expression ';' assignment ')' statement_break
					{ $$ = createFor($3, $5, $7, $9); }
			;

statement_break:		simple_statement
					|	block_break
					|	IF '(' expression ')' statement_break %prec IF
							{ $$ = createIf($3, $5, NULL); }
					|	IF '(' expression ')' statement_break ELSE statement_break
							{ $$ = createIf($3, $5, $7); }
					|	FOR '(' declaration ';' expression ';' assignment ')' statement_break
							{ $$ = createFor($3, $5, $7, $9); }
					|	BREAK ';'
							{ $$ = createSimple(ST_BREAK); }
					;
block_break:	'{' statements_break '}'
					{ $$ = createBlock($2); }
				;
statements_break:		statements_break statement_break
							{ List_add($1, $2); }
					|	/* empty */
							{ $$ = List_init(); }
					;

assignment:		member ASSIGN expression
					{ $$ = createAssignment($1, $3, OP_NONE); }
			|	member PROD_ASSIGN expression
					{ $$ = createAssignment($1, $3, OP_PROD); }
			|	member DIV_ASSIGN expression
					{ $$ = createAssignment($1, $3, OP_DIV); }
			|	member PLUS_ASSIGN expression
					{ $$ = createAssignment($1, $3, OP_PLUS); }
			|	member MINUS_ASSIGN expression
					{ $$ = createAssignment($1, $3, OP_MINUS); }
			;
member:			IDENT DOT IDENT
					{ $$ = createAssignmentLValue($1, $3); }
			|	IDENT
					{ $$ = createAssignmentLValue($1, NULL); }
			;

declaration:	type IDENT
					{ $$ = createDeclaration($1, $2, NULL); }
			|	type IDENT ASSIGN expression
					{ $$ = createDeclaration($1, $2, $4); }
			;

expression:		unary_operation
			|	binary_operation
			|	ternary_operation;

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
						{ $$ = createSymbol($1); }
				;


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
				|	expression	EQ			expression
						{ $$ = createOperation(OP_EQ, $1, $3); }
				|	expression	NE			expression
						{ $$ = createOperation(OP_NE, $1, $3); }
				|	expression	DOUBLE_BARS	expression
						{ $$ = createOperation(OP_DOUBLE_BARS, $1, $3); }
				|	expression	AND			expression
						{ $$ = createOperation(OP_AND, $1, $3); }
				;

ternary_operation:	expression '?' expression ':' expression
						{ $$ = createOperation(OP_CONDITIONAL, $1, $3, $5); }
					;

function_call:		IDENT '(' params ')'
						{ $$ = createCall($1, $3); }
				|	constructor
				;

params:		params ',' expression
				{ List_add($1, $3);	}
		|	expression
				{ $$ = List_init(); List_add($$, $1); }
		|	/* empty */
				{ $$ = List_init(); }
		;

constructor:		FLOAT '(' expression ')'
						{ $$ = createConstructorSingle(TYPE_FLOAT, $3); check($$); }
				|	VEC '(' params ')'
						{ $$ = createConstructor(TYPE_VECTOR, $3); check($$); }
				|	MAT '(' params ')'
						{ $$ = createConstructor(TYPE_MATRIX, $3); check($$); }
				;

%%

void main(int argc, char *args[])
{
	if(argc > 1)
	{
		yyin = fopen(args[1], "r");
	}
	if(argc > 2)
	{
		freopen(args[2], "w", stdout);
	}

	List *translations;
	yyparse(&translations);
	yylex_destroy();
	generateOutput(translations);
}