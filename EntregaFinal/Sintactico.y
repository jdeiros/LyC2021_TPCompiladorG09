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

	enum enum_equmax_equmin {
		equmax_enum = 0, 
		equmin_enum = 1
	} enum_equmax_equmin;

	//Variables para declaraciones
	char* pila_declaraciones[30];
	int tope_pila_declaraciones = 0;

	//variables globales
	int tipoDatoVarA, tipoDatoVarB, esOperacionMOD=0;
	
	int EQind = -1;	//indice para equmax_equmin
	int Xind = -1; 	//indice para Salto en equmax_equmin
	int Eind = -1; 	//indice para Expresion
	int Find = -1; 	//indice para Factor
	int Tind = -1; 	//indice para Termino

	// int contador_tiempos_debug = 0;

	/*  codigo assembler */
	FILE *pfASM; //Final.asm
	typedef struct s_elemento {
	    char* nombre;
		char* tipo;
	    char* valor;
	}t_elemento;

	typedef struct {
	    char nombre[100];
		char tipo[100];
	    char valor[100];
	    char longitud[100];
	}t_lineaTs;

	//funciones assembler
	void generarASM();
	void generarEncabezado();
	void generarDatos();
	void generarCodigo();
	int informeError(char *);
	char* obtenerTipoTS(char*);

	char* pila_operandos[100];
	int tope_pila_operando = 0;

	#define TAM_PILA 100
	#define STR_VALUE 1024

	// char etiqueta[COTA_STR];
	// Variables para el funcionamiento de operaciones if, while
	char* pila_etiquetas[100];
	int tope_pila_etiquetas = 0;
	int contador_operaciones = 0;
	int nro_etiqueta;
	char sEtiqueta[30];
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
	sentencias {
		generarASM();
		printf("Fin del parsing!\n");
		printf("FIN SENTENCIAS\n"); 
	}

declaracion_var: 
	DIM 
	CMP_MENOR 
	lista_declaracion_var
	CMP_MAYOR 
	AS
	CMP_MENOR 
	lista_declaracion_tipos 
	CMP_MAYOR

lista_declaracion_var:
	lista_declaracion_var CAR_COMA ID {
		if(buscarDatoDePila(pila_declaraciones, &tope_pila_declaraciones, $<stringValue>3)) {
			printf("Error :: Variable %s ya declarada.\n", yylval.stringValue);
			system("pause");
			exit(1);
		} else {
			apilar(yylval.stringValue, pila_declaraciones, &tope_pila_declaraciones);
		}
	} |
	ID {	
			if(buscarDatoDePila(pila_declaraciones, &tope_pila_declaraciones, yylval.stringValue)) {
				printf("Error :: Variable %s ya declarada.\n", yylval.stringValue);
				system("pause");
				exit(1);
			} else {
				apilar(yylval.stringValue, pila_declaraciones, &tope_pila_declaraciones);
			}
	}

lista_declaracion_tipos:
	lista_declaracion_tipos CAR_COMA declaracion_tipo |
	declaracion_tipo

declaracion_tipo:
	INT 		{
		actualizarTipoDato(T_INT); 
		// printf("[%d] debug: declaracion de tipos\n", contador_tiempos_debug++);
	}|
	FLOAT 		{
		actualizarTipoDato(T_FLOAT); 
		// printf("[%d] debug: declaracion de tipos\n", contador_tiempos_debug++);
	}|
	STRING 		{
		actualizarTipoDato(T_STRING); 
		// printf("[%d] debug: declaracion de tipos\n", contador_tiempos_debug++);
	}

sentencias:
	sentencias operacion {printf("FIN OPERACION \n"); }

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
               int i, iCmp, terceto_condicion, segunda_condicion, cant_condiciones=1, fin_if;
			   
			   char condicion[7], destino[7], etiq[10];
			   int tipo_condicion = sacar_pila (&pila_condicion);

			   if ( tipo_condicion == COND_AND || tipo_condicion == COND_OR )
			   {
				   cant_condiciones = 2;
			   }

			   //int fin_if = cant_tercetos; /* Terceto temporal para fin del if */
			   sprintf(etiq, "IF_%d", cant_tercetos);
			   fin_if = crear_terceto("#ETIQUETA",etiq,NULL);

			   /* Modifico los tercetos temporales de las condiciones */
			   for (i=0; i < cant_condiciones; i++){
				   iCmp = sacar_pila (&comparacion);
				   terceto_condicion = sacar_pila (&pila);
				   
				   sprintf(condicion, "[%d]", terceto_condicion-1);
				   printf("condicion: %s\n",condicion);

				   sprintf(destino, "[%d]", fin_if);
				   printf("destino: %s\n", destino);
				   
				   /* Si es OR y la primera condicion se cumple debe saltar al inicio del then 
				   	  (por eso se inverte el salto: salto_contrario me da el salto al interior del if)
				   */
				   if (tipo_condicion==COND_OR && i==1){
					   sprintf(destino, "[%d]", segunda_condicion+1);
					   printf("destino segunda condicion: %s\n", destino);

					   tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp], destino, NULL);
					   
					//    sprintf(etiqueta, "saltoDeIF_%d", terceto_number(destino));
					//    crear_terceto(etiqueta,NULL,NULL);
				   } 
				   else
				   { 
					   	/* Si es NOT, produce el salto cuando se cumple la condicion */
				   		if (tipo_condicion==COND_NOT){					   		
					   		tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp], destino, NULL);

							// sprintf(etiqueta, "saltoDeIF_%d", terceto_number(destino));
							// crear_terceto(etiqueta,NULL,NULL);
				   		} 
						else 
						{
					   		segunda_condicion = terceto_condicion;
					   		tercetos[terceto_condicion] = _crear_terceto(salto[iCmp], destino, NULL);

							// sprintf(etiqueta, "saltoDeIF_%d", terceto_number(destino));
							// crear_terceto(etiqueta,NULL,NULL);
				   		}
				   }
			   }
               $<stringValue>$ = string_from_cte(atoi( $<stringValue>7)+1);
			   itoa(fin_if, $<stringValue>$, 10);
           }

operacion_if:
	IF CAR_PA condiciones CAR_PC then_ CAR_LA sentencias CAR_LC {
               int i, iCmp, terceto_condicion, segunda_condicion, cant_condiciones=1, fin_if;
			   char condicion[7], destino[7],etiq[10];

			   int tipo_condicion = sacar_pila (&pila_condicion);
			   if ( tipo_condicion==COND_AND || tipo_condicion==COND_OR ){
				   cant_condiciones = 2;
			   } 
			   
			   //int fin_if = cant_tercetos; /* Terceto temporal para fin del if */
			   //sprintf(etiq, "IF_%d", cant_tercetos);
			   //fin_if = crear_terceto("#ETIQUETA",etiq,NULL);

			   /* Modifico los tercetos temporales de las condiciones */
			   for (i=0; i<cant_condiciones; i++){
					iCmp = sacar_pila (&comparacion);
					terceto_condicion = sacar_pila (&pila);
					
					sprintf(condicion, "[%d]", terceto_condicion-1);
					printf("condicion: %s\n",condicion);
					
					sprintf(destino, "[%d]", cant_tercetos+1);
					printf("destino: %s\n", destino);
									
					/* Si es OR y la primera condicion se cumple debe saltar al inicio del then */
					if (tipo_condicion==COND_OR && i==1){
						sprintf(destino, "[%d]", segunda_condicion+1);
						printf("destino segunda condicion: %s\n", destino);

						tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp], destino, NULL);
					} else if (tipo_condicion==COND_NOT){
						/* Si es NOT, produce el salto cuando se cumple la condicion */
						tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp], destino, NULL);
					} else {
						segunda_condicion = terceto_condicion;
						tercetos[terceto_condicion] = _crear_terceto(salto[iCmp], destino, NULL);
					}
			   }
			   //insertar_pila(&pila, crear_terceto("###", NULL, NULL)); /* guardo fin_then para el else */
               $<stringValue>$ =string_from_cte(atoi( $<stringValue>7)+1);
           }
		   else_ {
               // creo un terceto temporal donde colocare el salto del then
               int fin_then = crear_terceto("BI", NULL, NULL);
               insertar_pila (&pila, fin_then);
           }
		   CAR_LA sentencias CAR_LC {
				// creo el salto al ultimo terceto del else
				int fin_then = sacar_pila (&pila);
				char destino[7],etiq[10];
				sprintf(destino, "[%d]", cant_tercetos);
				tercetos[fin_then] = _crear_terceto("BI", destino, NULL);
				
				sprintf(etiq, "IF_%d", cant_tercetos);
			   	tercetos[cant_tercetos] = _crear_terceto("#ETIQUETA",etiq,NULL);
				
				itoa(fin_then, $<stringValue>$, 10);
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
				tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp],destino, NULL);
			} else if (tipo_condicion==COND_NOT){
				/* Si es NOT, produce el salto cuando se cumple la condicion */
				tercetos[terceto_condicion] = _crear_terceto(salto_contrario[iCmp],destino, NULL);
			} else {
				segunda_condicion = terceto_condicion;
				tercetos[terceto_condicion] = _crear_terceto(salto[iCmp],destino, NULL);
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
	FOR ID OP_ASIG expresion TO expresion  {
		crear_terceto(":=", "@iterfor", $<stringValue>4);
		crear_terceto(":=", "@forend", $<stringValue>6);
		crear_terceto("CMP", "@iterfor", "@forend");
		insertar_pila (&pila, cant_tercetos); //apilo nro celda actual para volver a cmp
		crear_terceto("BGE", NULL, NULL);		
	} 
	sentencias NEXT ID {
		crear_terceto(":=", "@iterfor", str_terceto_number(crear_terceto("+", "@iterfor", "1")));
		int terc_cond =sacar_pila (&pila);
		int terc_cmp = terc_cond-1;
		crear_terceto("BI", str_terceto_number(terc_cmp), NULL);
		tercetos[terc_cond] =  _crear_terceto("BGE", str_terceto_number(cant_tercetos), NULL);
	} |

	FOR ID OP_ASIG expresion TO expresion {
		crear_terceto(":=", "@iterfor", $<stringValue>4);
		crear_terceto(":=", "@forend", $<stringValue>6);
		crear_terceto("CMP", "@iterfor", "@forend");
		insertar_pila (&pila, cant_tercetos); //apilo nro celda actual para volver a cmp
		crear_terceto("BGE", NULL, NULL);		
	}
	CAR_CA constante CAR_CC sentencias NEXT ID {
		/* en $<stringValue>10 tengo el valor de la [step cte] */
		crear_terceto(":=", "@iterfor", str_terceto_number(crear_terceto("+", "@iterfor", $<stringValue>10))); 
		int terc_cond =sacar_pila (&pila);
		int terc_cmp = terc_cond-1;
		crear_terceto("BI", str_terceto_number(terc_cmp), NULL);
		tercetos[terc_cond] =  _crear_terceto("BGE", str_terceto_number(cant_tercetos), NULL);
	}
	
operacion_equmax:
	EQUMAX { enum_equmax_equmin = equmax_enum;} CAR_PA expresion {
		crear_terceto(":=", "@expr", str_terceto_number(Eind));
	} CAR_PYC CAR_CA lista_variables CAR_CC CAR_PC 
	
operacion_equmin:
	EQUMIN  { enum_equmax_equmin = equmin_enum;} CAR_PA expresion {		
		crear_terceto(":=", "@expr", str_terceto_number(Eind));
	} CAR_PYC CAR_CA lista_variables CAR_CC CAR_PC

lista_variables:
	factor CAR_COMA lista_variables {
		char Xind4[7];
		switch(enum_equmax_equmin)
		{
			case equmin_enum:
				Xind = crear_terceto(":=", "@aux", $<stringValue>1);
				EQind = crear_terceto("CMP", "@aux", "@min");				
				sprintf(Xind4, "[%d]", Xind+4);
				$<stringValue>$ = str_terceto_number(crear_terceto("BGE", Xind4, NULL));
				$<stringValue>$ = str_terceto_number(crear_terceto(":=", "@min", "@aux"));
				break;
			case equmax_enum:
				Xind = crear_terceto(":=", "@aux", $<stringValue>1);
				EQind = crear_terceto("CMP", "@aux", "@max");
				sprintf(Xind4, "[%d]", Xind+4);
				$<stringValue>$ = str_terceto_number(crear_terceto("BLE", Xind4, NULL));
				$<stringValue>$ = str_terceto_number(crear_terceto(":=", "@max", "@aux"));
				break;
		}		
	} |
	factor {
		switch(enum_equmax_equmin)
		{
			case equmin_enum:
				$<stringValue>$ = str_terceto_number(crear_terceto(":=", "@min", $<stringValue>$));
				break;
			case equmax_enum:
				$<stringValue>$ = str_terceto_number(crear_terceto(":=", "@max", $<stringValue>$));
				break;
		}			
	}
	
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
		tipoDatoVarA = obtenerTipoDatoTerceto($<stringValue>1);
		tipoDatoVarB = obtenerTipoDatoTerceto($<stringValue>3);		
		// printf("debug: validando tipo dato en condicion. tipo de %s: %d, tipo de %s: %d\n", $<stringValue>1, tipoDatoVarA, $<stringValue>3, tipoDatoVarB);
		// mostrarTablaSimbolos();
		validarTipoDato(tipoDatoVarA,tipoDatoVarB,yylineno, 1);

		/* aviso que operacion hay que hacer */
        insertar_pila(&comparacion, atoi($<intValue>2));
        $<stringValue>$ = str_terceto_number(crear_terceto("CMP", $<stringValue>1, $<stringValue>3)); 
	}|
	operacion_equmax {
		insertar_pila(&comparacion, CTE_CMP_IGUAL);
		$<stringValue>$ = str_terceto_number(crear_terceto("CMP", "@max", "@expr"));
		
	}|
	operacion_equmin{
		insertar_pila(&comparacion, CTE_CMP_IGUAL);
		$<stringValue>$ = str_terceto_number(crear_terceto("CMP", "@min", "@expr"));
	}
	

operador:
	CMP_IGUAL 		{$<intValue>$ = string_from_cte(CTE_CMP_IGUAL);}|
	CMP_DISTINTO 	{$<intValue>$ = string_from_cte(CTE_CMP_DISTINTO);}|
	CMP_MENOR 		{$<intValue>$ = string_from_cte(CTE_CMP_MENOR);}|
	CMP_MAYOR 		{$<intValue>$ = string_from_cte(CTE_CMP_MAYOR);}|
	CMP_MENORIGUAL 	{$<intValue>$ = string_from_cte(CTE_CMP_MENOR_IGUAL);}|
	CMP_MAYORIGUAL 	{$<intValue>$ = string_from_cte(CTE_CMP_MAYOR_IGUAL);}

asignacion:	
	ID OP_ASIG expresion {
		verificarExisteId($<stringValue>1);
		
		// printf("debug: verificar existe id %s\n", $<stringValue>2);

		tipoDatoVarA = obtenerTipoDato($<stringValue>1);
		tipoDatoVarB = obtenerTipoDatoTerceto($<stringValue>3);
		validarTipoDato(tipoDatoVarA,tipoDatoVarB,yylineno, 0);
		// printf("[%d] debug: asignaciones (ID := expresion)\n", contador_tiempos_debug++);
		$<stringValue>$ = str_terceto_number(crear_terceto(":=", $<stringValue>1,  $<stringValue>3)); 
	}

expresion:
	expresion OP_RES termino 	 {
									Eind = crear_terceto("-", $<stringValue>1, $<stringValue>3); 
									$<stringValue>$ = str_terceto_number(Eind);
									// printf("[%d] debug: expresion - termino\n", contador_tiempos_debug++);
								}|
	expresion OP_SUM termino 	 {
									Eind = crear_terceto("+", $<stringValue>1, $<stringValue>3);
									$<stringValue>$ = str_terceto_number(Eind);
									// printf("[%d] debug: expresion + termino\n", contador_tiempos_debug++);
								}|
	termino 					{	
									Eind = terceto_number($<stringValue>1);
									// printf("[%d] debug: termino\n", contador_tiempos_debug++);
								}

termino:
	termino OP_MUL factor 	{ 
								Tind = crear_terceto("*", $<stringValue>1, $<stringValue>3); 
								$<stringValue>$ = str_terceto_number(Tind); 
								// printf("[%d] debug: termino * factor\n", contador_tiempos_debug++);
							}|	
	termino OP_DIV factor 	{ 
								Tind = crear_terceto("/", $<stringValue>1, $<stringValue>3); 
								$<stringValue>$ = str_terceto_number(Tind); 
								// printf("[%d] debug: termino / factor\n", contador_tiempos_debug++);
							}|
	factor {
		// printf("[%d] debug: factor\n", contador_tiempos_debug++);
	}

factor:
	ID 		  {
		Find = crear_terceto($<stringValue>1, NULL, NULL);
		$<stringValue>$ = str_terceto_number(Find); 
		// printf("[%d] debug: ID\n", contador_tiempos_debug++);
	}| 
	constante {
		Find = crear_terceto($<stringValue>1, NULL, NULL);
		$<stringValue>$ = str_terceto_number(Find); 
		// printf("[%d] debug: constante\n", contador_tiempos_debug++);
	}

constante:
	CONST_INT	|
	CONST_REAL	|
	CONST_STR

entrada_salida:
	GET ID {
		verificarExisteId($<stringValue>2);

		// printf("debug: verificar existe id %s\n", $<stringValue>2);

		char valor[COTA_STR];
		obtener_nombre_o_valor($<stringValue>2, valor);
		$<stringValue>$ = str_terceto_number(crear_terceto ("GET", valor, NULL));
	} |
	DISPLAY ID {
		char valor[COTA_STR];
		verificarExisteId($<stringValue>2);

		// printf("debug: verificar existe id %s\n", $<stringValue>2);
		
		obtener_nombre_o_valor($<stringValue>2, valor);
		$<stringValue>$ = str_terceto_number(crear_terceto ("DISPLAY", valor, NULL));
	} |
	DISPLAY CONST_STR {
		$<stringValue>$ = str_terceto_number(crear_terceto ("DISPLAY", $<stringValue>2, NULL));
	}
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

//funciones assembler
void generarASM() {
    //Abrir archivo Final.asm
    if(!(pfASM = fopen("Final.asm", "wt+"))) {
        informeError("Error al crear el archivo Final.asm, verifique los permisos de escritura.");
    }
  
    //Generar archivo ASM
    fprintf(pfASM, ";\n;ARCHIVO FINAL.ASM\n;\n");

    generarEncabezado();
    generarDatos();
	// cargarVectorEtiquetas();
    generarCodigo();
 	//    generarFin();
	
    //Cerrar archivo
    fclose(pfASM);
}


void generarEncabezado() {
    //Encabezado del archivo
    fprintf(pfASM, "\nINCLUDE macros2.asm\t\t ;incluye macros\n");
    fprintf(pfASM, "INCLUDE number.asm\t\t ;incluye el asm para impresion de numeros\n");
    //fprintf(pfASM, "INCLUDE string.asm\t\t ;incluye el asm para manejo de strings\n");    		 
    fprintf(pfASM, "\n.MODEL LARGE ; tipo del modelo de memoria usado.\n");
    fprintf(pfASM, ".386\n");
    fprintf(pfASM, ".STACK 200h ; bytes en el stack\n"); 
}

void generarDatos() {
	FILE *pfTS;
	int nro_linea=1;
    char linea[95];
    int i = 0;
    int j=0;
    char aux[STR_VALUE];
	char* token; // para el split de linea
	t_lineaTs lineaTs;
	
    //Encabezado del sector de datos
    fprintf(pfASM, "\t\n.DATA ;variables de la tabla de simbolos.\n");    
    fprintf(pfASM, "\tTRUE equ 1\n");
    fprintf(pfASM, "\tFALSE equ 0\n");
    fprintf(pfASM, "\tMAXTEXTSIZE equ %d\n",200); //cota STR
    fprintf(pfASM, "\t%-32s\tdd\t%s\n", "R1", "?");	
	int cant_aux = 1;
	while(cant_aux<=15){
		fprintf(pfASM, "\t%s%-30d\tdd\t%s\n", "@aux", cant_aux,"?");
		cant_aux++;
	}   
	
	if(!(pfTS = fopen("ts.txt", "r+"))) {
         informeError("Error al abrir el archivo ts.txt, verifique los permisos de escritura.");
    }
	
	while( fscanf(pfTS,"%[^|]|%[^|]|%[^|]|%[^|]|\n",lineaTs.nombre,lineaTs.tipo,lineaTs.valor,lineaTs.longitud) == 4) {
    	if(i>=2){
    		j=0;
    		
    		for ( j = strlen(lineaTs.nombre) - 1; lineaTs.nombre[j] == ' ' ; j-- );
				lineaTs.nombre[j+1]='\0';
			for ( j = strlen(lineaTs.tipo) - 1; lineaTs.tipo[j] == ' ' ; j-- );
				lineaTs.tipo[j+1]='\0';
			for ( j = strlen(lineaTs.valor) - 1; lineaTs.valor[j] == ' ' ; j-- );
				lineaTs.valor[j+1]='\0';
			
	      
				if(strcmp(lineaTs.tipo,"INT")==0 || strcmp(lineaTs.tipo,"FLOAT")==0 || strcmp(lineaTs.tipo,"STRING")==0){
					fprintf(pfASM, "\t%-32s\tdd\t%s\n",lineaTs.nombre,"?"); 
				}else if(strcmp(lineaTs.tipo,"CTE_INT")==0 || strcmp(lineaTs.tipo,"CTE_FLOAT")==0)
					fprintf(pfASM, "\t%-32s\tdd\t%s\n",lineaTs.nombre,lineaTs.valor);

				if(strcmp(lineaTs.tipo,"CTE_STRING")==0)
					fprintf(pfASM, "\t%-32s\tdb\t%s ,'$',%s dup (?)\n",lineaTs.nombre,lineaTs.valor,lineaTs.longitud);
	    }
	    i++;
	}
	fclose(pfTS);	
}

void generarCodigo() {
	int i, procesado=0;
	//para assembler
	int countAssemblerAux=1;	

	// TODO: leer el archivo de tercetos y generar el codigo assembler
	fprintf(pfASM, "\n.CODE\n");
	fprintf(pfASM, "START:\n");
	fprintf(pfASM, "\tMOV AX,@DATA\n");
	fprintf(pfASM, "\tMOV DS,AX\n");
	fprintf(pfASM, "\tMOV es,ax\n\n");
			
	for(i=0; i < cant_tercetos; i++){
		printf("debug::::::> terceto %d) leyendo terceto -> ",i);
		printf("debug::::::> (t1, t2, t3) = (%s, %s, %s)\n", tercetos[i]->t1,tercetos[i]->t2,tercetos[i]->t3);
		
		/********************** asignacion y comparacion ***************************************************/
		if(strcmp(tercetos[i]->t1, ":=")==0){
			resolver_asignacion(pfASM, i, &countAssemblerAux);
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "CMP")==0){
			resolver_comparacion(pfASM, i);		
			procesado=1;
		}
		/********************** fin asignacion y comparacion ***************************************************/
		
		/********************** saltos ***************************************************/
		if(strcmp(tercetos[i]->t1, "BGT")==0){
			escribirSalto(pfASM, "JA", terceto_number(tercetos[i]->t2));
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "BGE")==0){
			escribirSalto(pfASM, "JAE", terceto_number(tercetos[i]->t2));
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "BLT")==0){			
			escribirSalto(pfASM, "JB", terceto_number(tercetos[i]->t2));
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "BLE")==0){			
			escribirSalto(pfASM, "JBE", terceto_number(tercetos[i]->t2));
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "BNE")==0){	
			escribirSalto(pfASM, "JNE", terceto_number(tercetos[i]->t2));
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "BEQ")==0){	
			escribirSalto(pfASM, "JE", terceto_number(tercetos[i]->t2));
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "BI")==0){
			printf("debug .:::::::::::::::::::> bi terceto_number(tercetos[i]->t2): %d\n",terceto_number(tercetos[i]->t2));
			escribirSalto(pfASM, "JMP", terceto_number(tercetos[i]->t2));
			procesado=1;
		}
		/********************** fin saltos ***************************************************/
		
		/********************** etiquetas ***************************************************/
		//TODO: agregar etiquetas en los ciclos y saltos por condicion (then, else, endif, while, endwhile, for...)
		//#ETIQUETA
		printf("debug ::::::> %s\n", tercetos[i]->t2);
		if(strcmp(tercetos[i]->t1, "#ETIQUETA")==0){
			printf("debug ::::::> antes de escribir: %s\n", tercetos[i]->t2);
			fprintf(pfASM, tercetos[i]->t2);
			procesado=1;
		}
		/********************** fin etiquetas ***************************************************/

		/********************** operaciones ***************************************************/
		if(strcmp(tercetos[i]->t1, "+")==0){
			resolver_suma(pfASM, i, &countAssemblerAux);
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "-")==0){
			resolver_resta(pfASM, i, &countAssemblerAux);		
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "/")==0){
			resolver_division(pfASM, i, &countAssemblerAux);	
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "*")==0){
			resolver_multiplicacion(pfASM, i, &countAssemblerAux);				
			procesado=1;
		}
		/********************** fin operaciones ***************************************************/
		
		/********************** I/O ***************************************************/
		if(strcmp(tercetos[i]->t1, "DISPLAY")==0){	
			resolver_display(pfASM, i);		
			procesado=1;
		}
		if(strcmp(tercetos[i]->t1, "GET")==0){
			resolver_get(pfASM, i);
			procesado=1;
		}
		/********************** fin I/O ***************************************************/
		printf("debug ::::::> salgo? : cant tercetos: %d, contador i: %d\n", cant_tercetos,i);
		printf("debug ::::::> llego: %s valor\n", tercetos[i]->t1);
		procesado==1 ? procesado=0 : printf("Terceto con valor: [%d] (%s, ,): %s\n",i, tercetos[i]->t1, get_type(tercetos[i]->tipo));
	}
	printf("debug ::::::> salgo? : cant tercetos: %d\n", cant_tercetos);
	//Fin de ejecución
    fprintf(pfASM, "\nTERMINAR: ;Fin de ejecución.\n\tmov ax, 4C00h ; termina la ejecución.\n\tint 21h; syscall\n\nEND START;final del archivo."); 
}

int informeError(char * error){
		printf("\n%s",error);
		getchar();
		exit(1);
}


char* obtenerTipoTS(char* nombre_elemento){
 	FILE *pfTS;
 	char* aux;
 	char linea[100];
 	int encontro = 0;
 	t_lineaTs lineaTs;
 	int j, i=0;
	
 	if(!(pfTS = fopen("ts.txt", "r+"))) {
          informeError("Error al abrir el archivo ts.txt, verifique los permisos de escritura.");
     }
	
 	while(fscanf(pfTS,"%[^|]|%[^|]|%[^|]|%[^|]|\n",lineaTs.nombre,lineaTs.tipo,lineaTs.valor,lineaTs.longitud) == 4) {
 		if(i>=2){
    		j=0;
    		
    		for ( j = strlen(lineaTs.nombre) - 1; lineaTs.nombre[j] == ' ' ; j-- );
				lineaTs.nombre[j+1]='\0';
			for ( j = strlen(lineaTs.tipo) - 1; lineaTs.tipo[j] == ' ' ; j-- );
				lineaTs.tipo[j+1]='\0';
			for ( j = strlen(lineaTs.valor) - 1; lineaTs.valor[j] == ' ' ; j-- );
				lineaTs.valor[j+1]='\0';
			

			if(strcmp(lineaTs.nombre,nombre_elemento)==0) {
				aux = (char *) malloc(sizeof(char) * (strlen(lineaTs.tipo) + 1));
				strcpy(aux, lineaTs.tipo);

				encontro = 1;
				fclose(pfTS);
				return aux;
			}
		}
	    i++;
     }
	
	
 	fclose(pfTS);
 	return "NADA";
 }