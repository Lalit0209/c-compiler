%{
	#include <stdio.h>
	#include <string.h>
	void yyerror(const char *);
	#include<stdlib.h>
	#define YYSTYPE char*
	FILE *yyin;
	int yylex();
	extern int line;
	int i;
	int tempc = 1;
	int labelc = 1;
	int stack1[100];
	int stack2[100];
	char switch_stack[100][100];
	int top1 = 0;
	int top2 = 0;
	int stop = 0;
	char* newTemp();
	char* newLabel();
	FILE *icg;

%}



%error-verbose


%left '*'
	

%token T_INT T_MAIN T_HASH T_INCLUDE T_IDENTIFIER T_HEADER_LITERAL T_STDIO T_STDLIB T_MATH T_STRING T_TIME T_VOID T_CHAR T_FLOAT T_OR_OP T_AND_OP	T_EQ_OP T_NE_OP T_LE_OP T_GE_OP T_INC_OP T_DEC_OP T_INTEGER_LITERAL T_FLOAT_LITERAL T_STRING_LITERAL T_CASE T_DEFAULT T_SWITCH T_FOR T_CONTINUE T_BREAK T_RETURN T_ADD_ASSIGN T_SUB_ASSIGN
%%

start:
	|{fprintf(icg,"start\n");} translation_unit {fprintf(icg,"end\n");}
translation_unit 
	: external_declaration 
	| translation_unit external_declaration 
	;

external_declaration
	: T_INT T_MAIN '(' ')' compound_statement 
	| declaration  
	| headers  
	;

headers
	: T_HASH T_INCLUDE T_HEADER_LITERAL 
	| T_HASH T_INCLUDE '<' libraries '>' 
	;

libraries
	: T_STDIO 
	| T_STDLIB 
	| T_MATH 
	| T_STRING 
	| T_TIME 
	;

declaration
	: type_specifier ';' 
	| type_specifier init_declarator_list ';' 
	;

type_specifier
	: T_VOID 
	| T_CHAR 
	| T_INT 
	| T_FLOAT 
	;



init_declarator_list
	: init_declarator 
	| init_declarator_list ',' init_declarator 
	;

init_declarator
	: declarator '=' conditional_expression {fprintf(icg,"%s = %s\n",$1,$3);}
	| declarator 
	;

declarator
	: T_IDENTIFIER

 											
 	| declarator '['conditional_expression']' {char x[100];
 											strcpy(x,$1);
 											strcat(x,"[");
 											strcat(x,$3);
 											strcat(x,"]");
 											strcpy($$,x);
 											}
	;

conditional_expression
	: logical_or_expression 
 	| logical_or_expression '?' expression ':' conditional_expression {char x[10];
 																		strcpy(x,newTemp());
 																		strcpy($$,x);
 																		fprintf(icg,"ifFalse t%d goto L%d\n",tempc-2,labelc);
 																		fprintf(icg,"%s = %s\n",x,$3);
 																		fprintf(icg,"Goto L%d\n",labelc+1);
 																		fprintf(icg,"L%d:\n",labelc);
 																		fprintf(icg,"%s = %s\n",x,$5);
 																		fprintf(icg,"L%d:\n",labelc+1);

 																		
 	}
 	;

logical_or_expression
 	: logical_and_expression 
 	| logical_or_expression T_OR_OP logical_and_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s || %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
	;

logical_and_expression
 	: equality_expression 
 	| logical_and_expression T_AND_OP equality_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s && %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
	; 

equality_expression
 	: relational_expression 
 	| equality_expression T_EQ_OP relational_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s == %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	| equality_expression T_NE_OP relational_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s != %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	;

relational_expression
 	: additive_expression 
 	| relational_expression '<' additive_expression {		
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s < %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	| relational_expression '>' additive_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s > %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	| relational_expression T_LE_OP additive_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s <= %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	| relational_expression T_GE_OP additive_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s >= %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	;


additive_expression
 	: multiplicative_expression 
 	| additive_expression '+' multiplicative_expression 
 														{
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s + %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	| additive_expression '-' multiplicative_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s - %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	;

multiplicative_expression
 	: unary_expression 
 	| multiplicative_expression '*' unary_expression {		
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s * %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	| multiplicative_expression '/' unary_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s / %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	| multiplicative_expression '%' unary_expression {
 															char x[10];
 															strcpy(x,newTemp());
 															fprintf(icg,"%s = %s mod %s\n",x,$1,$3);
 															strcpy($$,x);
 														}
 	;

unary_expression
 	: postfix_expression 
 	| T_INC_OP unary_expression 
 	| T_DEC_OP unary_expression 
 	;

postfix_expression
 	: primary_expression 
	| postfix_expression T_INC_OP 
 	| postfix_expression T_DEC_OP 
 	| postfix_expression '[' T_INTEGER_LITERAL ']' {char x[100];
 											strcpy(x,$1);
 											strcat(x,"[");
 											strcat(x,$3);
 											strcat(x,"]");
 											strcpy($$,x);
 											}
	; 

primary_expression
	: T_IDENTIFIER 		
	| T_INTEGER_LITERAL
	| T_FLOAT_LITERAL 	
	| T_STRING_LITERAL 	
	| '(' expression ')' {strcpy($$,$2);}
	;


statement
 	: labeled_statement 
 	| compound_statement 
 	| expression_statement 
 	| selection_statement 
 	| iteration_statement 
 	| jump_statement 
 	;

labeled_statement
 	: T_CASE conditional_expression {	

 										fprintf(icg,"%s == %s\n",switch_stack[stop-1],$2);
 										fprintf(icg,"ifFalse %s goto L%d:\n",switch_stack[stop-1],labelc);
 										stack1[top1] = labelc;
 										labelc++;
 										
 										top1++;
 									} ':' statement 
 									{
 										fprintf(icg,"L%d:\n",stack1[--top1]);
 									}
 	| T_DEFAULT ':' statement 		{
 										stop--;
 										fprintf(icg,"L%d:\n",stack2[--top2]);
 									}
;

compound_statement
: '{' '}' 
| '{' block_item_list '}' 
;

block_item_list
	: block_item 
	| block_item_list block_item 
	;
block_item
	: declaration 
	| statement 
	;
expression_statement
 	: ';' 
 	| expression ';' 
 	;

 selection_statement
 	: T_SWITCH '(' expression {strcpy(switch_stack[stop],$3);stop++;}')'{stack2[top2] = labelc;
 																	labelc++;
 																	top2++;} statement 

 	;

 iteration_statement
 	: T_FOR '(' expression_statement A expression_statement B expression ')' statement C 
	| T_FOR '(' declaration A expression_statement B expression ')' statement C  
 	;

 A
 	:{stack1[top1] = labelc;
	top1++;
	fprintf(icg,"L%d:\n",labelc);
	labelc++;} 
 	; 

B
	:{	
		stack2[top2] = labelc;
		labelc++;
		fprintf(icg,"ifFalse t%d goto L%d\n",tempc-1,stack2[top2]);
		
		top2++;
	}
	;

C
	:{fprintf(icg,"Goto L%d\n",stack1[--top1]);
		fprintf(icg,"L%d:\n",stack2[--top2]);}
	;

 jump_statement
	: T_CONTINUE ';' {fprintf(icg,"Goto L%d\n",stack1[top1-1] );}
	| T_BREAK ';' {fprintf(icg,"Goto L%d\n",stack2[top2-1]);}
 	| T_RETURN ';' {fprintf(icg,"Goto end\n");}
 	| T_RETURN expression ';' {fprintf(icg,"Goto end\n");}
	;

expression
	: assignment_expression 
	| expression ',' assignment_expression 
	;

assignment_expression
	: conditional_expression 
	| unary_expression '=' assignment_expression {fprintf(icg,"%s = %s\n",$1,$3);}
	| unary_expression T_ADD_ASSIGN assignment_expression 
	| unary_expression T_SUB_ASSIGN assignment_expression 
	;
%%

int main()
{
icg = fopen("icg.txt", "w");
yyin = fopen("test.c","r");
if(!yyparse()){

	printf("\n-----------------------------------\n");
	printf("Parsing succesful\nCheck icg.txt for Intermediate Code\n");
	printf("-----------------------------------\n\n");
	}


return 0;

}
void yyerror(const char *msg)
{
 	printf("\n");
  	printf("------\n");
	printf("ERROR\n");
	printf("------\n");
	printf("Parsing Unsuccesful\n");
	printf("Syntax Error at line %d\n\n",line);

}

char* newTemp()
{
	char* x;
	x = (char*)malloc(sizeof(char)*20);
	strcpy(x,"t");
	char j[20];
	snprintf(j,20*sizeof(char),"%d",tempc);
	strcat(x,j);
	tempc++;
	return x;
}

