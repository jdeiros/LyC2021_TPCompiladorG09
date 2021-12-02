flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe funciones.c lex.yy.c y.tab.c -o Final.exe
pause
Final.exe ../TestFiles/prueba_if.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Final.exe
pause
