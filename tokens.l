%{
#include "grammar.tab.h"
%}

alpha [A-Za-z]
digit [0-9]
alnum {alpha}|{digit}

%%
{alnum}+		{yylval.str = strdup(yytext); return IDENT;}
[\t\n\ ]
.				return yytext[0];
%%