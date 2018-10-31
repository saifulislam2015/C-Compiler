%option noyywrap

%x MYSTATE

%x MYSTATE2

%{
#include <bits/stdc++.h>
#include "y.tab.h"
#include "symbolinfo.h"


using namespace std;


void yyerror(char *);

FILE *logout;
FILE *tokenout;


//symbolTable ob(30);

int line_count=1;
int error_count=0;
string str="";
string str2="";
int a,b;


%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
DIGITS {DIGIT}+
NUMBER {DIGITS}(\.{DIGITS})?(E[+-]?{DIGITS})?
NEWLINE \n

%%

{NEWLINE} {line_count++;}
{WHITESPACE} {}

"if"	{return IF;}
		
"else"	{return ELSE;}
"for"	{return FOR;}
"while"	{return WHILE;}
"do"	{return DO;}
	
"break"	{return BREAK;}
		
"int"	{return INT;}
			
"char"	{return CHAR;}
"float"	{return FLOAT;}
"double"  {return DOUBLE;} 
"void"	{return VOID;}
	
"return" {return RETURN;}

"switch" {return SWITCH;}
"case"	{return CASE;}
		
"default"	{return DEFAULT;}
			
"continue"	{return CONTINUE;}
"main"          {return MAIN;}
"println"       {return PRINTLN;}

"+"		|

"-"		{
			symbolInfo *s= new  symbolInfo(yytext, (char *)"ADDOP");
			yylval = s;
			return ADDOP;
		}
[*/%]           {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"MULOP");
			yylval =s;
			return MULOP;
		}

"++"		{       symbolInfo *s= new  symbolInfo(yytext, (char *)"INCOP");
			yylval = s;
			return INCOP;
		}
"--"           {        symbolInfo *s= new  symbolInfo(yytext, (char *)"DECOP");
			yylval = s;
			return DECOP;
		}
		
"<="            |
">="		|
"=="		|
"!="		|
[<>]           {	symbolInfo *s= new  symbolInfo(yytext, (char *)"RELOP");
			yylval = s;
			return RELOP;
		}
"="		{	symbolInfo *s= new  symbolInfo(yytext, (char *)"ASSIGNOP");
			yylval = s;
			return ASSIGNOP;
		}
			
"&&"		|
"||"		{
			symbolInfo *s= new  symbolInfo(yytext, (char *)"LOGICOP");
			yylval = s;
			return LOGICOP;
		}
"!"		{
			symbolInfo *s= new  symbolInfo(yytext, (char *)"NOT");
			yylval = s;
			return NOT;
		}

"("           {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"LPAREN");
			yylval = s;
			return LPAREN;
		}
")"           {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"RPAREN");
			yylval = s;
			return RPAREN;
		}

"{"           {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"LCURL");
			yylval = (YYSTYPE)s;
			return LCURL;
		}
"}"           {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"RCURL");
			yylval = s;
			return RCURL;
		}
"["          {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"LTHIRD");
			yylval = s;
			return LTHIRD;
		}
"]"          {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"RTHIRD");
			yylval = s;
			return RTHIRD;
		}
","           {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"COMMA");
			yylval = s;
			return COMMA;
		}
";"           {
			symbolInfo *s= new  symbolInfo(yytext, (char *)"SEMICOLON");
			yylval = s;
			return SEMICOLON;
		}

{DIGITS} 	{	symbolInfo *s= new  symbolInfo(yytext, (char *)"CONST_INT");
			s->intvalue=atoi(yytext);
			strcpy(s->vtype,"int");
			yylval = s;
			return CONST_INT;
		}
{NUMBER} 	{	symbolInfo *s= new  symbolInfo(yytext, (char *)"CONST_FLOAT");
			s->floatvalue=atof(yytext);
			strcpy(s->vtype,"float");
			yylval = s;
			return CONST_FLOAT;
		}
"'"."'"           |
"'\\n'" 	|
"'\\0'"        |
"'\\t'"        |
"'\\r'"        |
"'\\b'" 	|
"'\\f'"       |
"'\n'"        		{
			symbolInfo *s= new  symbolInfo(yytext, (char *)"CONST_CHAR");
			yylval = s;
			s->charvalue=atoi(yytext);
			strcpy(s->vtype,"char");
			return CONST_CHAR;
		}
[_A-Za-z]({LETTER}|{DIGIT})*	{
			symbolInfo *s= new  symbolInfo(yytext, (char *)"ID");
			yylval = s;
			return ID;
			
		}	

"\"" {    
	str="";	
	a=line_count;
	str=str+yytext;
	BEGIN MYSTATE;
	}
<MYSTATE>[^"\\\n\r]*  { 
		     str=str+yytext;
		   }
<MYSTATE>"\\\n" {line_count++;}
<MYSTATE>{NEWLINE}  {	
			char msg[40];
			sprintf(msg,"<UNFINISHED STRING>  %s ",str.c_str());
			yyerror(msg);
			error_count++;
			line_count++;
			BEGIN INITIAL;
		}
<MYSTATE>"\""  {
		str=str+yytext;
		//fprintf(tokenout,"<STRING,%s>",str.c_str());
		//fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",a,str.c_str());
		BEGIN INITIAL;
		}


"//"[^\n]*	  {
			//fprintf(logout,"Line no %d:TOKEN <COMMENT> Lexeme %s found\n",line_count,yytext);
		}
"/*"   {
	str2="";
	b=line_count;
	str2=str2+yytext;
	BEGIN MYSTATE2;
	}
<MYSTATE2><<EOF>> {
		//fprintf(logout,"Line no %d: <UNFINISHED COMMENT ERROR>  %s found\n",b,str2.c_str());
		char msg[40];
		sprintf(msg,"<UNFINISHED COMMENT>  %s ",str2.c_str());
		yyerror(msg);
		error_count++;
		BEGIN INITIAL;
		}
<MYSTATE2>"*/" {
		str2=str2+yytext;
		//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n",b,str2.c_str());
		BEGIN INITIAL;
		}
<MYSTATE2>{NEWLINE}	{
			line_count++;
			str2=str2+yytext;
		} 
<MYSTATE2>.  {str2=str2+yytext;}

({DIGIT}*"\."{DIGIT}*){2,}   {
				//fprintf(logout,"Line no %d: TOO MANY DECIMAL POINT  %s \n",line_count,yytext);
				char msg[40];
				sprintf(msg,"<TOO MANY DECIMAL POINT>  %s ",yytext);
				yyerror(msg);
				error_count++;
			     }

{DIGITS}(\.{DIGITS})?E[+-]?{DIGITS}?\.[^\n\r]*    {
				//fprintf(logout,"Line no %d: ILL FORMED NUMBER %s \n",line_count,yytext);
				char msg[40];
				sprintf(msg,"<ILL FORMED NUMBER>  %s ",yytext);
				yyerror(msg);
				error_count++;
			     }
{DIGITS}{LETTER}+      |
{NUMBER}{LETTER}+          {
				//fprintf(logout,"Line no %d: INVALID SUFFIX ON NUMERIC CONSTANT ERROR  %s found\n",line_count,yytext);
				char msg[40];
				sprintf(msg,"<INVALID SUFFIX ON NUMERIC CONSTANT>  %s ",yytext);
				yyerror(msg);
				error_count++;
			     }

"'"[^"\n\t\a\f\r\b\v\0\\]{2,}"'"  {
				//fprintf(logout,"Line no %d: ILL FORMED CHARACTER  %s \n",line_count,yytext);
				char msg[40];
				sprintf(msg,"<ILL FORMED CHARACTER>  %s ",yytext);
				yyerror(msg);
				error_count++;
			     }

"'"[^'"\n\t\a\f\r\b\v\0\\]+ {
	//fprintf(logout,"Line no %d: UNDETERMINED CHARACTER FOUND  %s \n",line_count,yytext);
	char msg[40];
	sprintf(msg,"<UNDETERMINED CHARACTER>  %s ",yytext);
	yyerror(msg);
	error_count++;
	}
.   {  
	char msg[40];
	sprintf(msg,"<TOO MANY DECIMAL POINT>  %s ",yytext);
	yyerror(msg);
	//fprintf(logout,"Line no %d: UNDETERMINED CHARACTER FOUND  %s \n",line_count,yytext);
	error_count++;
	}


%%
/*
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
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	fprintf(logout,"total LINES: %d\n",line_count-1);
	fprintf(logout,"total ERRORS: %d\n",error_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
*/
