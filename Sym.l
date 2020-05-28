%{
	#define YYSTYPE char*
	#include "y.tab.h"
    #include <stdio.h>
    extern void yyerror(const char *);
    int line = 0;

%}


D   		[0-9]
E			[Ee][+-]?{D}+
L   		[a-zA-Z_]
A   		[a-zA-Z_0-9]
WS  		[ \t\v\f]

%%


[\n]				{line++;}
"int"				{yylval = strdup(yytext);return T_INT;} 
main				{yylval = strdup(yytext);return T_MAIN;}
"include"			{yylval = strdup(yytext);return T_INCLUDE;} 
"#"					{yylval = strdup(yytext);return T_HASH;}
"void"				{yylval = strdup(yytext);return T_VOID;} 
"char"				{yylval = strdup(yytext);return T_CHAR;} 
"float"				{yylval = strdup(yytext);return T_FLOAT;}
"case"				{yylval = strdup(yytext);return T_CASE;} 
"default"			{yylval = strdup(yytext);return T_DEFAULT;} 
"switch"			{yylval = strdup(yytext);return T_SWITCH;} 
"for"				{yylval = strdup(yytext);return T_FOR;} 
"continue"			{yylval = strdup(yytext);return T_CONTINUE;} 
"break"				{yylval = strdup(yytext);return T_BREAK;} 
"return"			{yylval = strdup(yytext);return T_RETURN;}

 
"||"				{return T_OR_OP;} 
"&&"				{return T_AND_OP;} 
"=="				{return T_EQ_OP;} 
"!="				{return T_NE_OP;} 
"<="				{return T_LE_OP;} 
">="				{return T_GE_OP;} 
"++"				{return T_INC_OP;} 
"--"				{return T_DEC_OP;}
"+="				{return T_ADD_ASSIGN;} 
"-="				{return T_SUB_ASSIGN;}


"stdio.h"			{return T_STDIO;} 
"stdlib.h" 			{return T_STDLIB;} 
"math.h"			{return T_MATH;} 
"string.h"			{return T_STRING;} 
"time.h"			{return T_TIME;} 

{L}{A}*				{yylval = strdup(yytext);return T_IDENTIFIER;}




	
";"			{return (';');}
"{"			{return('{'); }
"}"			{return('}'); }
","			{return(','); }
":"			{return(':'); }
"="			{return('='); }
"("			{return('('); }
")"			{return(')'); }
"["			{return('['); }
"]"			{return(']'); }
"-"			{return('-'); }
"+"			{return('+'); }
"*"			{return('*'); }
"/"			{return('/'); }
"%"			{return('%'); }
"<"			{return('<'); }
">"			{return('>'); }
"^"			{return('^'); }
"|"			{return('|'); }
"?"			{return('?'); }


\"{A}+(".h"|".c")\"	{yylval = strdup(yytext);return T_HEADER_LITERAL;}
{D}+				{yylval = strdup(yytext);return T_INTEGER_LITERAL;} 
{D}+\.{D}+			{yylval = strdup(yytext);return T_FLOAT_LITERAL;} 
\"(\\.|[^\\"])*\"	{yylval = strdup(yytext);return T_STRING_LITERAL;} 


\/\/[^\n]*			{}
"/*"([^*]|\*+[^*/])*\*+"/" 	{};	

{WS}+				{}

.					{ printf("--------------------\n");
					printf("ERROR\n");
					printf("--------------------\n");
						printf("Invalid Expression %s at Line number %d\n", yytext, yylineno); }

%%
