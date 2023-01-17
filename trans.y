%{
  #include <stdio.h>
  #include <string.h>
  #include <stdarg.h>
  #include <stdlib.h>
  #include "color-codes.h"

  int yylex();
  int yyerror();
  
  char* concat(int, ...);

  #define MAX_COLS 10
  #define BUF_SIZE 1024

  char* columns[MAX_COLS]; 
  int num_columns = 0;
%}

%union {
	char* str;
	int num;
}

%token SELECT FROM
%token COLUMN 
%token TABLE
%token COMMA SEMICOLON ASTERISK 
%token WHERE
%token AND OR
%token LT LE GT GE EQ NE
%token VALUE
%token JOIN ON

%type<str> COLUMN TABLE VALUE LT LE GT GE EQ NE
%type<str> statement column_list condition condition_list join_clause where_clause logical_op

%%

statement: 
	SELECT column_list FROM TABLE join_clause where_clause SEMICOLON { printf(RED "$[%s]" reset, $2); printf("("); printf(GRN "@[%s]" reset, $6); printf("("); printf(BLU "%s%s" reset, $4, $5); printf("))"); }
	;

column_list: 
	ASTERISK                                { $$ = "*"; }
  | COLUMN	 								              { $$ = $1; }
	| column_list COMMA COLUMN  			      { $$ = strcat(strcat($1, ","), $3); }
	;

join_clause:
  join_clause JOIN TABLE ON condition_list            { char *buf = malloc(BUF_SIZE * sizeof(char));  $$ = concat(6, buf, $1, " X[", $5, "] ", $3); }
  | %empty                                { $$ = ""; }
  ;

where_clause:
  WHERE condition_list                    { $$ = $2; }
  | %empty                                { $$ = ""; }
  ;

condition_list:                           
  condition                               { $$ = $1; }                         
  | condition AND condition               { $$ = strcat(strcat($1, " && "), $3); }                         
  | condition OR condition                { $$ = strcat(strcat($1, " || "), $3); }                         
  ;

condition:
  COLUMN logical_op VALUE                 { $$ = strcat(strcat($1, $2), $3); }
  | COLUMN logical_op COLUMN              { $$ = strcat(strcat($1, $2), $3); }
  ;

logical_op:
  LT | LE | GT | GE | EQ | NE
  ;

%% 

int main(int argc, char** argv) {
	yyparse();
}

int yyerror(char *s) {
	fprintf(stderr, "error: %s\n", s);
}

char *concat(int cnt, ...) {
  va_list list;
  va_start(list, cnt);

  char *buf = va_arg(list, char *);

  for (int i = 1; i < cnt; ++i) {
    strcat(buf, va_arg(list, char *));
  }

  return buf;
}
