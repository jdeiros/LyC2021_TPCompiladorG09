#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

//declaraciones de funciones de pila
int desapilar(char *[], int *tope);
char *desapilarChar(char *[], int *tope);
void apilar(char *dato, char *pila[], int *tope);
int pilaVacia(int tope);
int pilaLlena(int tope);
void recorrerPila(char *pila[], int *tope);
int topeDePila(char *[], int *tope);
int buscarDatoDePila(char *[], int *tope, char *dato);
