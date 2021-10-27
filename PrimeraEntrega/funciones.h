#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

//COMIENZO TABLA DE SIMBOLOS

#define T_CTE_INTEGER 1
#define T_CTE_STRING 2
#define T_CTE_FLOAT 3
#define T_ID 4
#define T_STRING 5
#define T_INT 6
#define T_FLOAT 7

typedef struct {
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
char * obtenerNombreTipo(int);
char * indicarNombreConstante(const char *);
char * indicarNombreConstanteString(const char *);
char * reemplazarCaracter(char *);

/*** SECCION FUNCIONES DE DATOS ***/
void actualizarTipoDato(int);
int obtenerTipoDato(char *);
void verificarExisteId(char *);
void validarTipoDato(int, int, int, int);
int obtenerTipoDatoOperacion(int, int);


/*** SECCION UTILITARIOS ***/
void validarDivisionPorCero(char*);
