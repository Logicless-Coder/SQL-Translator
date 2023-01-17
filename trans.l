%option noyywrap

%{
  #include "trans.tab.h"  

  int seen_from = 0;
  int seen_where = 0;
  int seen_on = 0;
  int seen_logical_op = 0;
%}

word        ([a-zA-Z_])([a-zA-Z0-9_])+
string      \"{word}\"
number      [0-9]+


%%

"select"               { return SELECT; }
"from"                 { seen_from = 1; return FROM; }
"where"                { seen_where = 1; return WHERE; }
"and"                  { seen_logical_op = 0; return AND; }
"or"                   { seen_logical_op = 0; return OR; }
"join"                 { return JOIN; }
"on"                   { seen_on = 1; return ON; }

{word}                 { yylval.str = strdup(yytext); return (seen_where || seen_on) ? COLUMN : seen_from ? TABLE : COLUMN; }
{string}               { yylval.str = strdup(yytext); return VALUE; }
{number}               { yylval.str = strdup(yytext); return VALUE; }

";"                    { seen_from = 0; return SEMICOLON; }
","                    { return COMMA; }
"*"                    { return ASTERISK; }

"<"                    { seen_logical_op = 1; yylval.str = strdup(yytext); return LT; }
"<="                   { seen_logical_op = 1; yylval.str = strdup(yytext); return LE; }
">"                    { seen_logical_op = 1; yylval.str = strdup(yytext); return GT; }
">="                   { seen_logical_op = 1; yylval.str = strdup(yytext); return GE; }
"="                    { seen_logical_op = 1; yylval.str = strdup(yytext); return EQ; }
"!="                   { seen_logical_op = 1; yylval.str = strdup(yytext); return NE; }

[ \t]                  { }

.                      { printf("Mystery character %c\n", yytext); }

%%
