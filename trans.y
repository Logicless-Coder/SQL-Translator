%{
  #include <stdio.h>
  #include <string.h>

  int yylex();
  int yyerror();
  
  #define MAX_COLS 10

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

%type<str> COLUMN TABLE VALUE LT LE GT GE EQ NE
%type<str> statement column_list condition condition_list where_clause logical_op

%%

statement: 
	SELECT column_list FROM TABLE where_clause SEMICOLON { printf("$[%s](@[%s](%s))", $2, $5, $4); }
	;

column_list: 
	ASTERISK                                { $$ = "*"; }
  | COLUMN	 								              { $$ = $1; }
	| column_list COMMA COLUMN  			      { $$ = strcat(strcat($1, ","), $3); }
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
  ;

logical_op:
  LT | LE | GT | GE | EQ | NE
  ;

%% 

int main(int argc, char** argv) {
	yyparse();
}

void add_column_to_list(char *column) {
  columns[num_columns++] = column;
}

int yyerror(char *s) {
	fprintf(stderr, "error: %s\n", s);
}
