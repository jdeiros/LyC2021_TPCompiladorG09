%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include <stdbool.h>
	#include <string.h>
	#include <float.h>
	#include "y.tab.h"
	#include "constantes.h"
	#include "funciones.h"
%}

%option noyywrap
%option yylineno

DIGITO_CON_CERO			[0-9]
DIGITO_SIN_CERO			[1-9]
LETRA					[a-zA-Z]
ID						{LETRA}({LETRA}|{DIGITO_CON_CERO}|_)*
CONST_INT				"-"{DIGITO_SIN_CERO}+|{DIGITO_CON_CERO}+
CONST_REAL				"-"{DIGITO_CON_CERO}+"."{DIGITO_CON_CERO}*|{DIGITO_CON_CERO}*"."{DIGITO_CON_CERO}+|{DIGITO_CON_CERO}+"."{DIGITO_CON_CERO}*
CONST_STR          		"\""({CARACTER}|{ESPACIO})*"\""
CARACTER        		[a-z,A-Z,0-9,=,>,<,!,:,+,-,*,/,@]
ESPACIO         		[" "]
A_COMENTARIO			"*/"
C_COMENTARIO			"/*"
CONTENIDO				[a-zA-Z0-9 "",=,>,<,!,:,+,-,*,/,@]*
COMENTARIO 				{A_COMENTARIO}{CONTENIDO}{C_COMENTARIO}
COMENTARIO_ANIDADO		{A_COMENTARIO}({COMENTARIO}|{CONTENIDO})*?{C_COMENTARIO}

%%

if|IF					{ return IF; }
then|THEN				{ return THEN; }
else|ELSE				{ return ELSE; }
endif|ENDIF				{ return ENDIF; }
while|WHILE				{ return WHILE; }
get|GET 				{ return GET; }
display|DISPLAY 		{ return DISPLAY; }
dim|DIM 				{ return DIM; }
as|AS 					{ return AS; }
for|FOR 				{ return FOR; }
next|NEXT				{ return NEXT; }
to|TO					{ return TO; }
equmax|EQUMAX 			{ return EQUMAX; }
equmin|EQUMIN			{ return EQUMIN; }

integer|INTEGER			{ return INT; }
real|REAL				{ return FLOAT; }
string|STRING			{ return STRING; }

"+"						{ return OP_SUM; }
"-"						{ return OP_RES; }
"/"						{ return OP_DIV; }
"*"						{ return OP_MUL; }
":="					{ return OP_ASIG; }
"="						{ return OP_IGUAL; }

","						{ return CAR_COMA; }
";"						{ return CAR_PYC; }
"("						{ return CAR_PA; }
")"						{ return CAR_PC; }
"["						{ return CAR_CA; }
"]"						{ return CAR_CC; }
"{"						{ return CAR_LA; }
"}"						{ return CAR_LC; }
">"						{ return CMP_MAYOR; }
"<"						{ return CMP_MENOR; }
">="					{ return CMP_MAYORIGUAL; }
"<="					{ return CMP_MENORIGUAL; }
"!="					{ return CMP_DISTINTO; }
"=="					{ return CMP_IGUAL; }
"&&"					{ return AND; }
"||"					{ return OR; }
"!"						{ return NOT; }

{ID} 					{   yylval.stringValue = strdup(yytext);
							printf("debug::::::> inserto valor %s en TS lo hago como tipo: %d\n",yylval.stringValue, T_ID);
							mostrarTablaSimbolos();
							insertarTablaSimbolos(yylval.stringValue, T_ID, "", 0);
							return ID; }
{CONST_INT}				{
							if (atoi(yytext) > COTA_INT) {
								printf( "El entero ingresado supera la cantidad maxima permitida. Cantidad: %d\n", COTA_INT);
								exit(1);
							}
							insertarTablaSimbolos(indicarNombreConstante(strdup(yytext)), T_CTE_INTEGER, strdup(yytext), 0);
							mostrarTablaSimbolos();
							yylval.intValue = strdup(yytext); 
							printf( "Entero en lexico: %d\n", yylval.intValue); 
							return CONST_INT;
						}
{CONST_REAL}      		{
							float auxf = atof(yytext);
							if (auxf < FLT_MIN) {
								printf( "El flotante ingresado es inferior a la cantidad minima permitida. Cantidad MIN: %f\n", FLT_MIN);
								exit(1);
							}  
							
							if (auxf > FLT_MAX) {
								printf( "El flotante ingresado supera a la cantidad maxima permitida. Cantidad MAX: %f \n", FLT_MAX);
								exit(1);
							}  
							
							yylval.floatValue = strdup(yytext);
							char * aux = indicarNombreConstante(strdup(yytext));
							reemplazarCaracter(aux);
							insertarTablaSimbolos(aux, T_CTE_FLOAT, strdup(yytext), 0);
							printf( "String en lexico: %s\n", yylval.floatValue); 
							return CONST_REAL;
						}
{CONST_STR}    			{	
					        if (strlen(yytext) > COTA_STR) { 
							    printf( "El string ingresado supera la cantidad maxima permitida. Cantidad: %d\n", COTA_STR);
								exit(1);
					        } else {
							    yylval.stringValue = strdup(yytext);
								printf( "String en lexico: %s\n", yylval.stringValue);
								char * aux = indicarNombreConstanteString(yylval.stringValue);
								reemplazarCaracter(aux);
								insertarTablaSimbolos(aux, T_CTE_STRING, strdup(yytext), strlen(yylval.stringValue));
								return CONST_STR; 
					        }
						}

{COMENTARIO}
<<EOF>> 				{tsCrearArchivo(); yyterminate();}
"\n"
"\r\n"
"\t"
" "
.						{ printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit(18); }

%%