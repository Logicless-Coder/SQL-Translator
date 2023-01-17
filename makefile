trans: trans.l trans.y
	bison -d trans.y
	flex trans.l
	gcc -o $@ trans.tab.c lex.yy.c 
