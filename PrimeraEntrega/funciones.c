#include "funciones.h"

t_simbolo tablaSimbolos[100];
int posActualTablaSimbolos = 0;

int indiceString = 0;

int tsCrearArchivo() {
	int i;
	FILE *archivo;

	archivo = fopen("ts.txt", "w");
	if (!archivo) {
		printf("Error en crear el archivo ts.txt [Tabla de Simbolos]\n");
		return 1;
	}

	// Cabecera del archivo
	fprintf(archivo," Nombre                          | Tipo          | Valor                          | Longitud |\n");
	fprintf(archivo,"---------------------------------|---------------|--------------------------------|----------|\n");

	// Se escribe linea por linea
	for (i = 0; i < posActualTablaSimbolos; i++) {
		fprintf(archivo, "%-33s|%-15s|%-32s|%-10d|\n", tablaSimbolos[i].nombre, obtenerNombreTipo(tablaSimbolos[i].tipo), tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
	}
	fclose(archivo);

	return 0;
}


void insertarTablaSimbolos(char * nombre, int tipo, char * dato, int longitud) {
    int i;
    for (i = 0; i < posActualTablaSimbolos; i++)
		if (strcmp(tablaSimbolos[i].nombre, nombre) == 0) {
			return;
		}
	t_simbolo tmp;
	strcpy(tmp.nombre, nombre);
	tmp.tipo = tipo;
	strcpy(tmp.dato, dato);
	tmp.longitud = longitud;
	tablaSimbolos[posActualTablaSimbolos++] = tmp;
}


void mostrarTablaSimbolos() {
	int i;
	printf("Cantidad de simbolos en tabla: %d\n", posActualTablaSimbolos);
	for(i = 0; i < posActualTablaSimbolos ; i++) {
		printf("POS. %d, NOMBRE %s, TIPO %d, DATO %s, LONGITUD %d\n", i, tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].dato, tablaSimbolos[i].longitud);
	}
}


char * obtenerNombreTipo(const int tipo) {
	switch(tipo) {
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

char * indicarNombreConstante(const char * valor) {
	char nombre[100] = "_";
	strcat(nombre, valor);
	return strdup(nombre);
}

char * indicarNombreConstanteString(const char * valor) {
//	char nombre[100];
//    sprintf(nombre, "_%s", valor);
//	return strdup(nombre);
	char *aux = (char *) malloc( sizeof(char) * (strlen(valor)) + 2);
	char *retor = (char *) malloc( sizeof(char) * (strlen(valor)) + 2);
	
	strcpy(retor,valor);
	int len = strlen(valor);
	retor[len-1] = '\0';
	
	strcpy(aux,"_");
	strcat(aux,++retor);
	
	return aux;
}

char * reemplazarCaracter(char * aux){
	int i=0;
	for(i = 0; i <= strlen(aux); i++) {
  		if(aux[i] == '\t' || aux[i] == '\r' || aux[i] == ' ') {
  			aux[i] = '_';
 		}

		if(aux[i] == '.') {
  			aux[i] = 'p';
 		}
	}
	return aux;
}

/** FUNCION QUE OBTIENE EL TIPO DE DATO DE UN LEXEMA EN LA TS **/
int obtenerTipoDato(char *valor) {
	int i, auxTipo = -1, flagEncontrado = 0;
	char * auxNombre ;

	for (i = 0; i < posActualTablaSimbolos; i++) {
		auxNombre = tablaSimbolos[i].nombre;

		if(strcmp(auxNombre, valor)==0) {
			auxTipo = tablaSimbolos[i].tipo;
		}
	}
	return auxTipo;
}

//Función actualizar_tipo_dato: Función que recorre la lista de simbolos buscando IDs sin tipo de datos para asignarle el tipo correcto.
void actualizarTipoDato(int tipo){
	int i;
	int tipo_simb;
	
	for (i = 0; i < posActualTablaSimbolos; i++) {
		tipo_simb = tablaSimbolos[i].tipo;
		
		if(tipo_simb == T_ID) {
			tablaSimbolos[i].tipo = tipo;
		}
	}
}

void verificarExisteId(char *valor) {
	int i, auxTipo, flagEncontrado = 0;
	char * auxNombre ;
	
	for (i = 0; i < posActualTablaSimbolos; i++) {
		auxNombre = tablaSimbolos[i].nombre;
		auxTipo = tablaSimbolos[i].tipo;
		
		if(strcmp(auxNombre, valor)==0 && auxTipo != T_ID) {
			flagEncontrado = 1;
		}
	}
	
	if(flagEncontrado == 0) {
		printf("Descripcion: el id '%s' no ha sido declarado\n", valor);
		system ("Pause");
		exit(1);
	}
}


void validarTipoDato(int td1, int td2, int linea, int operacion) {
	char charOperacion[30];

	if (operacion == 0){
		sprintf(charOperacion, "asignacion");
	} else {
		sprintf(charOperacion, "comparacion");
	}

    if(td1==T_INT && td2!=T_CTE_INTEGER && td2!=T_INT) {
        printf("\tError en %s por tipo de datos Entero - Linea :: %d\n", charOperacion, linea);
        system ("Pause");
    	exit (1);
    }

    if(td1==T_FLOAT && td2!=T_CTE_FLOAT && td2!=T_FLOAT) {
        printf("\tError en %s por tipo de datos Real - Linea :: %d\n", charOperacion, linea);
        system ("Pause");
    	exit (1);
    }

    if(td1==T_STRING && td2!=T_CTE_STRING && td2!=T_STRING) {
        printf("\tError en %s por tipo de datos String - Linea :: %d\n", charOperacion, linea);
        system ("Pause");
    	exit (1);
    }
}

int obtenerTipoDatoOperacion(int td1, int td2) {
	if((td1==T_INT || td1==T_CTE_INTEGER) && (td2==T_CTE_INTEGER|| td2==T_INT)){
		return T_INT;
	}

	if((td1==T_FLOAT || td1==T_CTE_FLOAT) && (td2==T_CTE_FLOAT || td2==T_FLOAT)) {
        return T_FLOAT;
    }

    if((td1==T_STRING || td1==T_CTE_STRING) && (td2==T_CTE_STRING || td2==T_STRING)) {
        return T_STRING;
    }

    return T_ID;
}

void validarDivisionPorCero(char* dato) {
	if(strcmp(dato,"0")==0) {
		printf("Error :: No se puede dividir un numero por CERO.\n");
		system("pause");
		exit(1);
	}
}