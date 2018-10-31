%{
#include <bits/stdc++.h>
#include "symbolinfo.h"
#define YYSTYPE symbolInfo*
//int yydebug;
using namespace std;
int yyparse(void);
int yylex(void);
double var[26];
FILE *fo;
extern FILE *yyin;
extern int line_count;
extern int error_count;
int warning=0;
char temp[40];

int labelCount=0;
int tempCount=0;


char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}


void yyerror(char *s)
{
	//fprintf(stderr,"%s\n",s);
	fprintf(fo,"Error at line no %d : %s\n",line_count,s);
	error_count++;
	return;
}

class symbolTable
{
    symbolInfo **arr;
    int arrsize;
public:
    symbolTable(int a);
    int myhash(char *p);
    symbolInfo *search(char *p);
    int insert(symbolInfo *s);
    int mydelete(char *p);
    void print();
    ~symbolTable();
};
symbolTable::symbolTable(int a)
{
    arr=(symbolInfo **)malloc(a*sizeof(symbolInfo *));
    for(int i=0;i<a;i++) arr[i]=0;
    arrsize=a;
}

int symbolTable::myhash(char *p)
{
    int s=0;
    int l=strlen(p);
    for(int i=0;i<l;i++){
        int temp=(int) p[i];
        s+=temp;
    }
    return (s%arrsize);
}
symbolInfo *symbolTable::search(char *p)
{
    int i=myhash(p);
    symbolInfo *h=arr[i];
    while(1){
        if(h==0) break;
        if(strcmp(h->name,p)==0) {
            return h;
        }
        h=h->next;
    }
    return 0;
}

int symbolTable::insert(symbolInfo *s)
{
    
    /*if(search(n)!=-1){
	fprintf(logout,"<%s,%s> already exists\n",n,t);
        return -1;
    }*/
    //else{
        int j=0,i=myhash(s->name);
        s->next=0;
        if(arr[i]==0){
            arr[i]=s;
        }
        else{
            j++;
            struct symbolInfo *h=arr[i];
            while(h->next!=0) {
                h=h->next;
                j++;
            }
            h->next=s;
        }
        return j;
    //}
}

int symbolTable::mydelete(char *p)
{
	if(search(p)==0){
        return -1;
	}
	else{
        symbolInfo *temp, *prev ;
        int j=0,i=myhash(p);
        temp = arr[i];
        while (temp != 0)
        {
            if (strcmp(temp->name,p)==0) break;
            prev = temp;
            temp = temp->next ;
            j++;
        }
        if (temp == arr[i])
        {
            arr[i]=arr[i]->next;
            delete temp ;
        }
        else
        {
            prev->next = temp->next ;
            delete temp;
        }
        return j ;
	}
}

void symbolTable::print()
{
    fprintf(fo,"\n\n");
    for(int i=0;i<arrsize;i++){
        symbolInfo *h=arr[i];
	if(h==0) continue;
	fprintf(fo,"%d ->",i);
        while(h!=0){
	    if(h->size!=-1){
		fprintf(fo,"<%s,%s,{",h->name,h->type);
		for(int j=0;j<h->size;j++){
			//fprintf(fo,"0,"); continue;
			if(h->aray[j]==NULL) {fprintf(fo,"0");}
			else if(strcmp(h->vtype,"int")==0) fprintf(fo,"%d",h->aray[j]->intvalue);
	    		else if (strcmp(h->vtype,"float")==0) fprintf(fo,"%f",h->aray[j]->floatvalue);
	    		else if (strcmp(h->vtype,"char")==0) fprintf(fo,"%c",h->aray[j]->charvalue);
			if(j!=h->size-1) {fprintf(fo,",");}
			//else continue;
		}
		fprintf(fo,"}>");
	    }
	    else{
		    if(strcmp(h->vtype,"int")==0) fprintf(fo,"<%s,%s,%d>",h->name,h->type,h->intvalue);
		    else if (strcmp(h->vtype,"float")==0) fprintf(fo,"<%s,%s,%f>",h->name,h->type,h->floatvalue);
		    else if (strcmp(h->vtype,"char")==0) fprintf(fo,"<%s,%s,,%c>",h->name,h->type,h->charvalue);
	    }
            h=h->next;
        }
	fprintf(fo,"\n");
    }
    fprintf(fo,"\n\n");
}

symbolTable::~symbolTable()
{
    free(arr);
}
symbolTable table(20);

%}

%token MAIN IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON ID STRING CONST_INT CONST_FLOAT CONST_CHAR NOT PRINTLN

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

Global_Program  : var_declaration Func_program {fprintf(fo,"Global_Program  : var_declaration Func_program\n");}
		| Func_program  {fprintf(fo,"Global_Program  : Func_program\n");}
		;
Func_program    : Func_list Program {fprintf(fo,"Func_program    : Func_list Program\n");}
		| Program   {fprintf(fo,"Func_program     : Program\n");}
		;
Func_list	:Func_list Func  {fprintf(fo,"Func_list	:Func_list Func\n");}
		|Func  {fprintf(fo,"Func_list	:Func\n");}
		;	       
Func		: type_specifier ID LPAREN Param_list RPAREN compound_statement {fprintf(fo,"Func	: type_specifier ID LPAREN Param_list RPAREN compound_statement\n");}
		|VOID ID LPAREN Param_list RPAREN compound_statement {fprintf(fo,"Func	: VOID ID LPAREN Param_list RPAREN compound_statement\n");}
		;
Param_list	: Param_list COMMA Param  {fprintf(fo,"Param_list	: Param_list COMMA Param\n");}
		|Param  {fprintf(fo,"Param_list	:Param\n");}
		|VOID {fprintf(fo,"Param_list	:VOID\n");}
		;
Param		:type_specifier ID  {fprintf(fo,"Param		:type_specifier ID\n");}
		;

Program : INT MAIN LPAREN RPAREN compound_statement  {fprintf(fo,"Program : INT MAIN LPAREN RPAREN compound_statement\n");
			$$=new symbolInfo();
			//$$=$5;
			$$->code=".model small\n";
			$$->code+=".stack 100h\n";
			$$->code+=".data\n";
			for(int i=0;i<tempCount;i++){
				char *t= new char[4];
				strcpy(t,"t");
				char b[3];
				sprintf(b,"%d", i);
				strcat(t,b);
				$$->code+=string(t)+" dw ?\n";
			}

			$$->code+=$5->code; 
			ofstream fout;
			fout.open("mycode.asm");
			fout << $$->code;
		}
	;


compound_statement : LCURL var_declaration statements RCURL  {fprintf(fo,"compound_statement : LCURL var_declaration statements RCURL\n");
							//$$=$3;
							//$$->code=$2->code+$3->code;
							$$->code=$2->code;
							$$->code+="\n";
							$$->code+=".code\n";
							$$->code+="main proc\n";
							$$->code+="mov ax,@data\n";
							$$->code+="mov ds,ax\n";
							$$->code+=$3->code;
						}
		   | LCURL statements RCURL                  {fprintf(fo,"compound_statement : LCURL statements RCURL\n");$$=$2;}
		   | LCURL RCURL			     {fprintf(fo,"compound_statement : LCURL RCURL\n");
								$$=new symbolInfo("compound_statement","dummy");}
		   ;

			 
var_declaration	: type_specifier declaration_list SEMICOLON  {fprintf(fo,"var_declaration : type_specifier declaration_list SEMICOLON\n");
						$$=$2;
					}
		| type_specifier declaration_list error	  {fprintf(fo,"Error at line no %d: ; expected\n",line_count);error_count++;}
		|  var_declaration type_specifier declaration_list SEMICOLON  {fprintf(fo,"var_declaration :var_declaration type_specifier declaration_list SEMICOLON\n");$$=$1;
						$$->code+=$3->code;}
		| var_declaration type_specifier declaration_list error{fprintf(fo,"Error at line no %d: ; expected\n",line_count);error_count++;}
		;

type_specifier	: INT  	  {strcpy(temp,"int");fprintf(fo,"type_specifier	: INT\n");$$=new symbolInfo("int","type");}
		| FLOAT   {strcpy(temp,"float");fprintf(fo,"type_specifier	:FLOAT\n");$$=new symbolInfo("float","type");}
		| CHAR    {strcpy(temp,"char");fprintf(fo,"type_specifier	:CHAR\n");$$=new symbolInfo("char","type");}
		;
			
declaration_list : declaration_list COMMA ID   {fprintf(fo,"declaration_list : declaration_list COMMA ID\n");
				$$=new symbolInfo();
				$$=$3;
				$$->code=$1->code;
				$$->code+=string($3->name)+" dw " + "?\n";
				strcpy($$->vtype,temp);
				$$->size=-1;
				if(table.search($3->name)==NULL)
				{
							table.insert($$);
				}
				else {fprintf(fo,"Error at Line %d: Multiple Declaration of %s\n",line_count,$3->name);error_count++;} 
				}
		 | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD  {
				fprintf(fo,"declaration_list :declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n");
				$$=new symbolInfo();
				$$=$3;
				strcpy($$->vtype,temp);
				$$->size=$5->intvalue;
				$$->aray=new symbolInfo*[$$->size];
				for(int k=0;k<$$->size;k++) {$$->aray[k]=new symbolInfo();strcpy($$->aray[k]->vtype,temp);}
						//$$->arr=(symbolInfo **)malloc($$->size*sizeof(symbolInfo *));
				$$->code=$1->code;
				$$->code+=string($3->name)+" dw ";
				for(int i=0;i<$$->size-1;i++){
					$$->code += "?, " ;
				}
				$$->code+="?\n";
				if(table.search($3->name)==NULL)
				{
						table.insert($$);
				}
				else {fprintf(fo,"Error at Line %d: Multiple Declaration of %s\n",line_count,$3->name);error_count++;} 
				}
		 | ID  {//$$=new symbolInfo();
			$$=$1;
			fprintf(fo,"declaration_list :ID\n");
			strcpy($$->vtype,temp);
			$$->size=-1;
			$$->code=string($1->name)+" dw " + "?\n";
			if(table.search($1->name)==NULL)
			{	
				table.insert($$);
				//fprintf(fo,"%s\n",$$->vtype);		
			}
			else {fprintf(fo,"Error at Line %d: Multiple Declaration of %s\n",line_count,$1->name);error_count++;}
		  }
		 | ID LTHIRD CONST_INT RTHIRD  {fprintf(fo,"declaration_list : ID LTHIRD CONST_INT RTHIRD\n");
						$$=new symbolInfo();

						strcpy($$->vtype,temp);
						$$->size=$3->intvalue;
						$$->aray=new symbolInfo*[$$->size];
						for(int k=0;k<$$->size;k++) {$$->aray[k]=new symbolInfo();strcpy($$->aray[k]->vtype,temp);}
						//$$->aray=(symbolInfo **)malloc($$->size*sizeof(symbolInfo *));
						$$->code=string($1->name)+" dw ";
						for(int i=0;i<$$->size-1;i++){
							$$->code += "?, " ;
						}
						$$->code+="?\n";
			if(table.search($1->name)==NULL)
				{		
						table.insert($$);
						//table.print();
				}
			else {fprintf(fo,"Error at Line %d: Multiple Declaration of %s\n",line_count,$1->name);error_count++;}
						}
		 ;

statements : statement  {fprintf(fo,"statements : statement\n");}
	   | statements statement   {fprintf(fo,"statements :statements statement\n");$$->code += $2->code;}
	   ;


statement  : expression_statement  {fprintf(fo,"statement  : expression_statement\n");}
	   | compound_statement    {fprintf(fo,"statement  : compound_statement\n");}
	   | FOR LPAREN expression_statement expression_statement expression RPAREN statement   {
fprintf(fo,"statement  :FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
					$$=$3;
					char *label=newLabel();
					char *label2=newLabel();
					$$->code+=string(label)+":\n";
					$$->code+=$4->code;
					$$->code+="mov ax, "+string($4->name)+"\n";
					$$->code+="cmp ax, 1\n";
					$$->code+="jne "+string(label2)+"\n";
					$$->code+=$7->code;
					$$->code+=$5->code;
					$$->code+="jmp "+string(label)+"\n";
					$$->code+=string(label2)+":\n";
			}
	   | IF LPAREN expression RPAREN statement  {fprintf(fo,"statement  : IF LPAREN expression RPAREN statement\n");
					$$=$3;
					char *label=newLabel();
					$$->code+="mov ax, "+string($3->name)+"\n";
					$$->code+="cmp ax, 1\n";
					$$->code+="jne "+string(label)+"\n";
					$$->code+=$5->code;
					$$->code+=string(label)+":\n";

			} %prec LOWER_THAN_ELSE ;
	   | IF LPAREN expression RPAREN statement ELSE statement  {
					fprintf(fo,"statement  :IF LPAREN expression RPAREN statement ELSE statement\n");
					$$=$3;
					char *label=newLabel();
					char *label2=newLabel();
					$$->code+="mov ax, "+string($3->name)+"\n";
					$$->code+="cmp ax, 1\n";
					$$->code+="jne "+string(label)+"\n";
					$$->code+=$5->code;
					$$->code+="jmp "+string(label2)+"\n";
					$$->code+=string(label)+":\n";
					$$->code+=$7->code;
					$$->code+=string(label2)+":\n";				
				}
	   | WHILE LPAREN expression RPAREN statement   {fprintf(fo,"statement  :WHILE LPAREN expression RPAREN statement\n");
					$$=$3;
					char *label=newLabel();
					char *label2=newLabel();
					$$->code+=string(label)+":\n";
					$$->code+="mov ax, "+string($3->name)+"\n";
					$$->code+="cmp ax, 1\n";
					$$->code+="jne "+string(label2)+"\n";
					$$->code+=$5->code;
					$$->code+="jmp "+string(label)+"\n";
					$$->code+=string(label2)+":\n";			
				}
	   | PRINTLN LPAREN ID RPAREN SEMICOLON    {fprintf(fo,"statement  :PRINTLN LPAREN ID RPAREN SEMICOLON\n");
					$$=new symbolInfo("println","nonterminal");
					char *t=newTemp();
					char *label=newLabel();
					$$->code="mov "+string(t)+","+string($3->name)+"\n";
					$$->code+=string(label)+":\n";
					$$->code+="mov dx,0\n";
					$$->code+="mov ax,"+string(t)+"\n";
					$$->code+="mov bx,10\n";
					$$->code+="div bx\n";
					$$->code+="mov "+string(t)+",ax\n";
					$$->code+="add dx,48\n";
					$$->code+="mov ah,2\n";
					$$->code+="int 21h\n";
					$$->code+="cmp "+string(t)+",0\n";
					$$->code+="jne "+string(label)+"\n";
				symbolInfo *h=table.search($3->name);
				if(strcmp(h->vtype,"int")==0) 
				{
					//printf("%d\n",h->intvalue);
				}

				//else if(strcmp(h->vtype,"float")==0) //printf("%d\n",h->floatvalue);
				//else if(strcmp(h->vtype,"char")==0) //printf("%c\n",h->charvalue);
			}
	   | PRINTLN LPAREN ID RPAREN error {fprintf(fo,"Error at line no %d: ; expected\n",line_count);error_count++;}
	   | RETURN expression SEMICOLON     {
				fprintf(fo,"statement  :RETURN expression SEMICOLON\n");
				$$=$2;
				$$->code+="mov ah,4ch\n";
				$$->code+="int 21h\n";
				$$->code+="main endp\n";
				$$->code+="end main\n";
			}
	   | RETURN expression error         {fprintf(fo,"Error at line no %d: ; expected\n",line_count);error_count++;}	
	   ;
		
expression_statement	: SEMICOLON	{fprintf(fo,"expression_statement	: SEMICOLON\n");$$=new symbolInfo(";","SEMICOLON");}
			|error {fprintf(fo,"Error at line no %d: ; expected\n",line_count);error_count++;}		
			| expression SEMICOLON   {fprintf(fo,"expression_statement	:expression SEMICOLON\n");}
		        | expression error {fprintf(fo,"Error at line no %d: ; expected\n",line_count);error_count++;}
			;
						
variable : ID 		{symbolInfo *h=table.search($1->name);
			fprintf(fo,"variable : ID\n");
			if(h==NULL)  {fprintf(fo,"Error at Line no %d:Undeclared variable\n",line_count);error_count++;}
			if(h->size!=-1) {fprintf(fo,"Error at Line no %d:Type mismatch\n",line_count);error_count++;}
			}
	 | ID LTHIRD expression RTHIRD {	$$=$1;
						$$->code=$3->code;
						$$->arrIndexHolder=string($3->name);
					fprintf(fo,"variable :ID LTHIRD expression RTHIRD\n");
					symbolInfo *h=table.search($1->name);
					if(h==NULL)  {fprintf(fo,"Error at Line no %d:Undeclared variable\n",line_count);error_count++;}
					//h->aray[$3->intvalue]=new symbolInfo();
					else if(h->size==-1) 
						{fprintf(fo,"Error at Line no %d:%s Not an array\n",line_count,h->name);error_count++;}
					else if(h->size<=$3->intvalue) 
						{fprintf(fo,"Error at Line no %d:Array index out of bound\n",line_count);error_count++;}
					else {
						$$=h->aray[$3->intvalue];
					}
					//fprintf(fo,"-----------------------%d %s\n",$$->intvalue,$$->vtype);
					}
	 ;
			
expression : logic_expression	{fprintf(fo,"expression : logic_expression\n");}
	   | variable ASSIGNOP logic_expression   {
			fprintf(fo,"expression : variable ASSIGNOP logic_expression %d %s\n",$1->intvalue,$1->vtype);
			//symbolInfo *h=$1;
			//h->intvalue=$3->intvalue;
					$1->intvalue=$3->intvalue;
					//cout<<$1->intvalue;
					$$->code=$3->code+$1->code;
					$$->code+="mov ax, "+string($3->name)+"\n";
					if($$->arrIndexHolder==""){ 
						$$->code+= "mov "+string($1->name)+", ax\n";
					}
				
					else{
						$$->code+="lea di, " + string($1->name)+"\n";
						for(int i=0;i<2;i++){
							$$->code += "add di, " + $1->arrIndexHolder +"\n";
						}
						$$->code+= "mov [di], ax\n";
						$$->arrIndexHolder="";
					}
			if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$1->intvalue=$3->intvalue;
					strcpy($1->vtype,"int");
				}
			else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){
					fprintf(fo,"Warning at line no %d: Type mismatch\n",line_count);
					warning++;	
					$1->intvalue=$3->floatvalue;
					strcpy($1->vtype,"int");
				}
			else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){
					fprintf(fo,"Warning at line no %d: Type mismatch\n",line_count);
					warning++;	
					$1->floatvalue=$3->intvalue;
					strcpy($1->vtype,"float");
				}
			else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$1->floatvalue=$3->floatvalue;
					strcpy($1->vtype,"float");
				}
			else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){
					fprintf(fo,"Warning at line no %d: Type mismatch\n",line_count);
					warning++;	
					$1->floatvalue=$3->charvalue;
					strcpy($1->vtype,"float");
				}
			else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$1->charvalue=$3->floatvalue;
					strcpy($1->vtype,"char");
				}
			else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){
					fprintf(fo,"Warning at line no %d: Type mismatch\n",line_count);
					warning++;	
					$1->charvalue=$3->intvalue;
					strcpy($1->vtype,"char");
				}
			else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){
					fprintf(fo,"Warning at line no %d: Type mismatch\n",line_count);
					warning++;	
					$1->intvalue=$3->charvalue;
					strcpy($1->vtype,"int");
				}
			else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$1->charvalue=$3->charvalue;
					strcpy($1->vtype,"char");
				}
			table.print();
			fprintf(fo,"expression : variable ASSIGNOP logic_expression %d %s\n",$1->intvalue,$1->vtype);
			}	
	   ;
			
logic_expression : rel_expression 	{fprintf(fo,"logic_expression : rel_expression\n");}
		 | rel_expression LOGICOP rel_expression 	{fprintf(fo,"logic_expression : rel_expression LOGICOP rel_expression\n");
			$$=new symbolInfo();
			$$=$1;
		 	strcpy($$->vtype,"int");
			$$->code+=$3->code;
			$$->code+="mov ax, " + string($1->name)+"\n";
			$$->code+="mov bx, " + string($3->name)+"\n";
			char *temp=newTemp();
			char *label1=newLabel();
			char *label2=newLabel();
			if(strcmp($2->name,"&&")==0) {
				$$->code+="cmp ax,1\n";
				$$->code+="jne "+string(label1)+"\n";
				$$->code+="cmp bx,1\n";
				$$->code+="jne "+string(label1)+"\n";
				$$->code+="mov "+string(temp)+",1\n";
				$$->code+="jmp "+string(label2)+"\n";
				$$->code+=string(label1)+":\n";
				$$->code+="mov "+string(temp)+",0\n";
				$$->code+=string(label2)+":\n";
				strcpy($$->name,temp);
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue&&$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue&&$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue&&$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue&&$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue&&$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue&&$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue&&$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue&&$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue&&$3->charvalue;
					
				}
			}
			else if(strcmp($2->name,"||")==0) {
				$$->code+="cmp ax,1\n";
				$$->code+="je "+string(label1)+"\n";
				$$->code+="cmp bx,1\n";
				$$->code+="je "+string(label1)+"\n";
				$$->code+="mov "+string(temp)+",0\n";
				$$->code+="jmp "+string(label2)+"\n";
				$$->code+=string(label1)+":\n";
				$$->code+="mov "+string(temp)+",1\n";
				$$->code+=string(label2)+":\n";
				strcpy($$->name,temp);
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue||$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue||$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue||$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue||$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue||$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue||$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue||$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue||$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue||$3->charvalue;
				
				}
			}
		 }
		 ;
			
rel_expression	: simple_expression   {fprintf(fo,"rel_expression	: simple_expression\n");}
		| simple_expression RELOP simple_expression	{
			fprintf(fo,"rel_expression	: simple_expression RELOP simple_expression\n");
			$$=new symbolInfo();
			$$=$1;
		 	strcpy($$->vtype,"int");
			$$->code+=$3->code;
			$$->code+="mov ax, " + string($1->name)+"\n";
			$$->code+="cmp ax, " + string($3->name)+"\n";
			char *temp=newTemp();
			char *label1=newLabel();
			char *label2=newLabel();
			if(strcmp($2->name,"<")==0) {$$->code+="jl " + string(label1)+"\n";
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue<$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue<$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue<$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue<$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue<$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue<$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue<$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue<$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue<$3->charvalue;
					
				}
			}
			else if(strcmp($2->name,">")==0) {$$->code+="jg " + string(label1)+"\n";
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue>$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue>$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue>$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue>$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue>$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue>$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue>$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue>$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue>$3->charvalue;
				
				}
			}
			else if(strcmp($2->name,"<=")==0) {$$->code+="jle " + string(label1)+"\n";
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue<=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue<=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue<=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue<=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue<=$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue<=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue<=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue<=$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue<=$3->charvalue;
					
				}
			}
			else if(strcmp($2->name,">=")==0) {$$->code+="jge " + string(label1)+"\n";
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue>=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue>=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue>=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue>=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue>=$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue>=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue>=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue>=$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue>=$3->charvalue;
				
				}
			}
			else if(strcmp($2->name,"==")==0) {$$->code+="jeq " + string(label1)+"\n";
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue==$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue==$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue==$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue==$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue==$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue==$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue==$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue==$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue==$3->charvalue;
					
				}
			}
			else if(strcmp($2->name,"!=")==0) {$$->code+="jne " + string(label1)+"\n";
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue!=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue!=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue!=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue!=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue!=$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue!=$3->floatvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue!=$3->intvalue;
					
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue!=$3->charvalue;
					
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue!=$3->charvalue;
				
				}
			}
			$$->code+="mov "+string(temp) +", 0\n";
			$$->code+="jmp "+string(label2) +"\n";
			$$->code+=string(label1)+":\nmov "+string(temp)+", 1\n";
			$$->code+=string(label2)+":\n";
			strcpy($$->name,temp);
		}
		;
				
simple_expression : term    {fprintf(fo,"simple_expression : term\n");}
		  | simple_expression ADDOP term    {fprintf(fo,"simple_expression : simple_expression ADDOP term\n");
			$$=new symbolInfo();
			$$=$1;
			$$->code += $3->code;
			if(strcmp($2->name,"+")==0) {
				//if($1->intvalue==0 && $3->intvalue==0){	
				//}
				if($1->intvalue==0){
					$$->code += "mov ax, "+ string($3->name)+"\n";
					char *temp=newTemp();
					$$->code +="mov "+string(temp)+",ax\n";
					strcpy($$->name,temp);
				}
				else if($3->intvalue==0){
					$$->code += "mov ax, "+ string($1->name)+"\n";
					char *temp=newTemp();
					$$->code +="mov "+string(temp)+",ax\n";
					strcpy($$->name,temp);
				}
				else if($1->intvalue!=0 && $3->intvalue!=0){
					$$->code += "mov ax, "+ string($1->name)+"\n";
					$$->code += "mov bx, "+ string($3->name) +"\n";
					char *temp=newTemp();
					$$->code +="add ax,bx\n";
					$$->code +="mov "+string(temp)+",ax\n";
					strcpy($$->name,temp);
				}
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue+$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue+$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue+$3->intvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue+$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue+$3->charvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue+$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue+$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue+$3->charvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue+$3->charvalue;
					strcpy($$->vtype,"char");
				}
			}
			else{   
				$$->code += "mov ax, "+ string($1->name)+"\n";
				$$->code += "mov bx, "+ string($3->name) +"\n";
				char *temp=newTemp();
				$$->code +="sub ax,bx\n";
				$$->code +="mov "+string(temp)+",ax\n";
				strcpy($$->name,temp);
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue-$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue-$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue-$3->intvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue-$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue-$3->charvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue-$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue-$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue-$3->charvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue-$3->charvalue;
					strcpy($$->vtype,"char");
				}
			    }
			}
		  ;
					
term :	unary_expression    {fprintf(fo,"term :	unary_expression\n");}
     |  term MULOP unary_expression    {
	fprintf(fo,"term :term MULOP unary_expression\n");
	$$=new symbolInfo();
	$$=$1;
	$$->code += $3->code;
	char *temp=newTemp();
			if(strcmp($2->name,"*")==0) {
				if($1->intvalue==1){
					$$->code += "mov ax, "+ string($3->name)+"\n";
					char *temp=newTemp();
					$$->code +="mov "+string(temp)+",ax\n";
					strcpy($$->name,temp);
				}
				else if($3->intvalue==1){
					$$->code += "mov ax, "+ string($1->name)+"\n";
					char *temp=newTemp();
					$$->code +="mov "+string(temp)+",ax\n";
					strcpy($$->name,temp);
				}
				else {
					$$->code += "mov ax, "+ string($1->name)+"\n";
					$$->code += "mov bx, "+ string($3->name) +"\n";
					char *temp=newTemp();
					$$->code += "mul bx\n";
					$$->code += "mov "+ string(temp) + ", ax\n";
					strcpy($$->name,temp);
				}
				//$$->code += "mul bx\n";
				//$$->code += "mov "+ string(temp) + ", ax\n";
				//strcpy($$->name,temp);
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue*$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue*$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue*$3->intvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue*$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue*$3->charvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue*$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue*$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue*$3->charvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue*$3->charvalue;
					strcpy($$->vtype,"char");
				}
			}
			if(strcmp($2->name,"/")==0) {
				$$->code +="mov dx,0\n";
				$$->code += "div bx\n";
				$$->code += "mov "+ string(temp) + ", ax\n";
				strcpy($$->name,temp);
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue/$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->intvalue/$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"int")){	
					$$->floatvalue=$1->floatvalue/$3->intvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->floatvalue/$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"float")&&!strcmp($3->vtype,"char")){	
					$$->floatvalue=$1->floatvalue/$3->charvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"float")){	
					$$->floatvalue=$1->charvalue/$3->floatvalue;
					strcpy($$->vtype,"float");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->charvalue/$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"char")){	
					$$->intvalue=$1->intvalue/$3->charvalue;
					strcpy($$->vtype,"int");
				}
				else if(!strcmp($1->vtype,"char")&&!strcmp($3->vtype,"char")){	
					$$->charvalue=$1->charvalue/$3->charvalue;
					strcpy($$->vtype,"char");
				}
			}
			if(strcmp($2->name,"%")==0) {
					$$->code +="mov dx,0\n";
					$$->code += "div bx\n";
					$$->code += "mov "+ string(temp) + ", dx\n";
					strcpy($$->name,temp);
				if(!strcmp($1->vtype,"int")&&!strcmp($3->vtype,"int")){	
					$$->intvalue=$1->intvalue%$3->intvalue;
					strcpy($$->vtype,"int");
				}
				else {fprintf(fo,"Error at Line no %d :Both operands of Modulus operator should be integer.\n",line_count);
					error_count++;}
			}
	}
     ;

unary_expression : ADDOP unary_expression  {fprintf(fo,"used :unary_expression : ADDOP unary_expression\n");
					$$=$2;
					if(!strcmp($1->name,"-")){
						char *temp=newTemp();
						$$->code="mov ax, " + string($2->name) + "\n";
						$$->code+="neg ax\n";
						$$->code+="mov "+string(temp)+", ax\n";
						strcpy($$->name,temp);	
					}
				}
		 | NOT unary_expression   {fprintf(fo,"unary_expression : NOT unary_expression\n");
						$$=$2;
						char *temp=newTemp();
						$$->code="mov ax, " + string($2->name) + "\n";
						$$->code+="not ax\n";
						$$->code+="mov "+string(temp)+", ax\n";
						strcpy($$->name,temp);
				}
		 | factor                 {fprintf(fo,"unary_expression : factor\n");}
		 ;
	
factor	: variable 			{fprintf(fo,"factor	: variable\n");
			$$=$1;
			if($$->arrIndexHolder==""){
				
			}
			else{
				$$->code+="lea di, " + string($1->name)+"\n";
				for(int i=0;i<2;i++){
					$$->code += "add di, " + $1->arrIndexHolder +"\n";
				}
				char *temp= newTemp();
				$$->code+= "mov " + string(temp) + ", [di]\n";
				strcpy($$->name,temp);
				$$->arrIndexHolder="";
			}
		}
	| LPAREN expression RPAREN  	{fprintf(fo,"factor	: LPAREN expression RPAREN\n");$$=$2;}
	| CONST_INT 			{fprintf(fo,"factor	: CONST_INT\n");}
	| CONST_FLOAT			{fprintf(fo,"factor	: CONST_FLOAT\n");}
	| CONST_CHAR			{fprintf(fo,"factor	: CONST_CHAR\n");}
	| factor INCOP 			{fprintf(fo,"factor	: factor INCOP\n");$$->code += "inc " + string($1->name) + "\n";}
	| factor DECOP			{fprintf(fo,"factor	: factor DECOP\n");$$->code += "dec " + string($1->name) + "\n";}
	;



%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	//yydebug=1;
	//freopen("input1.txt", "r", stdin);
	//freopen("fo.txt", "w", stdout);
	fo= fopen("fo.txt","w");
	yyin= fin;
	yyparse();
	fprintf(fo,"total LINES: %d\n",line_count-1);
	fprintf(fo,"total ERRORS: %d\n",error_count);
	fprintf(fo,"total WARNINGSS: %d\n",warning);
	fclose(yyin);
	fclose(fo);
	return 0;
}







