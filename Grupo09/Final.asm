;
;ARCHIVO FINAL.ASM
;

INCLUDE macros2.asm		 ;incluye macros
INCLUDE number.asm		 ;incluye el asm para impresion de numeros

.MODEL LARGE ; tipo del modelo de memoria usado.
.386
.STACK 200h ; bytes en el stack
	
.DATA ; comienzo de la zona de datos.
	TRUE equ 1
	FALSE equ 0
	MAXTEXTSIZE equ 200
	R1                              	dd	?
	@aux1                             	dd	?
	@aux2                             	dd	?
	@aux3                             	dd	?
	@aux4                             	dd	?
	@aux5                             	dd	?
	@aux6                             	dd	?
	@aux7                             	dd	?
	@aux8                             	dd	?
	@aux9                             	dd	?
	@aux10                            	dd	?
	@aux11                            	dd	?
	@aux12                            	dd	?
	@aux13                            	dd	?
	@aux14                            	dd	?
	@aux15                            	dd	?
	A                               	dd	?
	B                               	dd	?
	C                               	dd	?
	D                               	dd	?
	E                               	dd	?
	var1                            	dd	?
	s3                              	dd	?
	_5                              	dd	5
	_10p3                           	dd	10.3
	_hola                           	db	"hola" ,'$',6          dup (?)
	_FOR                            	db	"FOR" ,'$',5          dup (?)
	_120                            	dd	120
	_10                             	dd	10
	_101                            	dd	101
	_100                            	dd	100
	_111                            	dd	111
	_EQUMAX                         	db	"EQUMAX" ,'$',8          dup (?)
	_EQUMIN                         	db	"EQUMIN" ,'$',8          dup (?)
	_1p3                            	dd	1.3
	_4                              	dd	4
	_8p3                            	dd	8.3
	_9                              	dd	9
	_3                              	dd	3
	_IF_anidado                     	db	"IF anidado" ,'$',12         dup (?)
	_condicion_compuesta            	db	"condicion compuesta" ,'$',21         dup (?)
	_IF_exterior                    	db	"IF exterior" ,'$',13         dup (?)
	_regla_de_IF_con_ELSE           	db	"regla de IF con ELSE" ,'$',22         dup (?)
	_HOLA                           	db	"HOLA" ,'$',6          dup (?)
	_HOLA_TODO_BIEN                 	db	"HOLA TODO BIEN" ,'$',16         dup (?)
	_Mostrar_por_pantalla           	db	"Mostrar por pantalla" ,'$',22         dup (?)
