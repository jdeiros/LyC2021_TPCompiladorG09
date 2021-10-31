#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "constantes.h"

//COMIENZO TABLA DE SIMBOLOS

#define T_CTE_INTEGER 1
#define T_CTE_STRING 2
#define T_CTE_FLOAT 3
#define T_ID 4
#define T_STRING 5
#define T_INT 6
#define T_FLOAT 7
#define ERROR -1

typedef struct
{
	char nombre[50];
	int tipo;
	char dato[50];
	int longitud;
} t_simbolo;


/*** SECCION FUNCIONES TABLA DE SIMBOLOS ***/
int tsCrearArchivo();
void insertarTablaSimbolos(char *, int, char *, int);
void mostrarTablaSimbolos();

/*** SECCION FUNCIONES NOMBRES ***/
char *obtenerNombreTipo(int);
char *indicarNombreConstante(const char *);
char *indicarNombreConstanteString(const char *);
char *reemplazarCaracter(char *);

/*** SECCION FUNCIONES DE DATOS ***/
void actualizarTipoDato(int);
int obtenerTipoDato(char *);
void verificarExisteId(char *);
void validarTipoDato(int, int, int, int);
int obtenerTipoDatoOperacion(int, int);

/*** SECCION UTILITARIOS ***/
void validarDivisionPorCero(char *);

/* Notacion intermedia */
/* estrutura de un terceto */
typedef struct s_terceto
{
	char t1[COTA_STR],	// primer termino
		t2[COTA_STR],	// segundo termino
		t3[COTA_STR];	// tercer termino
	char aux[COTA_STR]; // nombre variable auxiliar correspondiente
} t_terceto;
/* coleccion de tercetos */
t_terceto *tercetos[MAX_TERCETOS];
/* cantidad de tercetos */
int cant_tercetos;
/** crea una estructura de datos de terceto */
t_terceto *_crear_terceto(const char *, const char *, const char *);
/* crea un terceto y lo agrega a la coleccion */
int crear_terceto(const char *, const char *, const char *);
/* crea un terceto y lo agrega a la coleccion y devuelve string con formato [n]*/
char * str_terceto_number(int);
/* escribe los tercetos en un archivo */
void escribir_tercetos(FILE *);
/* libera memoria pedida para tercetos */
void limpiar_tercetos();

int terceto_number(char *);

FILE *intermedia;
/* flag error de sintaxis */
int sintaxis_error;
char * get_from_TS();

/* Pila para manejo de tercetos */ 
typedef struct s_nodo {
    int valor;
    struct s_nodo *sig;
} t_nodo;
typedef t_nodo* t_pila;
/* apunta al ultimo elemento ingresado */
t_pila pila;
/* Indica que operador de comparacion se uso */
t_pila comparacion;
/* Apila los tipos de condicion (and, or, not) cuando hay anidamiento */
t_pila pila_condicion;
/** inserta un entero en la pila */
void insertar_pila (t_pila*, int);
/** obtiene un entero de la pila */
int sacar_pila(t_pila*);
/** crea una estructura de pila */
void crear_pila(t_pila*);
/** destruye pila */
void destruir_pila(t_pila*);

char * string_from_cte(int cte);

/** Obtiene nombre o valor del elemento en posicion i en la tabla de simbolos */
void obtener_nombre_o_valor(char* lex, char* destino);
