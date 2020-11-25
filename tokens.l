%{
#include "grammar.tab.h"
%}

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
{alnum}+		{yylval.str = strdup(yytext); return IDENT;}
[\t\n\ ]
.				return yytext[0];

{alpha}({alpha}|{digit})*		{ yylval.str = strdup(yytext); return IDENT; }
.					return yytext[0];

%%