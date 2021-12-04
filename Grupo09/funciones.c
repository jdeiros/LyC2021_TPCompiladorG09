#include "funciones.h"

t_simbolo tablaSimbolos[100];
int posActualTablaSimbolos = 0;

int indiceString = 0;

int tsCrearArchivo()
{
	int i;
	FILE *archivo;

	archivo = fopen("ts.txt", "w");
	if (!archivo)
	{
		printf("Error en crear el archivo ts.txt [Tabla de Simbolos]\n");
		return 1;
	}

	// Cabecera del archivo
	fprintf(archivo, " Nombre                          | Tipo          | Valor                          | Longitud |\n");
	fprintf(archivo, "---------------------------------|---------------|--------------------------------|----------|\n");

	// Se escribe linea por linea
	for (i = 0; i < posActualTablaSimbolos; i++)
	{
		fprintf(archivo, "%-33s|%-15s|%-32s|%-10d|\n", tablaSimbolos[i].nombre, obtenerNombreTipo(tablaSimbolos[i].tipo), tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
	}
	fclose(archivo);

	return 0;
}

void insertarTablaSimbolos(char *nombre, int tipo, char *dato, int longitud)
{
	int i;
	for (i = 0; i < posActualTablaSimbolos; i++)
		if (strcmp(tablaSimbolos[i].nombre, nombre) == 0)
		{
			return;
		}
	t_simbolo tmp;
	strcpy(tmp.nombre, nombre);
	tmp.tipo = tipo;
	strcpy(tmp.dato, dato);
	tmp.longitud = longitud;
	tablaSimbolos[posActualTablaSimbolos++] = tmp;
}

void mostrarTablaSimbolos()
{
	int i;
	printf("Cantidad de simbolos en Tabla de Simbolos: %d\n", posActualTablaSimbolos);
	for (i = 0; i < posActualTablaSimbolos; i++)
	{
		printf("POS. %d, NOMBRE %s, TIPO %d, DATO %s, LONGITUD %d\n", i, tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
	}
}

char *obtenerNombreTipo(const int tipo)
{
	switch (tipo)
	{
	case T_CTE_INTEGER:
		return "CTE_INT";
	case T_CTE_STRING:
		return "CTE_STRING";
	case T_CTE_FLOAT:
		return "CTE_FLOAT";
	case T_ID:
		return "ID";
	case T_INT:
		return "INT";
	case T_STRING:
		return "STRING";
	case T_FLOAT:
		return "FLOAT";
	default:
		return "";
	}
}

char *indicarNombreConstante(const char *valor)
{
	char nombre[100] = "_";
	strcat(nombre, valor);
	return strdup(nombre);
}

char *indicarNombreConstanteString(const char *valor)
{
	//	char nombre[100];
	//    sprintf(nombre, "_%s", valor);
	//	return strdup(nombre);
	char *aux = (char *)malloc(sizeof(char) * (strlen(valor)) + 2);
	char *retor = (char *)malloc(sizeof(char) * (strlen(valor)) + 2);

	strcpy(retor, valor);
	int len = strlen(valor);
	retor[len - 1] = '\0';

	strcpy(aux, "_");
	strcat(aux, ++retor);

	return aux;
}

char *reemplazarCaracter(char *aux)
{
	int i = 0;
	for (i = 0; i <= strlen(aux); i++)
	{
		if (aux[i] == '\t' || aux[i] == '\r' || aux[i] == ' ')
		{
			aux[i] = '_';
		}

		if (aux[i] == '.')
		{
			aux[i] = 'p';
		}
	}
	return aux;
}

/** FUNCION QUE OBTIENE EL TIPO DE DATO DE UN LEXEMA EN LA TS **/
int obtenerTipoDato(char *valor)
{
	int i;
	char *auxNombre;

	for (i = 0; i < posActualTablaSimbolos; i++)
	{
		auxNombre = tablaSimbolos[i].nombre;

		if (strcmp(auxNombre, valor) == 0)
		{
			return tablaSimbolos[i].tipo;
		}
	}
	//si no encontro por nombre puede ser una cte
	for (i = 0; i < posActualTablaSimbolos; i++)
	{
		//ahora busco por dato
		auxNombre = tablaSimbolos[i].dato;

		if (strcmp(auxNombre, valor) == 0)
		{
			return tablaSimbolos[i].tipo;
		}
	}
	return -1;
}

//Función actualizar_tipo_dato: Función que recorre la lista de simbolos buscando IDs sin tipo de datos para asignarle el tipo correcto.
void actualizarTipoDato(int tipo)
{
	int i;
	int tipo_simb;
	for (i = 0; i < posActualTablaSimbolos; i++)
	{
		tipo_simb = tablaSimbolos[i].tipo;
		if (tipo_simb == T_ID)
		{
			tablaSimbolos[i].tipo = tipo;
			break;
		}
	}
}

void verificarExisteId(char *valor)
{
	int i, auxTipo, flagEncontrado = 0;
	char *auxNombre;

	for (i = 0; i < posActualTablaSimbolos; i++)
	{
		auxNombre = tablaSimbolos[i].nombre;
		auxTipo = tablaSimbolos[i].tipo;

		if (strcmp(auxNombre, valor) == 0 && auxTipo != T_ID)
		{
			flagEncontrado = 1;
		}
	}

	if (flagEncontrado == 0)
	{
		printf("Descripcion: el id '%s' no ha sido declarado\n", valor);
		system("Pause");
		exit(1);
	}
}

void validarTipoDato(int td1, int td2, int linea, int operacion)
{
	char charOperacion[30];

	if (operacion == 0)
	{
		sprintf(charOperacion, "asignacion");
	}
	else
	{
		sprintf(charOperacion, "comparacion");
	}

	if (td1 == T_INT && td2 != T_CTE_INTEGER && td2 != T_INT)
	{
		printf("\tError en %s por tipo de datos Entero - Linea :: %d\n", charOperacion, linea);
		system("Pause");
		exit(1);
	}

	if (td1 == T_FLOAT && td2 != T_CTE_FLOAT && td2 != T_FLOAT)
	{
		printf("\tError en %s por tipo de datos Real - Linea :: %d\n", charOperacion, linea);
		system("Pause");
		exit(1);
	}

	if (td1 == T_STRING && td2 != T_CTE_STRING && td2 != T_STRING)
	{
		printf("\tError en %s por tipo de datos String - Linea :: %d\n", charOperacion, linea);
		system("Pause");
		exit(1);
	}
}

int obtenerTipoDatoOperacion(int td1, int td2)
{
	if ((td1 == T_INT || td1 == T_CTE_INTEGER) && (td2 == T_CTE_INTEGER || td2 == T_INT))
	{
		return T_INT;
	}

	if ((td1 == T_FLOAT || td1 == T_CTE_FLOAT) && (td2 == T_CTE_FLOAT || td2 == T_FLOAT))
	{
		return T_FLOAT;
	}

	if ((td1 == T_STRING || td1 == T_CTE_STRING) && (td2 == T_CTE_STRING || td2 == T_STRING))
	{
		return T_STRING;
	}

	return T_ID;
}

int obtenerTipoDatoTerceto(char *tercetoNumberEnclosed)
{
	int nroTerceto = terceto_number(tercetoNumberEnclosed);
	return tercetos[nroTerceto]->tipo;
}

void validarDivisionPorCero(char *dato)
{
	if (strcmp(dato, "0") == 0)
	{
		printf("Error :: No se puede dividir un numero por CERO.\n");
		system("pause");
		exit(1);
	}
}

/** crea una estructura de datos de terceto */
t_terceto *_crear_terceto(const char *t1, const char *t2, const char *t3)
{
	t_terceto *terceto = (t_terceto *)malloc(sizeof(t_terceto));
	// completo sus atributos
	strcpy(terceto->t1, t1);

	//printf("debug: creando terceto (%s,%s,%s)\n", t1, t2, t3);
	//printf("debug: tipo dato de %s = %d, tipo de dato de %s = %d)\n", t2, obtenerTipoDato(t2), t3, obtenerTipoDato(t3));
	if (t2 == NULL && t3 == NULL)
	{
		terceto->tipo = obtenerTipoDato((char *)t1);
	}
	else
	{
		terceto->tipo = ERROR;
	}
	// mostrarTablaSimbolos();

	if (t2)
		strcpy(terceto->t2, t2);
	else
		*(terceto->t2) = '\0';

	if (t3)
		strcpy(terceto->t3, t3);
	else
		*(terceto->t3) = '\0';
	return terceto;
}

/** crea un terceto y lo agrega a la coleccion de tercetos */

int crear_terceto(const char *t1, const char *t2, const char *t3)
{
	// creo un nuevo terceto y lo agrego a la coleccion de tercetos
	int numero = cant_tercetos;
	tercetos[numero] = _crear_terceto(t1, t2, t3);
	cant_tercetos++;
	// devuelvo numero de terceto
	return numero;
}

char *str_terceto_number(int numero)
{
	// devuelvo numero de terceto en un string con formato [n]
	char *aux = (char *)malloc(sizeof(numero));
	char *terceto = (char *)malloc(sizeof('[') + sizeof(numero) + sizeof(']'));
	itoa(numero, aux, 10);
	strcpy(terceto, "[");
	strcat(terceto, aux);
	strcat(terceto, "]");
	return terceto;
}

/** Escribe tercetos en un archivo de texto */
void escribir_tercetos(FILE *archivo)
{
	int i;
	for (i = 0; i < cant_tercetos; i++)
		fprintf(archivo, "%d (%s, %s, %s)\n", i,
				tercetos[i]->t1,
				tercetos[i]->t2,
				tercetos[i]->t3);
}
/** Libera memoria pedida para tercetos */
void limpiar_tercetos()
{
	int i;
	for (i = 0; i < cant_tercetos; i++)
		free(tercetos[i]);
}
int terceto_number(char *cadena)
{
	int i, longitud = strlen(cadena) - 2, inicio = 1, long_subcadena;
	char *subcadena = (char *)malloc(sizeof(strlen(cadena))); //[strlen(cadena)];

	for (i = 0; i < longitud && inicio + i < strlen(cadena); i++)
		subcadena[i] = cadena[inicio + i];

	subcadena[i] = '\0';
	return atoi(subcadena);
}

/** inserta un entero en la pila */
void insertar_pila(t_pila *p, int valor)
{
	// creo nodo
	t_nodo *nodo = (t_nodo *)malloc(sizeof(t_nodo));
	// asigno valor
	nodo->valor = valor;
	// apunto al elemento siguiente
	nodo->sig = *p;
	// apunto al tope de la pila
	*p = nodo;
}

/** obtiene un entero de la pila */
int sacar_pila(t_pila *p)
{
	int valor = ERROR;
	t_nodo *aux;
	if (*p != NULL)
	{
		aux = *p;
		valor = aux->valor;
		*p = aux->sig;
		free(aux);
	}
	return valor;
}

/** crea una estructura de pila */
void crear_pila(t_pila *p)
{
	*p = NULL;
}

/** destruye pila */
void destruir_pila(t_pila *p)
{
	while (ERROR != sacar_pila(p))
		;
}

/* inicializaciones globales*/
void init()
{
	sintaxis_error = 0;
	if ((intermedia = fopen("Intermedia.txt", "w")) == NULL)
	{
		printf("No se puede crear el archivo Intermedia.txt\n");
		exit(ERROR);
	}

	cant_tercetos = 0;
	crear_pila(&pila);
	crear_pila(&comparacion);
	crear_pila(&pila_condicion);
}

char *string_from_cte(int cte)
{
	char *str_cte = (char *)malloc(sizeof(cte));
	itoa(cte, str_cte, 10);

	return str_cte;
}

/** Obtiene nombre o valor del elemento en posicion i en la tabla de simbolos */
void obtener_nombre_o_valor(char *lex, char *destino)
{
	int i, auxTipo, flagEncontrado = 0;
	char *auxNombre;

	for (i = 0; i < posActualTablaSimbolos; i++)
	{
		auxNombre = tablaSimbolos[i].nombre;
		auxTipo = tablaSimbolos[i].tipo;

		if (strcmp(auxNombre, lex) == 0 && auxTipo != T_ID)
		{
			flagEncontrado = 1;
			if (*(tablaSimbolos[i].dato))
				strcpy(destino, tablaSimbolos[i].dato);
			else
				strcpy(destino, tablaSimbolos[i].nombre);
		}
	}

	if (flagEncontrado == 0)
	{
		printf("Descripcion: el id '%s' no ha sido declarado\n", i);
		system("Pause");
		exit(1);
	}
}

/**************** 	FUNCIONES PILA	********************/

void recorrerPila(char *pila[], int *tope)
{
	int x;

	for (x = 0; x < (*tope); x++)
		printf("\t\t\t POSICION :: %d  ----- DATO %s\n\n", x, pila[x]);
}

int desapilar(char *pila[], int *tope)
{
	if (pilaVacia((*tope)) == 0)
	{
		char *dato = pila[(*tope) - 1];

		(*tope)--;
		//printf("\tDESAPILAR #CELDA -> %s de posicion : %d \n", dato, *tope);

		return atoi(dato);
	}
	else
	{
		printf("Error: La pila esta vacia.\n");
		system("Pause");
		exit(1);
	}
}

char *desapilarChar(char *pila[], int *tope)
{
	if (pilaVacia((*tope)) == 0)
	{
		char *dato = pila[(*tope) - 1];

		(*tope)--;
		//printf("\tDESAPILAR #CELDA -> %s de posicion : %d \n", dato, *tope);

		return dato;
	}
	else
	{
		printf("Error: La pila esta vacia.\n");
		system("Pause");
		exit(1);
	}
}

void apilar(char *dato, char *pila[], int *tope)
{
	if (pilaLlena((*tope)) == 1)
	{
		printf("Error: Se excedio el tamano de la pila.\n");
		system("Pause");
		exit(1);
	}

	pila[(*tope)] = (char *)malloc(sizeof(char) * (strlen(dato) + 1));
	strcpy(pila[(*tope)], dato);
	//printf("\tAPILAR #CELDA ACTUAL -> %s en posicion: %d\n", pila[(*tope)], *tope);

	(*tope)++;
	//printf("\tNUEVO TOPE PILA: %d\n", *tope);
}

int pilaVacia(int tope)
{
	if (tope - 1 == -1)
	{
		return 1;
	}
	return 0;
}

int pilaLlena(int tope)
{
	if (tope - 1 == 100 - 1)
	{
		return 1;
	}
	return 0;
}

int topeDePila(char *pila[], int *tope)
{
	if (pilaVacia((*tope)) == 0)
	{
		char *dato = pila[(*tope) - 1];

		printf("\tTOPE DE PILA :: #CELDA -> %s de posicion : %d \n", dato, *tope);

		return atoi(dato);
	}
	else
	{
		printf("Error: La pila esta vacia.\n");
		system("Pause");
		exit(1);
	}
}

int buscarDatoDePila(char *pila[], int *tope, char *dato)
{
	int existeEnPila = 0, x;

	if (pilaVacia((*tope)) == 0)
	{
		for (x = 0; x < (*tope); x++)
		{
			if (strcmp(pila[x], dato) == 0)
			{
				existeEnPila = 1;
			}
		}
	}
	return existeEnPila;
}



//************************************************** assembler **************************************************

void resolver_asignacion(FILE* arch, int ind, int *countAssemblerAux){
	/**************************************************/
	char op1[30];
    char op2[30];
	int nroTercetoOp1 = terceto_number(tercetos[ind]->t2);
	int nroTercetoOp2 = terceto_number(tercetos[ind]->t3);
	int tipoDatoOp1 = tercetos[nroTercetoOp1]->tipo;
	int tipoDatoOp2 = tercetos[nroTercetoOp2]->tipo;
	sprintf(op1, "%s", tercetos[nroTercetoOp1]->t1);
	sprintf(op2, "%s", tercetos[nroTercetoOp2]->t1);

	if(strcmp(op1, "+")!=0 && strcmp(op1, "-")!=0 && strcmp(op1, "/")!=0  && strcmp(op1, "-")!=0 && strcmp(op1, "*")!=0 
		&& strcmp(op2, "+")!=0 && strcmp(op2, "-")!=0 && strcmp(op2, "/")!=0  && strcmp(op2, "-")!=0 && strcmp(op2, "*")!=0)
	{
		/***************************************************/
		if ((tipoDatoOp1==T_INT || tipoDatoOp1==T_CTE_INTEGER) && (tipoDatoOp2==T_INT || tipoDatoOp2==T_CTE_INTEGER))
		{
			fprintf(arch, "\tfild %s\n", op2);
			fprintf(arch, "\tfistp %s\n",op1);
		} else if (tipoDatoOp2==T_STRING || tipoDatoOp2 == T_CTE_STRING)
		{
			fprintf(arch, "\tmov si, OFFSET %s\n", op2);
			fprintf(arch, "\tmov di, OFFSET %s\n", op1);
			fprintf(arch, "\tSTRCPY\n");
		} else {
			fprintf(arch, "\tfld %s\n", op2);
			fprintf(arch, "\tfstp %s\n", op1);
		}
		/***************************************************/
	}
	else {
		//op1
		if(strcmp(op1, "+")==0){
			resolver_suma(arch, nroTercetoOp1, countAssemblerAux);
		}
		if(strcmp(op1, "-")==0){
			resolver_resta(arch, nroTercetoOp1, countAssemblerAux);		
		}
		if(strcmp(op1, "/")==0){
			resolver_division(arch, nroTercetoOp1, countAssemblerAux);	
		}
		if(strcmp(op1, "*")==0){
			resolver_multiplicacion(arch, nroTercetoOp1, countAssemblerAux);				
		}
		//op2
		if(strcmp(op2, "+")==0){
			resolver_suma(arch, nroTercetoOp2, countAssemblerAux);
		}
		if(strcmp(op2, "-")==0){
			resolver_resta(arch, nroTercetoOp2, countAssemblerAux);		
		}
		if(strcmp(op2, "/")==0){
			resolver_division(arch, nroTercetoOp2, countAssemblerAux);	
		}
		if(strcmp(op2, "*")==0){
			resolver_multiplicacion(arch, nroTercetoOp2, countAssemblerAux);				
		}
	}

}


char *get_type(int const_type)
{
	switch(const_type)
	{
		case T_CTE_INTEGER: return "T_CTE_INTEGER";break;
		case T_CTE_STRING: return "T_CTE_STRING";break;
		case T_CTE_FLOAT: return "T_CTE_FLOAT";break;
		case T_ID: return "T_ID";break;
		case T_STRING: return "T_STRING";break;
		case T_INT: return "T_INT";break;
		case T_FLOAT: return "T_FLOAT";break;
		case ERROR: return "ERROR";break;
	}
}

void resolver_comparacion(FILE* arch, int ind)
{
	char op1[30];
    char op2[30];
	int nroTercetoOp1 = terceto_number(tercetos[ind]->t2);
	int nroTercetoOp2 = terceto_number(tercetos[ind]->t3);
	int tipoDatoOp1 = tercetos[nroTercetoOp1]->tipo;
	int tipoDatoOp2 = tercetos[nroTercetoOp2]->tipo;
	sprintf(op1, "%s", tercetos[nroTercetoOp1]->t1);
	sprintf(op2, "%s", tercetos[nroTercetoOp2]->t1);

	fprintf(arch, "\tfld %s\n", op1);
	fprintf(arch, "\tfld %s\n", op2);
	fprintf(arch, "\tfxch\n");		
	fprintf(arch, "\tfcomp\n");
	fprintf(arch, "\tfstsw ax\n");
	fprintf(arch, "\tffree st(0)\n");
	fprintf(arch, "\tsahf\n");  
}


void resolver_suma(FILE* arch, int ind, int *countAssemblerAux){
	char op1[30];
    char op2[30];
	int nroTercetoOp1 = terceto_number(tercetos[ind]->t2);
	int nroTercetoOp2 = terceto_number(tercetos[ind]->t3);
	int tipoDatoOp1 = tercetos[nroTercetoOp1]->tipo;
	int tipoDatoOp2 = tercetos[nroTercetoOp2]->tipo;
	sprintf(op1, "%s", tercetos[nroTercetoOp1]->t1);
	sprintf(op2, "%s", tercetos[nroTercetoOp2]->t1);
	char auxAssembler[100];
	sprintf(auxAssembler,"@aux%d", (*countAssemblerAux));

	if ((tipoDatoOp1==T_INT || tipoDatoOp1==T_CTE_INTEGER) && (tipoDatoOp2==T_INT || tipoDatoOp2==T_CTE_INTEGER))
	{
		fprintf(arch, "\tfild %s\n", op1);
		fprintf(arch, "\tfild %s\n", op2);
		fprintf(arch, "\tfxch\n");
		fprintf(arch, "\tfadd\n");
		fprintf(arch, "\tfistp %s\n",auxAssembler);
	} else {
		fprintf(arch, "\tfld %s\n", op1);
		fprintf(arch, "\tfld %s\n", op2);
		fprintf(arch, "\tfxch\n");
		fprintf(arch, "\tfadd\n");
		fprintf(arch, "\tfstp %s\n",auxAssembler);
	}	
	(*countAssemblerAux)++;
}
void resolver_resta(FILE* arch, int ind, int *countAssemblerAux){
	char op1[30];
    char op2[30];
	int nroTercetoOp1 = terceto_number(tercetos[ind]->t2);
	int nroTercetoOp2 = terceto_number(tercetos[ind]->t3);
	int tipoDatoOp1 = tercetos[nroTercetoOp1]->tipo;
	int tipoDatoOp2 = tercetos[nroTercetoOp2]->tipo;
	sprintf(op1, "%s", tercetos[nroTercetoOp1]->t1);
	sprintf(op2, "%s", tercetos[nroTercetoOp2]->t1);
	char auxAssembler[100];

	sprintf(auxAssembler,"@aux%d", (*countAssemblerAux));

	if ((tipoDatoOp1==T_INT || tipoDatoOp1==T_CTE_INTEGER) && (tipoDatoOp2==T_INT || tipoDatoOp2==T_CTE_INTEGER))
	{		
		fprintf(arch, "\tfild %s\n", op1);
		fprintf(arch, "\tfild %s\n", op2);
		fprintf(arch, "\tfxch\n");
		fprintf(arch, "\tfsub\n");
		fprintf(arch, "\tfistp %s\n",auxAssembler);
	} else {
		fprintf(arch, "\tfld %s\n", op1);
		fprintf(arch, "\tfld %s\n", op2);
		fprintf(arch, "\tfxch\n");
		fprintf(arch, "\tfsub\n");
		fprintf(arch, "\tfstp %s\n",auxAssembler);
	}
	(*countAssemblerAux)++;
}
void resolver_multiplicacion(FILE* arch, int ind, int *countAssemblerAux){
	char op1[30];
    char op2[30];
	int nroTercetoOp1 = terceto_number(tercetos[ind]->t2);
	int nroTercetoOp2 = terceto_number(tercetos[ind]->t3);
	int tipoDatoOp1 = tercetos[nroTercetoOp1]->tipo;
	int tipoDatoOp2 = tercetos[nroTercetoOp2]->tipo;
	sprintf(op1, "%s", tercetos[nroTercetoOp1]->t1);
	sprintf(op2, "%s", tercetos[nroTercetoOp2]->t1);
	char auxAssembler[100];

	sprintf(auxAssembler,"@aux%d", (*countAssemblerAux));

	if ((tipoDatoOp1==T_INT || tipoDatoOp1==T_CTE_INTEGER) && (tipoDatoOp2==T_INT || tipoDatoOp2==T_CTE_INTEGER))
	{
		fprintf(arch, "\tfild %s\n", op1);
		fprintf(arch, "\tfild %s\n", op2);
		fprintf(arch, "\tfxch\n");
		fprintf(arch, "\tfmul\n");

		fprintf(arch, "\tfistp %s\n",auxAssembler);
		
	} else {
		fprintf(arch, "\tfld %s\n", op1);
		fprintf(arch, "\tfld %s\n", op2);
		fprintf(arch, "\tfxch\n");
		fprintf(arch, "\tfmul\n");

		fprintf(arch, "\tfstp %s\n",auxAssembler);
		
	}

	
	(*countAssemblerAux)++;
}
void resolver_division(FILE* arch, int ind, int *countAssemblerAux){
	char op1[30];
    char op2[30];
	int nroTercetoOp1 = terceto_number(tercetos[ind]->t2);
	int nroTercetoOp2 = terceto_number(tercetos[ind]->t3);
	int tipoDatoOp1 = tercetos[nroTercetoOp1]->tipo;
	int tipoDatoOp2 = tercetos[nroTercetoOp2]->tipo;
	sprintf(op1, "%s", tercetos[nroTercetoOp1]->t1);
	sprintf(op2, "%s", tercetos[nroTercetoOp2]->t1);
	char auxAssembler[100];

	sprintf(auxAssembler,"@aux%d", (*countAssemblerAux));

	if ((tipoDatoOp1==T_INT || tipoDatoOp1==T_CTE_INTEGER) && (nroTercetoOp2==T_INT || nroTercetoOp2==T_CTE_INTEGER))
	{
		fprintf(arch, "\tfild %s\n", op1);
		fprintf(arch, "\tfild %s\n", op2);
		fprintf(arch, "\tfxch\n");
		fprintf(arch, "\tfdiv\n");
		fprintf(arch, "\tfistp %s\n",auxAssembler);

	} else {
		fprintf(arch, "\tfld %s\n", op1);
		fprintf(arch, "\tfld %s\n", op2);
		fprintf(arch, "\tfxch\n");
		fprintf(arch, "\tfdiv\n");
		fprintf(arch, "\tfstp %s\n",auxAssembler);

	}

	(*countAssemblerAux)++;
}

void resolver_display(FILE* arch,int ind){
	char op1[30];    
	int nroTercetoOp1 = terceto_number(tercetos[ind]->t2);	
	int tipoDatoOp1 = tercetos[nroTercetoOp1]->tipo;	
	sprintf(op1, "%s", tercetos[nroTercetoOp1]->t1);	

	if ((tipoDatoOp1==T_STRING)||tipoDatoOp1==T_CTE_STRING) {
		fprintf(arch, "\tdisplayString  %s\n", op1);
	} else if ((tipoDatoOp1==T_INT)||tipoDatoOp1==T_CTE_INTEGER) {
		fprintf(arch, "\tDisplayInteger  %s\n", op1);
	} else if ((tipoDatoOp1==T_FLOAT)||tipoDatoOp1==T_CTE_FLOAT) {
		fprintf(arch, "\tDisplayFloat  %s,2\n", op1);
	}
	fprintf(arch, "\tnewline\n");
}
void resolver_get(FILE* arch,int ind){
	char op1[30];    
	int nroTercetoOp1 = terceto_number(tercetos[ind]->t2);	
	int tipoDatoOp1 = tercetos[nroTercetoOp1]->tipo;
	sprintf(op1, "%s", tercetos[nroTercetoOp1]->t1);

	if ((tipoDatoOp1==T_STRING)||tipoDatoOp1==T_CTE_STRING) {
		fprintf(arch, "\tgetString  %s\n", op1);
	} else if ((tipoDatoOp1==T_INT)||tipoDatoOp1==T_CTE_INTEGER) {
		fprintf(arch, "\tGetInteger  %s\n", op1);
	} else if ((tipoDatoOp1==T_FLOAT)||tipoDatoOp1==T_CTE_FLOAT) {
		fprintf(arch, "\tGetFloat  %s\n", op1);
	}
}

void escribirSalto(FILE* arch, char* salto, int tercetoDestino){
    fprintf(arch, "%s ", salto);
	printf("debug::::::> terceto destino %d) leyendo terceto -> %s",tercetoDestino, tercetos[tercetoDestino]->t2);
	fprintf(arch, "%s \n", tercetos[tercetoDestino]->t2);	

	/*
    switch( lista_terceto[tercetoDestino - OFFSET].operador ){
    case THEN:
        fprintf(arch, "then");
        break;
    case ELSE:
        fprintf(arch, "else");
        break;
    case ENDIF:
        fprintf(arch, "endif");
        break;
    case WHILE:
        fprintf(arch, "while");
        break;
    case ENDWHILE:
        fprintf(arch, "endwhile");
		break;
	case INLIST_TRUE:
        fprintf(arch, "inlistTrue");
		break;
	case INLIST_CMP:
        fprintf(arch, "inlistCMP");
    }

    fprintf(arch, "%d\n", tercetoDestino);
	*/
}