flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe funciones.c lex.yy.c y.tab.c -o Segunda.exe
pause
Segunda.exe Prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Segunda.exe
pause
