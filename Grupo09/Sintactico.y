%{
	#include <stdio.h>
	#include <conio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <math.h>
	#include "y.tab.h"
	#include "funciones.h"

	extern int yylineno;
	FILE *yyin;
	char *yyltext;
	char *yytext;
	int yyparse();
	
	int yylex();
	int yyerror();
	
%}

%union{

    char *intValue;
    char *floatValue;
    char *stringValue;
}

//Start Symbol
%start programa

//Tokens
%token IF
%token THEN
%token ELSE
%token ENDIF
%token WHILE
%token FOR
%token NEXT
%token TO
%token ECUMIN
%token ECUMAX
%token GET
%token DISPLAY
%token DECVAR
%token ENDDEC

%token INT
%token FLOAT
%token STRING

%token OP_SUM
%token OP_RES
%token OP_DIV
%token OP_MUL
%token OP_ASIG
%token OP_IGUAL
%token OP_DOSP
%token CAR_COMA
%token CAR_PYC
%token CAR_PA
%token CAR_PC
%token CAR_CA
%token CAR_CC
%token CAR_LA
%token CAR_LC
%token CMP_MAYOR
%token CMP_MENOR
%token CMP_MAYORIGUAL
%token CMP_MENORIGUAL
%token CMP_DISTINTO
%token CMP_IGUAL
%token AND
%token OR
%token NOT

%token <stringValue>ID
%token <stringValue>CONST_INT
%token <stringValue>CONST_REAL
%token <stringValue>CONST_STR

//Definicion de la gramatica
%%
programa: {printf("INICIO PROGRAMA\n");}
	declaracion_var {printf("INICIO SENTENCIAS\n");} 
	sentencias {printf("FIN SENTENCIAS\n"); mostrarTablaSimbolos();}

declaracion_var: 
	DECVAR {printf("DECVAR\n");} 
	lista_de_declaracion_de_tipos 
	ENDDEC {printf("ENDDEC\n");}

lista_de_declaracion_de_tipos:
	lista_de_declaracion_de_tipos linea_declaracion

lista_de_declaracion_de_tipos: 
	linea_declaracion

linea_declaracion: 
	lista OP_DOSP {printf("OPERADOR : \n");} declaracion_tipo

lista:
	lista CAR_COMA {printf(", \n");} ID {printf("ID \n");}

lista:
	ID {printf("ID \n");}

declaracion_tipo:
	INT 		{actualizarTipoDato(T_INT); printf("INT \n");}|
	FLOAT 		{actualizarTipoDato(T_FLOAT); printf("FLOAT \n");}|
	STRING 		{actualizarTipoDato(T_STRING); printf("STRING \n");}

sentencias:
	sentencias operacion {printf("FIN OPERACION \n");}

sentencias:
	operacion

operacion:
	operacion_if 		{printf("IF \n");}|
	iteracion_while  	{printf("WHILE \n");}|
	iteracion_for		{printf("FOR \n");}|
	operacion_ecumax	{printf("ECUMAX \n");}|
	operacion_ecumin	{printf("ECUMIN \n");}|
	asignacion			{printf("ASIGNACION \n");}|
	entrada_salida		{printf("IN / OUT \n");}

operacion_if:
	IF CAR_PA condiciones CAR_PC then_ CAR_LA sentencias CAR_LC

operacion_if:
	IF CAR_PA condiciones CAR_PC then_ CAR_LA sentencias CAR_LC else_ CAR_LA sentencias CAR_LC

then_:
	THEN

else_:
	ELSE

iteracion_while:
	WHILE CAR_PA condiciones CAR_PC CAR_LA sentencias CAR_LC 

iteracion_for:
	FOR ID OP_ASIG expresion TO expresion NEXT ID |
	FOR ID OP_ASIG expresion TO expresion CAR_CA constante CAR_CC NEXT ID
	
operacion_ecumax:
	ECUMAX CAR_PA expresion CAR_PYC CAR_CA lista_variables CAR_CC CAR_PC
	
operacion_ecumin:
	ECUMIN CAR_PA expresion CAR_PYC CAR_CA lista_variables CAR_CC CAR_PC

lista_variables:
	factor CAR_COMA lista_variables |
	factor
	
condiciones:
	condicion 						|
	NOT condicion 					|
	condicion	AND  condicion 		|
	condicion OR condicion  

condicion:
	expresion operador expresion 


operador:
	CMP_IGUAL 		|
	CMP_DISTINTO 	| 
	CMP_MENOR 		|
	CMP_MAYOR 		| 
	CMP_MENORIGUAL 


asignacion:	
	ID OP_ASIG expresion 

expresion:
	expresion OP_RES termino 	|
	expresion OP_SUM termino 	|
	termino

termino:
	termino OP_MUL factor 	|	
	termino OP_DIV factor 	|
	factor

factor:
	ID 			| 
	constante 

constante:
	CONST_INT	|
	CONST_REAL	|
	CONST_STR

entrada_salida:
	GET ID 			|
	DISPLAY ID 		|
	DISPLAY CONST_STR 

%%

int main(int argc,char *argv[])
{
	if ((yyin = fopen(argv[1], "rt")) == NULL) {
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
    }
    else {
        yyparse();
    }
    fclose(yyin);

    printf("\n\n* COMPILACION EXITOSA *\n");
	return 0;
}

int yyerror() {
	printf("Error sintatico \n");
	system("Pause");
	exit(1);
}

