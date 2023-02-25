/* Compiler Theory and Design
   Duane J. Jarc */

/* This file contains flex input file */

%{
#include <string>
#include <math.h>
#include <cmath>
#include <iostream>

using namespace std;

#include "values.h"
#include "listing.h"
#include "tokens.h"

%}

%option noyywrap

ws		[ \t\r]+
comment		("//"|"--").*\n
line		[\n]
id		[A-Za-z][A-Za-z0-9]*
digit		[0-9]
int		-?{digit}+
real		{digit}+\.{digit}*([Ee][+-]?{digit}+)*
punc		[\(\),:;.]
%%

{ws}		{ ECHO; }
{comment}	{ ECHO; nextLine();}
{line}		{ ECHO; nextLine();}
"<"		{ ECHO; yylval.oper = LESS; return(RELOP); }
"<="     { ECHO; yylval.oper = LESS_EQUAL; return(RELOP); }
">"      { ECHO; yylval.oper = GREATER; return(RELOP); }
">="     { ECHO; yylval.oper = GREATER_EQUAL; return(RELOP); }
"="      { ECHO; yylval.oper = EQUAL; return(RELOP); }
"/="     { ECHO; yylval.oper = NOT_EQUAL; return(RELOP); }
"+"		{ ECHO; yylval.oper = ADD; return(ADDOP); }
"-"      { ECHO; yylval.oper = SUB;return(ADDOP); }
"*"		{ ECHO; yylval.oper = MULTIPLY; return(MULOP); }
"/"      { ECHO; yylval.oper = DIVIDE; return(MULOP); }
"rem"    { ECHO; yylval.oper = REM; return(REMOP); }
"=>"     { ECHO; return(ARROW); }
"**"     { ECHO; return(EXPOP); }
begin		{ ECHO; return(BEGIN_); }
boolean		{ ECHO; return(BOOLEAN); }
end		{ ECHO; return(END); }
endreduce	{ ECHO; return(ENDREDUCE); }
function	{ ECHO; return(FUNCTION); }
integer		{ ECHO; return(INTEGER); }
is		{ ECHO; return(IS); }
reduce		{ ECHO; return(REDUCE); }
returns		{ ECHO; return(RETURNS); }
and		{ ECHO; return(ANDOP); }
case     { ECHO; return(CASE); }
else     { ECHO; return(ELSE); }
endcase     { ECHO; return(ENDCASE); }
if    { ECHO; return(IF); }
then     { ECHO; return(THEN); }
when     { ECHO; return(WHEN); }
endif    { ECHO; return(ENDIF); }
others      { ECHO; return(OTHERS); }
real     { ECHO; return(REAL); }
or    { ECHO; return(OROP); }
not      { ECHO; return(NOTOP); }
true     { ECHO; yylval.value = atof(yytext); return(BOOL_LITERAL); }
false    { ECHO; yylval.value = atof(yytext); return(BOOL_LITERAL); }
{id}		{ ECHO; yylval.iden = (CharPtr)malloc(yyleng + 1); 
			strcpy(yylval.iden, yytext); return(IDENTIFIER);}
{int}		{ ECHO; yylval.value = atoi(yytext); return(INT_LITERAL); }
{real}   { ECHO; yylval.value = atof(yytext); return(REAL_LITERAL); }
{punc}		{ ECHO; return(yytext[0]); }
.		{ ECHO; appendError(LEXICAL, yytext); }

%%
