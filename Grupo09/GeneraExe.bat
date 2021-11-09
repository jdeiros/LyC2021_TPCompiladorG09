flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe funciones.c lex.yy.c y.tab.c -o Primera.exe
pause
Primera.exe ../TestFiles/prueba_variables.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Primera.exe
pause
