%{
	#include <stdio.h>
	#include <string.h>

	void yyerror(const char *);
	#include<stdlib.h>
	#define YYSTYPE char*
	FILE *yyin;
	int yylex();
	FILE *error;
	extern int line;

	struct scope_a
	{
		int s;
		int o;
	}SCOPE;
	struct scope_a stack[50];
	
	int top = 1;

	int scope_g = 0;
	int occ_g = 1;
	char type_g[100];
	char name_g[100];
	int flag = 0;

	typedef struct NODE
	{
		char value[100];
		char type[10];
		char name[100];
		int scope;
		int occ;
		struct NODE* next;

	}NODE;

typedef struct symbol_table
{
	NODE* head;
}TABLE;

TABLE *t;
void insert_scope(int scope, int occ);
int search_scope(int scope);
int update_occ(int scope);


void insert(char* name, char* value, char* type, int scope, int occ);
NODE* create_node(char* name, char* value, char* type, int scope, int occ);
void display();
void add_type(char*);
char* getvalue(char*,int,int);
int search(char*,int,int);
void update_val(char*,char*,int,int);
void deleteall();
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
	| type_specifier init_declarator_list ';' {add_type($1);

												
												}
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
	: declarator '=' conditional_expression {if(search($1,scope_g,occ_g)==1)
											{flag = 1;
												fprintf(error,"\n");
  				fprintf(error,"------\n");
				fprintf(error,"ERROR\n");
				fprintf(error,"------\n");

											fprintf(error,"%s is being Redeclared at Line %d\n\n", $1,line+1);
											
											}
											else
											{

											insert($1,$3,"temp",scope_g,occ_g);}}
	| declarator {if(search($1,scope_g,occ_g)==1)
				{
				fprintf(error,"\n");
  				fprintf(error,"------\n");
				fprintf(error,"ERROR\n");
				fprintf(error,"------\n");
				fprintf(error,"%s is being Redeclared at Line %d\n\n", $1,line+1);
				flag = 1;
				}
				else
				{
				insert($1,"0","temp",scope_g,occ_g);}}
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
 	| logical_or_expression T_OR_OP logical_and_expression {int val;
 															val = atoi($1) || atoi($3);
 															snprintf($$,20*sizeof(char),"%d",val);
 													}
	;

logical_and_expression
 	: equality_expression
 	| logical_and_expression T_AND_OP equality_expression {int val;
 															val = atoi($1) && atoi($3);
 															snprintf($$,20*sizeof(char),"%d",val);
 													}
	; 

equality_expression
 	: relational_expression
 	| equality_expression T_EQ_OP relational_expression {int val;
 															val = atoi($1) == atoi($3);
 															snprintf($$,20*sizeof(char),"%d",val);
 													}
 	| equality_expression T_NE_OP relational_expression {int val;
 															val = atoi($1) != atoi($3);
 															snprintf($$,20*sizeof(char),"%d",val);
 													}
 	;

relational_expression
 	: additive_expression
 	| relational_expression '<' additive_expression {int val;
 													if(atof($1)<atof($3))
 													val = 1;
 													else
 													val = 0;
 													snprintf($$,20*sizeof(char),"%d",val);}
 	| relational_expression '>' additive_expression {int val;
 													if(atof($1)>atof($3))
 													val = 1;
 													else
 													val = 0;
 													snprintf($$,20*sizeof(char),"%d",val);}
 	| relational_expression T_LE_OP additive_expression {int val;
 													if(atof($1)<=atof($3))
 													val = 1;
 													else
 													val = 0;
 													snprintf($$,20*sizeof(char),"%d",val);}
 	| relational_expression T_GE_OP additive_expression {int val;
 													if(atof($1)>=atof($3))
 													val = 1;
 													else
 													val = 0;
 													snprintf($$,20*sizeof(char),"%d",val);}
 	;


additive_expression
 	: multiplicative_expression
 	| additive_expression '+' multiplicative_expression {float val = atof($1) + atof($3);
 														snprintf($$,20*sizeof(char),"%f",val);}
 	| additive_expression '-' multiplicative_expression {float val = atof($1) - atof($3);
 														snprintf($$,20*sizeof(char),"%f",val);}
 	;

multiplicative_expression
 	: unary_expression
 	| multiplicative_expression '*' unary_expression {float val = atof($1) * atof($3);
 													snprintf($$,20*sizeof(char),"%f",val);}
 	| multiplicative_expression '/' unary_expression {float val = atof($1) / atof($3);
 													snprintf($$,20*sizeof(char),"%f",val);}
 	| multiplicative_expression '%' unary_expression {float val = atoi($1) % atoi($3);
 													snprintf($$,20*sizeof(char),"%f",val);}
 	;

unary_expression
 	: postfix_expression
 	| T_INC_OP unary_expression {float val = atof($1) + 1;
 									snprintf($$,20*sizeof(char),"%f",val);}
 	| T_DEC_OP unary_expression {float val = atof($1) + 1;
 									snprintf($$,20*sizeof(char),"%f",val);}
 	;

postfix_expression
 	: primary_expression
	| postfix_expression T_INC_OP {float val = atof($1) + 1;

 									snprintf($$,20*sizeof(char),"%f",val);
 									}
 	| postfix_expression T_DEC_OP {float val = atof($1) + 1;
 									snprintf($$,20*sizeof(char),"%f",val);}
	; 

primary_expression
	: T_IDENTIFIER 		{	
							char v[20] = "";
							strcpy(v,getvalue($1,scope_g, occ_g));
							//printf("YOLLLL\n");
							if(strcmp(v,"a")==0)
							{	
								flag = 1;
								fprintf(error,"\n");
  								fprintf(error,"------\n");
								fprintf(error,"ERROR\n");
								fprintf(error,"------\n");
								fprintf(error,"%s is not Declared (Line %d)\n\n",$1,line);
								
							}
							else{
							strcpy(name_g,$1);
							

							float val = atof(v);
							snprintf($$,20*sizeof(char),"%f",val);
						}
						}
	| T_INTEGER_LITERAL {
						//create new node
						//node->type = "int"
						//node->value.a = val;
						//int val = atoi($1);
						//snprintf($$,20*sizeof(char),"%d",val);
						//printf("After con%s\n",$$);
						}
	| T_FLOAT_LITERAL 	
	| T_STRING_LITERAL 	
	| '(' expression ')' {$$ = $2;}
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
| '{' 	{
			scope_g++;
			if(search_scope(scope_g))
			{
				occ_g = update_occ(scope_g);
				occ_g++;
			}
			
			
			insert_scope(scope_g,occ_g);
		} block_item_list '}' 
		{
			scope_g--;
			occ_g = update_occ(scope_g);
			insert_scope(scope_g,occ_g);
		}	
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
: T_CONTINUE ';' | T_BREAK ';' | T_RETURN ';' | T_RETURN expression ';' 	
;

expression
	: assignment_expression 
	| expression ',' assignment_expression
	;

assignment_expression
	: conditional_expression //printf("Cond\n");
							//printf("%s\n",$1);}
	| T_IDENTIFIER '=' assignment_expression { 
								char v[20] = "";
								strcpy(v,getvalue($1,scope_g, occ_g));
							
							if(strcmp(v,"a")==0)
							{
								flag = 1;
								fprintf(error,"\n");
  								fprintf(error,"------\n");
								fprintf(error,"ERROR\n");
								fprintf(error,"------\n");
								fprintf(error,"%s is not Declared (Line %d)\n\n",$1,line);
								
							}
							else

							update_val($1,$3,scope_g,occ_g);} 
	| T_IDENTIFIER T_ADD_ASSIGN assignment_expression  {	char v[20] = "";
															strcpy(v,getvalue($1,scope_g, occ_g));
															
															if(strcmp(v,"a")==0)
															{
																flag = 1;
																fprintf(error,"\n");
								  								fprintf(error,"------\n");
																fprintf(error,"ERROR\n");
																fprintf(error,"------\n");
																fprintf(error,"%s is not Declared (Line %d)\n\n",$1,line);
																
															}
															else
															{float val = atof(getvalue($1,scope_g,occ_g)) + atof($3);
															char abc[20];
															snprintf(abc,20*sizeof(char),"%f",val);
															update_val($1,abc,scope_g,occ_g);}}
	| T_IDENTIFIER T_SUB_ASSIGN assignment_expression {		char v[20] = "";
															strcpy(v,getvalue($1,scope_g, occ_g));
															
															if(strcmp(v,"a")==0)
															{
																flag = 1;
																fprintf(error,"\n");
								  								fprintf(error,"------\n");
																fprintf(error,"ERROR\n");
																fprintf(error,"------\n");
																fprintf(error,"%s is not Declared (Line %d)\n\n",$1,line);
																
															}
															else
															{float val = atof(getvalue($1,scope_g,occ_g)) - atof($3);
															char abc[20];
															snprintf(abc,20*sizeof(char),"%f",val);	
															update_val($1,abc,scope_g,occ_g);}}
	;
%%

int main()
{
error = fopen("Errors.txt", "w");
stack[0].s = 0;
stack[0].o = 1;
t = (TABLE*)malloc(sizeof(TABLE));
t->head = NULL;


yyin = fopen("test.c","r");
if(!yyparse() && flag == 0){
	printf("\n--------------------------------------\n");
	printf("Parsing succesful\nCheck Symboltable.txt for Symbol Table\n");
	printf("--------------------------------------\n\n");
	display();
	}
if(flag == 1)
{	printf("\n\n--------------------------------------");
	printf("\nParsing Unsuccesful\n");
	printf("There are Semantic Errors in your Code\n");
	printf("Check Errors.txt for Errors\n");
	printf("--------------------------------------\n\n");
	
}


fclose(error);


return 0;


}
void yyerror(const char *msg)
{	printf("\n---------------------------------------");
	printf("\nParsing Unsuccesful\n");
	printf("There are Syntactic Errors in your Code\n");
	printf("Check Errors.txt for Errors\n");
	printf("---------------------------------------\n\n");

  	fprintf(error,"------\n");
	fprintf(error,"ERROR\n");
	fprintf(error,"------\n");
	fprintf(error,"Parsing Unsuccesful\n");
	fprintf(error,"Syntax Error at line %d\n\n",line);
}

void insert(char* name, char* value, char* type, int scope, int occ)
{
	if(t->head == NULL)
	{
		NODE* new = create_node(name,value,type,scope,occ);
		new->next = NULL;
		t->head = new;
		
		
		return;
	}
	else
	{
		NODE* new = create_node(name,value,type,scope,occ);
		new->next = NULL;
		NODE* it;
		it = t->head;
		while(it->next!=NULL)
		{
			it = it->next;
		}
		it->next = new;
	}
}

NODE* create_node(char* name, char* value, char* type, int scope,int occ)
{
	NODE* temp = (NODE*)malloc(sizeof(NODE));
	strcpy(temp->value,value); 
	strcpy(temp->name,name); 
	strcpy(temp->type,type); 
	temp->scope = scope;
	temp->occ = occ;
	return temp;
}

void display()
{	
	if(t->head == NULL)
		printf("Empty");
	NODE* it = t->head;
	int i = 0;
	FILE *fp;
	fp = fopen("Symboltable.txt", "w");
	fprintf(fp,"\n------------\n");
	fprintf(fp,"SYMBOL TABLE\n");
	fprintf(fp,"------------\n\n");
	while(it!=NULL)
	{	
		fprintf(fp,"Entry %d:\n",i);
		fprintf(fp,"Name:%s\t Value:%s\t Type:%s\t Scope:%d\t Occurence:%d\n\n\n",it->name,it->value,it->type,it->scope,it->occ);
		it = it->next;
		i = i+1;
	}
	fclose(fp);
}

void add_type(char* x)
{
	NODE* it = t->head;
	while(it!=NULL)
	{
		if(strcmp(it->type,"temp")==0)
		{		
			strcpy(it->type,x);
			if(strcmp(x,"int")==0)
			{
				int val = atoi(it->value);
				snprintf(it->value,20*sizeof(char),"%d",val);
			}
		}
		it = it->next;
	}

}

char* getvalue(char* id, int x, int y)

{	
	if(x==-1)
		return "a";
	NODE* it = t->head;

	while(it!=NULL)
	{
		if(strcmp(it->name,id)==0 && it->scope == x &&  it->occ == y)
		{
			return (it->value);
		}

	it = it->next;
	
	}

	return getvalue(id,x-1,update_occ(x-1));
}

int search(char* id,int x, int y)
{	
	if(x == -1)
		return 0;

	NODE* it = t->head;
	while(it!=NULL)
	{
		if(strcmp(it->name,id)==0 && it->scope == scope_g && it->occ == occ_g)
		{
			return 1;
		}
	it = it->next;
	}
	return search(id,x-1,update_occ(x-1));
}

void update_val(char* name, char* value, int x, int y)
{	
	if(x==-1)
		return;
	NODE* it = t->head;
	while(it!=NULL)
	{
		if(strcmp(it->name,name)==0 && it->scope == x && it->occ == y)
		{
			if(strcmp(it->type,"int")==0)
			{
				int val = atoi(value);
				snprintf(it->value,20*sizeof(char),"%d",val);

			}
			else
			{
				strcpy(it->value,value);
			}
			return;
		}
	it = it->next;
	
	}
	update_val(name,value,x-1,update_occ(x-1));
}

void insert_scope(int scope, int occ)
{
	stack[top].s = scope;
	stack[top].o = occ;
	top = top + 1;
}
int search_scope(int scope)
{
	for(int i = top-1; i>-1; i--)
	{
		if(stack[i].s == scope)
			return 1;
	}
	return 0;

}
int update_occ(int scope)
{
	for(int i = top-1; i>-1; i--)
	{
		if(stack[i].s == scope)
		{
			int z = stack[i].o;
			return z;
		}
		
	}
	return occ_g;

}