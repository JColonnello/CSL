%{
#include <string.h>
#include <expressions.h>
#include "grammar.tab.h"
%}
%option yylineno

alpha [_A-Za-z]
digit [0-9]
alnum ({alpha}|{digit})

%x COMMENT

%%

[\n\t ]
\/\/.*\n?
<INITIAL>"/*" BEGIN(COMMENT);
<COMMENT>"*/" BEGIN(INITIAL);
<COMMENT>[^*\n]+

float				return FLOAT;
vec					return VEC;
mat					return MAT;
return				return RETURN;
void				return VOID;

\.					return DOT;
\*					return PROD;
\/					return DIV;
-					return MINUS;
\+					return PLUS;
\|\|				return DOUBLE_BARS;
max					return MAX;
min					return MIN;
=					return ASSIGN;
>					return GT;
\<					return LT;
>=					return GE;
\<=					return LE;
if					return IF;
else				return ELSE;
for					return FOR;
break				return BREAK;
\*=					return PROD_ASSIGN;
\/=					return DIV_ASSIGN;
\+=					return PLUS_ASSIGN;
-=					return MINUS_ASSIGN;
&&					return AND;

{alpha}({alpha}|{digit})*		{ yylval.str = strdup(yytext); return IDENT; }
{digit}+\.?{digit}*([eE][-+]?{digit}+)?			{ yylval.num = atof(yytext); return FLOAT_CONST; }

.					return yytext[0];

%%