%{
	#include <stdio.h>
	#include <conio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <math.h>
	#include "y.tab.h"
	#include "funciones.h"
	
	const char salto[6][4] = {
		{"BGE"}, // menor
		{"BGT"}, // menor igual
		{"BLE"}, //mayor
		{"BLT"}, //mayor igual
		{"BEQ"}, // distinto
		{"BNE"}, //igual
	};

	const char salto_contrario[6][4] = {
		{"BLT"}, // menor
		{"BLE"}, // menor igual
		{"BGT"}, //mayor
		{"BGE"}, //mayor igual
		{"BEQ"}, // distinto
		{"BNE"}, //igual
	};

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
%token EQUMIN
%token EQUMAX
%token GET
%token DISPLAY
%token DIM
%token AS

%token INT
%token FLOAT
%token STRING

%token OP_SUM
%token OP_RES
%token OP_DIV
%token OP_MUL
%token OP_ASIG
%token OP_IGUAL

%token CAR_COMA
%token CAR_PYC
%token CAR_PA
%token CAR_PC
%token CAR_CA
%token CAR_CC
%token CAR_LA
%token CAR_LC
%token <intValue>CMP_MAYOR
%token <intValue>CMP_MENOR
%token <intValue>CMP_MAYORIGUAL
%token <intValue>CMP_MENORIGUAL
%token <intValue>CMP_DISTINTO
%token <intValue>CMP_IGUAL
%token <intValue>AND
%token <intValue>OR
%token <intValue>NOT

%token <stringValue>ID
%token <stringValue>CONST_INT
%token <stringValue>CONST_REAL
%token <stringValue>CONST_STR

//Definicion de la gramatica
%%
programa: {printf("INICIO PROGRAMA\n");}
	declaracion_var {printf("INICIO SENTENCIAS\n");} 
	sentencias {printf("FIN SENTENCIAS\n"); }

declaracion_var: 
	DIM {printf("DIM ");} 
	CMP_MENOR {printf(" < ");}
	lista_declaracion_var
	CMP_MAYOR {printf(" > ");}
	AS {printf("AS\n");}
	CMP_MENOR {printf(" < ");}
	lista_declaracion_tipos 
	CMP_MAYOR {printf(" > ");}

lista_declaracion_var:
	lista_declaracion_var CAR_COMA ID {printf(" id ");} |
	ID {printf(" id1 ");}

lista_declaracion_tipos:
	lista_declaracion_tipos CAR_COMA declaracion_tipo |
	declaracion_tipo

declaracion_tipo:
	INT 		{actualizarTipoDato(T_INT); printf("integer ");}|
	FLOAT 		{actualizarTipoDato(T_FLOAT); printf("real ");}|
	STRING 		{actualizarTipoDato(T_STRING); printf("STRING ");}

sentencias:
	sentencias operacion {printf("FIN OPERACION \n");}

sentencias:
	operacion

operacion:
	operacion_if 		{printf("IF \n");}|
	iteracion_while  	{printf("WHILE \n");}|
	iteracion_for		{printf("FOR \n");}|
	operacion_equmax	{printf("EQUMAX \n");}|
	operacion_equmin	{printf("EQUMIN \n");}|
	asignacion			{printf("ASIGNACION \n");} |
	entrada_salida		{printf("IN / OUT \n");}

operacion_if:
	IF CAR_PA condiciones CAR_PC then_ CAR_LA sentencias CAR_LC {
               int i, iCmp, terceto_condicion, segunda_condicion, cant_condiciones=1;
			   char condicion[7], destino[7];
			   int tipo_condicion = sacar_pila (&pila_condicion);
			   if ( tipo_condicion==COND_AND || tipo_condicion==COND_OR ){
				   cant_condiciones = 2;
			   } 
			   /* Modifico los tercetos temporales de las condiciones */
			   for (i=0; i<cant_condiciones; i++){
				   iCmp = sacar_pila (&comparacion);
				   terceto_condicion = sacar_pila (&pila);
				   
				   sprintf(condicion, "[%d]", terceto_condicion-1);
				   printf("condicion: %s\n",condicion);
				   
				   sprintf(destino, "[%d]", atoi($<stringValue>7)+1);
				   printf("destino: %s\n", destino);
				   
				   /* Si es OR y la primera condicion se cumple debe saltar al inicio del then */
				   if (tipo_condicion==COND_OR && i==1){
					   sprintf(destino, "[%d]", segunda_condicion+1);
					   printf("destino segunda condicion: %s\n", destino);

					   tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp], condicion, destino);
				   } else if (tipo_condicion==COND_NOT){
					   /* Si es NOT, produce el salto cuando se cumple la condicion */
					   tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp], condicion, destino);
				   } else {
					   segunda_condicion = terceto_condicion;
					   tercetos[terceto_condicion] = _crear_terceto(salto[iCmp], condicion, destino);
				   }
			   }
               $<stringValue>$ =string_from_cte(atoi( $<stringValue>7)+1);
           }

operacion_if:
	IF CAR_PA condiciones CAR_PC then_ CAR_LA sentencias CAR_LC {
               int i, iCmp, terceto_condicion, segunda_condicion, cant_condiciones=1;
			   char condicion[7], destino[7];
			   int tipo_condicion = sacar_pila (&pila_condicion);
			   if ( tipo_condicion==COND_AND || tipo_condicion==COND_OR ){
				   cant_condiciones = 2;
			   } 
			   /* Modifico los tercetos temporales de las condiciones */
			   for (i=0; i<cant_condiciones; i++){
				   iCmp = sacar_pila (&comparacion);
				   terceto_condicion = sacar_pila (&pila);
				   
				   sprintf(condicion, "[%d]", terceto_condicion-1);
				   printf("condicion: %s\n",condicion);
				   
				   sprintf(destino, "[%d]", atoi($<stringValue>7)+2);
				   printf("destino: %s\n", destino);
				   
				   /* Si es OR y la primera condicion se cumple debe saltar al inicio del then */
				   if (tipo_condicion==COND_OR && i==1){
					   sprintf(destino, "[%d]", segunda_condicion+1);
					   printf("destino segunda condicion: %s\n", destino);

					   tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp], condicion, destino);
				   } else if (tipo_condicion==COND_NOT){
					   /* Si es NOT, produce el salto cuando se cumple la condicion */
					   tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp], condicion, destino);
				   } else {
					   segunda_condicion = terceto_condicion;
					   tercetos[terceto_condicion] = _crear_terceto(salto[iCmp], condicion, destino);
				   }
			   }
			   insertar_pila(&pila, crear_terceto("###", NULL, NULL)); /* guardo fin_then para el else */
               $<stringValue>$ =string_from_cte(atoi( $<stringValue>7));
           }
		   else_ {
               // creo un terceto temporal donde colocare el salto del then
               //int fin_then = crear_terceto("Temporal", NULL, NULL);
               //insertar_pila (&pila, fin_then);
           }
		   CAR_LA sentencias CAR_LC {
				// creo el salto al ultimo terceto del else
				int fin_then = sacar_pila (&pila);
				char destino[7];
				sprintf(destino, "[%d]", string_from_cte(atoi($<stringValue>13)+1));
				tercetos[fin_then] = _crear_terceto("BI", destino, NULL);
				$<stringValue>$ = string_from_cte(atoi($<stringValue>13)+1);
           }

then_:
	THEN

else_:
	ELSE

iteracion_while:
	WHILE {
		insertar_pila (&pila, cant_tercetos); //apilo nro celda actual
	} CAR_PA condiciones CAR_PC CAR_LA sentencias CAR_LC {
		int i, iCmp, terceto_condicion, segunda_condicion, cant_condiciones=1;
		char condicion[7], destino[7];
		int tipo_condicion = sacar_pila (&pila_condicion);
		if ( tipo_condicion==COND_AND || tipo_condicion==COND_OR ){
			cant_condiciones = 2; /* Solo se permite comparacion entre dos condiciones simple */
		} 
		int fin_while = crear_terceto("BI", NULL, NULL); /* Terceto temporal para fin del while */
		/* Modifico los tercetos temporales de las condiciones */
		for (i=0; i<cant_condiciones; i++){
			iCmp = sacar_pila (&comparacion);
			terceto_condicion = sacar_pila (&pila);
			sprintf(condicion, "[%d]", terceto_condicion-1);
			sprintf(destino, "[%d]", fin_while + 1);
			/* Si es OR y la primera condicion se cumple debe saltar al inicio del then */
			if (tipo_condicion==COND_OR && i==1){
				sprintf(destino, "[%d]", segunda_condicion+1);
				tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp],condicion,destino);
			} else if (tipo_condicion==COND_NOT){
				/* Si es NOT, produce el salto cuando se cumple la condicion */
				tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp],condicion,destino);
			} else {
				segunda_condicion = terceto_condicion;
				tercetos[terceto_condicion] = _crear_terceto(salto[iCmp],condicion,destino);
			}
		}

		/* obtengo terceto de inicio de condicion */
		int inicio_condicion= sacar_pila (&pila);
		char tmp0[7];
		// fin del while, completar salto incondicional al inicio condicion
		sprintf(tmp0, "[%d]", inicio_condicion);
		tercetos[fin_while]= _crear_terceto("BI", tmp0, NULL);		
		itoa(fin_while, $<stringValue>$, 10); //coloco nro terceto fin while
	}

iteracion_for:
	FOR ID OP_ASIG expresion TO expresion NEXT ID |
	FOR ID OP_ASIG expresion TO expresion CAR_CA constante CAR_CC NEXT ID
	
operacion_equmax:
	EQUMAX CAR_PA expresion CAR_PYC CAR_CA lista_variables CAR_CC CAR_PC
	
operacion_equmin:
	EQUMIN CAR_PA expresion CAR_PYC CAR_CA lista_variables CAR_CC CAR_PC

lista_variables:
	factor CAR_COMA lista_variables |
	factor
	
condiciones:
	condicion {
				insertar_pila (&pila, crear_terceto("###",NULL,NULL));
				insertar_pila (&pila_condicion, COND_SIMPLE);
			  } |
	NOT condicion {
					insertar_pila (&pila, crear_terceto("###",NULL,NULL));
					insertar_pila (&pila_condicion, COND_NOT);
				  } |
	condicion {
				insertar_pila (&pila, crear_terceto("###",NULL,NULL)); 
			  } AND  condicion {
				insertar_pila (&pila, crear_terceto("###",NULL,NULL)); 
				insertar_pila (&pila_condicion, COND_AND);
			  }	|
	condicion  {
				insertar_pila (&pila, crear_terceto("###",NULL,NULL)); 
			  } OR condicion  {
				insertar_pila (&pila, crear_terceto("###",NULL,NULL)); 
				insertar_pila (&pila_condicion, COND_OR);
			  }

condicion:
	expresion operador expresion {
		/* aviso que operacion hay que hacer */
        insertar_pila(&comparacion, atoi($<intValue>2));
        $<stringValue>$ = str_terceto_number(crear_terceto("CMP", $<stringValue>1, $<stringValue>3)); 
	}

operador:
	CMP_IGUAL 		{$<intValue>$ = string_from_cte(CTE_CMP_IGUAL);}|
	CMP_DISTINTO 	{$<intValue>$ = string_from_cte(CTE_CMP_DISTINTO);}|
	CMP_MENOR 		{$<intValue>$ = string_from_cte(CTE_CMP_MENOR);}|
	CMP_MAYOR 		{$<intValue>$ = string_from_cte(CTE_CMP_MAYOR);}|
	CMP_MENORIGUAL 	{$<intValue>$ = string_from_cte(CTE_CMP_MENOR_IGUAL);}|
	CMP_MAYORIGUAL 	{$<intValue>$ = string_from_cte(CTE_CMP_MAYOR_IGUAL);}


asignacion:	
	ID OP_ASIG expresion {$<stringValue>$ = str_terceto_number(crear_terceto(":=", $<stringValue>1, $<stringValue>3)); }

expresion:
	expresion OP_RES termino 	 {$<stringValue>$ = str_terceto_number(crear_terceto("+", $<stringValue>1, $<stringValue>3)); }|
	expresion OP_SUM termino 	 {$<stringValue>$ = str_terceto_number(crear_terceto("+", $<stringValue>1, $<stringValue>3)); }|
	termino

termino:
	termino OP_MUL factor 	{$<stringValue>$ = str_terceto_number(crear_terceto("*", $<stringValue>1, $<stringValue>3)); }|	
	termino OP_DIV factor 	{$<stringValue>$ = str_terceto_number(crear_terceto("/", $<stringValue>1, $<stringValue>3)); }|
	factor

factor:
	ID 		  		| 
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
	init();

	if ((yyin = fopen(argv[1], "rt")) == NULL) {
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
    }
    else {
        yyparse();
    }
    fclose(yyin);
	
    // libero memoria de tercetos
    printf("\n\n* COMPILACION EXITOSA *\n");

	// guardo coleccion de tercetos en archivo
    if (!sintaxis_error) {
        escribir_tercetos(intermedia);
		printf("Mostrando tercetos guardados: \n");
        escribir_tercetos(stdout);
		mostrarTablaSimbolos();
    }
	// libero memoria de tercetos
    limpiar_tercetos();
	return 0;
}

int yyerror() {
	printf("Error sintatico \n");
	system("Pause");
	sintaxis_error = 1;
	exit(1);
}