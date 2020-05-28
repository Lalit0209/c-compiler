%{
	#include <stdio.h>
	#include <string.h>
	void yyerror(const char *);
	#include<stdlib.h>
	#define YYSTYPE char*
	FILE *yyin;
	int yylex();
	extern int line;

%}



%error-verbose


%left '*'
	

%token T_INT T_MAIN T_HASH T_INCLUDE T_IDENTIFIER T_HEADER_LITERAL T_STDIO T_STDLIB T_MATH T_STRING T_TIME T_VOID T_CHAR T_FLOAT T_OR_OP T_AND_OP	T_EQ_OP T_NE_OP T_LE_OP T_GE_OP T_INC_OP T_DEC_OP T_INTEGER_LITERAL T_FLOAT_LITERAL T_STRING_LITERAL T_CASE T_DEFAULT T_SWITCH T_FOR T_CONTINUE T_BREAK T_RETURN T_ADD_ASSIGN T_SUB_ASSIGN
%%
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
	: declarator '=' conditional_expression 
	| declarator 
	;

declarator
	: T_IDENTIFIER 
	| declarator '[' ']'  
 	| declarator '['conditional_expression']'
	;

conditional_expression
	: logical_or_expression 
 	| logical_or_expression '?' expression ':' conditional_expression
 	;

logical_or_expression
 	: logical_and_expression 
 	| logical_or_expression T_OR_OP logical_and_expression 
	;

logical_and_expression
 	: equality_expression 
 	| logical_and_expression T_AND_OP equality_expression 
	; 

equality_expression
 	: relational_expression 
 	| equality_expression T_EQ_OP relational_expression 
 	| equality_expression T_NE_OP relational_expression 
 	;

relational_expression
 	: additive_expression 
 	| relational_expression '<' additive_expression 
 	| relational_expression '>' additive_expression 
 	| relational_expression T_LE_OP additive_expression
 	| relational_expression T_GE_OP additive_expression
 	;


additive_expression
 	: multiplicative_expression 
 	| additive_expression '+' multiplicative_expression 
 	| additive_expression '-' multiplicative_expression 
 	;

multiplicative_expression
 	: unary_expression 
 	| multiplicative_expression '*' unary_expression 
 	| multiplicative_expression '/' unary_expression 
 	| multiplicative_expression '%' unary_expression 
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
	; 

primary_expression
	: T_IDENTIFIER 		
	| T_INTEGER_LITERAL
	| T_FLOAT_LITERAL 	
	| T_STRING_LITERAL 	
	| '(' expression ')' 
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
 	: T_CASE conditional_expression ':' statement
 	| T_DEFAULT ':' statement 
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
 	: T_SWITCH '(' expression ')' statement 
 	;

 iteration_statement
 	: T_FOR '(' expression_statement expression_statement ')' statement 
	| T_FOR '(' expression_statement expression_statement expression ')' statement  
	| T_FOR '(' declaration expression_statement ')' statement 
	| T_FOR '(' declaration expression_statement expression ')' statement  
 	;

 jump_statement
	: T_CONTINUE ';' 
	| T_BREAK ';'
 	| T_RETURN ';' 
 	| T_RETURN expression ';'
	;

expression
	: assignment_expression 
	| expression ',' assignment_expression 
	;

assignment_expression
	: conditional_expression 
	| unary_expression '=' assignment_expression 
	| unary_expression T_ADD_ASSIGN assignment_expression 
	| unary_expression T_SUB_ASSIGN assignment_expression 
	;
%%

int main()
{
yyin = fopen("test.c","r");
if(!yyparse()){
	printf("\n--------------------\n");
	printf("Parsing Successful\n");
	printf("--------------------\n\n");
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
