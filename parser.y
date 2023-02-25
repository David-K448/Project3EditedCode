/* Compiler Theory and Design
   Duane J. Jarc */

%{

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <cmath>
#include <math.h>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);

Symbols<double> symbols;

double*parameters;
int parameterNo = 0;
int parameterCount;

double result;

%}

%define parse.error verbose

%union
{
	CharPtr iden;
	Operators oper;
	double value;
}

%token <iden> IDENTIFIER
%token <value> INT_LITERAL REAL_LITERAL BOOL_LITERAL CASE
%token <oper> ADDOP MULOP RELOP REMOP EXPOP
%token ANDOP OROP NOTOP
%token BEGIN_ BOOLEAN END ENDREDUCE FUNCTION INTEGER IS REDUCE RETURNS
%token THEN ARROW WHEN
%token ELSE IF OTHERS REAL ENDIF ENDCASE
%type <value> body statement_ statement reductions expression binary exponent unary relation term factor primary case cases case_
%type <oper> operator

%%

function:
	function_header optional_variable body{result=$3;};
	
function_header:
	FUNCTION IDENTIFIER parameters RETURNS type ';' |
	FUNCTION IDENTIFIER RETURNS type ';' |
	error ';' ;
	
optional_variable:
	optional_variable variable |
	error ';' |
	;
	
variable:
	IDENTIFIER ':' type IS statement_ {symbols.insert($1, $5);} ;
	
parameters:
	parameter optional_parameter ;
	
optional_parameter:
	optional_parameter ',' parameter |
	;
	
parameter:
	IDENTIFIER ':' type{symbols.insert($1, parameters[parameterNo++]);};
	
type:
	INTEGER| 
	REAL |
	BOOLEAN;
	
body:
	BEGIN_ statement_ END ';' {$$=$2;};
	
statement_:
	statement ';' |
	error ';' {$$= 0;};
	
statement:
	expression |
	REDUCE operator reductions ENDREDUCE {$$ = $3;} |
	IF expression THEN statement_ ELSE statement_ ENDIF {$$= ($2) ? $4 : $6;} |
	CASE expression IS cases OTHERS ARROW statement_ ENDCASE {$$=isnan($4) ? $7: $4;} ;
	
cases:
	cases case_ {$$ =isnan($1) ? $2 : $1;} |
	{$$=NAN;};
	
case_:
	case |
	error ';' {$$= 0;};
	
case:
	WHEN INT_LITERAL ARROW statement_ {$$ =$<value>-2==$2 ? $4 : NAN;} ;
	
operator:
	ADDOP |
	RELOP |
	MULOP |
	EXPOP ;
	
reductions:
	reductions statement_ {$$ = evaluateReduction($<oper>0, $1, $2);} |
	{$$ = $<oper>0 == ADD ? 0 : 1;};
	
expression:
	expression OROP binary {$$ = $1 || $3;} |
	binary;
	
binary:
	binary ANDOP relation {$$ =$1 && $3;} |
	relation ;
	
relation:
	relation RELOP term {$$ = evaluateRelational($1, $2, $3);} |
	term ;
	
term:
	term ADDOP factor {$$ = evaluateArithmetic($1, $2, $3);} |
	factor ;
	
factor:
	factor MULOP exponent {$$ = evaluateArithmetic($1, $2, $3);} |
	factor REMOP exponent {$$ = evaluateArithmetic($1, $2, $3);} |
	exponent ;

exponent:
	unary |
	unary EXPOP exponent {$$ = pow($1, $3);};
	
unary:
	NOTOP primary {$$ = !$2;} |
	primary;
	
primary:
	'(' expression ')' {$$ = $2;} |
	INT_LITERAL |
	REAL_LITERAL | 
	BOOL_LITERAL |
	IDENTIFIER {if (!symbols.find($1, $$)) appendError(UNDECLARED, $1);} ;

%%

void yyerror(const char* message)
{
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[])    
{
	parameters= new double[argc-1];
	parameterCount = argc - 1;
	for(int i=1; i < argc;++i)
	{
		parameters[i-1]= atof(argv[i]);
	}
	
	firstLine();
	yyparse();
	if (lastLine() == 0)
		cout << "Compiled Successfully" << endl;
		cout << "Result = " << result << endl;
	return 0;
} 
