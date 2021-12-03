;
;ARCHIVO FINAL.ASM
;

INCLUDE macros2.asm		 ;incluye macros
INCLUDE number.asm		 ;incluye el asm para impresion de numeros

.MODEL LARGE ; tipo del modelo de memoria usado.
.386
.STACK 200h ; bytes en el stack
	
.DATA ;variables de la tabla de simbolos.
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
	a                               	dd	?
	b                               	dd	?
	c                               	dd	?
	_estoy                          	db	"estoy" ,'$',7          dup (?)

.CODE
START:
	MOV AX,@DATA
	MOV DS,AX
	MOV es,ax

	fld a
	fld b
	fxch
	fcomp
	fstsw ax
	ffree st(0)
	sahf
JNE FinIF_5 	DisplayInteger  a
	newline
FinIF_5
TERMINAR: ;Fin de ejecución.
	mov ax, 4C00h ; termina la ejecución.
	int 21h; syscall

END START;final del archivo.