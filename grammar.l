%{
#include "grammar.tab.h"
%}
%option yylineno

alpha [_A-Za-z]
digit [0-9]
alnum ({alpha}|{digit})

%x COMMENT

%%

[\n\t ]
\/\/.*\n
<INITIAL>"/*" BEGIN(COMMENT);
<COMMENT>"*/" BEGIN(INITIAL);
<COMMENT>[^*\n]+ { }

float				return FLOAT;
quat				return QUAT;
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

{alpha}({alpha}|{digit})*		{ yylval.str = strdup(yytext); return IDENT; }
{digit}+\.{digit}+				{ yylval.num = atof(yytext); return FLOAT_CONST; }

.					return yytext[0];

%%