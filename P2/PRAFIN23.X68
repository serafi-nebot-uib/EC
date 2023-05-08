*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : Serafí Nebot Ginard
* Date       : 19/05/2023
* Description: Emulador de la HAL9000
*-----------------------------------------------------------
	ORG $1000

EMEM:	DC.W $E082,$E09B,$E0B4,$E01D,$2020,$C006,$2031,$C017
        DC.W $F160,$F170,$CE70,$3040,$EFFD,$501E,$4008,$8000
        DC.W $0001,$0001,$0001,$0001,$0001,$0001,$0000,$0000
        DC.W $0000
EIR:	DC.W 0 ;eregistro de instruccion
EPC:	DC.W 0 ;econtador de programa
ET0:	DC.W 0 ;eregistro T0
ET1:	DC.W 0 ;eregistro T1
EX2:	DC.W 0 ;eregistro X2
EX3:	DC.W 0 ;eregistro X3
EX4:	DC.W 0 ;eregistro X4
EX5:	DC.W 0 ;eregistro X5
EX6:	DC.W 0 ;eregistro X6
EX7:	DC.W 0 ;eregistro X7
ESR:	DC.W 0 ;eregistro de estado (00000000 00000CNZ)

START:
	CLR.W EPC

FETCH:
	;--- IFETCH: INICIO FETCH
	;*** En esta seccion debeis introducir el codigo necesario para cargar
	;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
		;*** y dejar listo el EPC para que apunte a la siguiente instruccion

		; ESCRIBID VUESTRO CODIGO AQUI	    
	MOVE.W EPC, D1
	MULU #2, D1
	MOVEA.W D1, A0
	MOVE.W EMEM(A0), EIR
	ADDQ.W #1, EPC
		;--- FFETCH: FIN FETCH



		;--- IBRDECOD: INICIO SALTO A DECOD
		;*** En esta seccion debeis preparar la pila para llamar a la subrutina
		;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
		;*** almacenando el resultado de la decodificacion en D1

		; ESCRIBID VUESTRO CODIGO AQUI    	    
	SUBQ.W #2, SP
	MOVE.W EIR, -(SP)
	JSR DECOD
	ADDQ.W #2, SP
	MOVE.W (SP)+, D1
		;--- FBRDECOD: FIN SALTO A DECOD



		;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
		;*** Esta seccion se usa para saltar a la fase de ejecucion
		;*** NO HACE FALTA MODIFICARLA
	MULU #6, D1
	MOVEA.L D1, A1
	JMP JMPLIST(A1)
JMPLIST:
	JMP ELOA
	JMP ESTO
	JMP ELOIP
	JMP ESTIP
	JMP EGOI
	JMP EGOZ
	JMP EGON
	JMP EEXIT
	JMP ECOPY
	JMP EADD
	JMP ESUB
	JMP EAND
	JMP ESET
	JMP EADQ
	JMP ELSH
	;--- FBREXEC: FIN SALTO A FASE DE EJECUCION



	;--- IEXEC: INICIO EJECUCION
	;*** En esta seccion debeis implementar la ejecucion de cada einstr.

	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ELOA:
	CLR.L D2
	CLR.L D3

	MOVE.W EIR, D2
	LSR.W #1, D2
	ANDI.W #%11111111, D2

	MOVE.W EIR, D3
	ANDI.W #%1, D3 ; dst

	MULU #2, D2
	MULU #2, D3
	MOVEA.L D2, A2
	MOVEA.L D3, A3
	MOVE.W EMEM(A2), ET0(A3)

	; update flags
	SUBQ.L #2, SP
	MOVE.L ET0(A3), -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, D2
	ANDI.B #%011, D2
	ANDI.B #%100, ESR
	OR.B D2, ESR

	JMP FETCH
ESTO:
	CLR.L D2
	CLR.L D3

	MOVE.W EIR, D2
	LSR.W #1, D2
	ANDI.W #%11111111, D2 ; src

	MOVE.W EIR, D3
	ANDI.W #%1, D3 ; dst

	MULU.W #2, D2
	MULU.W #2, D3
	MOVEA.L D2, A2
	MOVEA.L D3, A3
	MOVE.W ET0(A3), EMEM(A2)

	JMP FETCH
ELOIP:
	CLR.L D2
	CLR.L D3
	MOVEA.L #0, A4

	; load src
	MOVE.W EIR, D2
	LSR.W #4, D2
	ANDI.W #%111, D2

	; load dst
	MOVE.W EIR, D3
	ANDI.W #%1, D3

	; perform operation
	MULU.W #2, D2
	MULU.W #2, D3
	MOVEA.L D2, A2
	MOVEA.L D3, A3
	MOVE.W ET0(A2), D4
	MULU.W #2, D4
	MOVE.W D4, A4
	MOVE.W EMEM(A4), ET0(A3)
	ADDQ.W #1, ET0(A2)

	; update flags
	SUBQ.L #2, SP
	MOVE.L ET0(A3), -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, D2
	ANDI.B #%011, D2
	ANDI.B #%100, ESR
	OR.B D2, ESR

	JMP FETCH
ESTIP:
	CLR.L D2
	CLR.L D3
	MOVEA.L #0, A4

	; load src
	MOVE.W EIR, D2
	ANDI.W #%1, D2

	; load dst
	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	MULU.W #2, D2
	MULU.W #2, D3
	MOVEA.L D2, A2
	MOVEA.L D3, A3
	MOVE.W ET0(A3), D4
	MULU.W #2, D4
	MOVE.W D4, A4
	MOVE.W ET0(A2), EMEM(A4)
	ADDQ.W #1, ET0(A3)

	JMP FETCH
EGOI:
	MOVE.W EIR, D2
	LSR.W #1, D2
	ANDI.W #%11111111, D2

	MOVE.W D2, EPC

	JMP FETCH
EGOZ:
	BTST #0, ESR
	BEQ FETCH
	JMP EGOI
EGON:
	BTST #1, ESR
	BEQ FETCH
	JMP EGOI
EEXIT:
	SIMHALT
ECOPY:
	; src
	MOVE.W EIR, D2
	LSR.W #4, D2
	ANDI.W #%111, D2

	; dst
	MOVE.W EIR, D3
	ANDI.W #%111, D3

	MULU.W #2, D2
	MULU.W #2, D3
	MOVEA.L D2, A2
	MOVEA.L D3, A3
	MOVE.W ET0(A2), ET0(A3)

	; update flags
	SUBQ.L #2, SP
	MOVE.L ET0(A3), -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, D2
	ANDI.B #%011, D2
	ANDI.B #%100, ESR
	OR.B D2, ESR

	JMP FETCH
EADD:
	CLR.L D2
	CLR.L D3
	CLR.L D4
	MOVEA.L #0, A2
	MOVEA.L #0, A3
	MOVEA.L #0, A4

	MOVE.W ESR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	MOVE.W ESR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	MOVE.W ESR, D4
	ANDI.W #%111, D4

	MULU.W #2, D2
	MULU.W #2, D3
	MULU.W #2, D4
	MOVEA.L D2, A2
	MOVEA.L D3, A3
	MOVEA.L D4, A4
	MOVE.W ET0(A2), D2
	MOVE.W ET0(A3), D3
	ADD.L D2, D3
	MOVE.W D3, ET0(A4)

	; update flags
	SUBQ.L #2, SP
	MOVE.L ET0(A3), -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, ESR

	JMP FETCH
ESUB:
	CLR.L D2
	CLR.L D3
	CLR.L D4
	MOVEA.L #0, A4

	; Ra
	MOVE.W ESR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	; Rb
	MOVE.W ESR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	; Rc
	MOVE.W ESR, D4
	ANDI.W #%111, D4

	; subtract
	NOT.L D2
	ADDQ.L #1, D2
	ADD.L D3, D2
	MULU.W #2, D4
	MOVEA.L D4, A4
	MOVE.W D2, ET0(A4)

	; update flags
	SUBQ.L #2, SP
	MOVE.L D2, -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, ESR

	JMP FETCH
EAND:
	CLR.L D2
	CLR.L D3
	CLR.L D4
	MOVEA.L #0, A4

	; Ra
	MOVE.W ESR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	; Rb
	MOVE.W ESR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	; Rc
	MOVE.W ESR, D4
	ANDI.W #%111, D4

	AND.W D2, D3
	MULU.W #2, D4
	MOVEA.L D4, A4
	MOVE.W D3, ET0(A4)

	; update flags
	SUBQ.L #2, SP
	MOVE.L ET0(A4), -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, D2
	ANDI.B #%011, D2
	ANDI.B #%100, ESR
	OR.B D2, ESR

	JMP FETCH
ESET:
	CLR.L D2
	CLR.L D3

	MOVE.W EIR, D2
	LSR.W #3, D2
	ANDI.W #%11111111, D2 ; src
	EXT.W D2

	MOVE.W EIR, D3
	ANDI.W #%111, D3 ; dst

	MULU.W #2, D3
	MOVEA.L D3, A3
	MOVE.W D2, ET0(A3)

	; update flags
	SUBQ.L #2, SP
	MOVE.L D2, -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, D2
	ANDI.B #%011, D2
	ANDI.B #%100, ESR
	OR.B D2, ESR

	JMP FETCH
EADQ:
	CLR.L D2
	CLR.L D3
	CLR.L D4
	MOVEA.L #0, A3

	; src
	MOVE.W EIR, D2
	LSR.W #3, D2
	ANDI.W #%11111111, D2 ; src
	EXT.W D2

	; dst
	MOVE.W EIR, D3
	ANDI.W #%111, D3

	MULU.W #2, D3
	MOVEA.L D3, A3
	MOVE.W ET0(A3), D4
	ADD.L D2, D4
	MOVE.W D4, ET0(A3)

	; update flags
	SUBQ.L #2, SP
	MOVE.L D4, -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, ESR
	
	JMP FETCH
ELSH:
	CLR.L D2
	CLR.L D3

	; p
	MOVE.W ESR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	; Rb
	MOVE.W ESR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	MULU.W #2, D3
	MOVEA.L D3, A3
	BTST #0, ESR
	BNE ELSH_N0
	MOVE.W ET0(A3), D3
	LSL.W D2, D3
	JMP ELSH_END
ELSH_N0:
	LSR.W D2, D3
ELSH_END:
	; update flags
	MOVE.W D3, ET0(A3)
	SUBQ.L #2, SP
	MOVE.L D3, -(SP)
	JSR FLAGS
	ADDQ.L #4, SP
	MOVE.W (SP)+, ESR
	
	JMP FETCH

	;--- FEXEC: FIN EJECUCION



	;--- ISUBR: INICIO SUBRUTINAS
	;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
	;*** SALVO DECOD, que va en la siguiente seccion

	; ESCRIBID VUESTRO CODIGO AQUI
FLAGS:
	MOVE.L D0, -(SP)
	MOVE.L D1, -(SP)
	MOVE.L 12(SP), D0
	MOVE.L D0, D1

	LSR.L #8, D1
	LSR.L #6, D1
	ANDI.W #%110, D1
	ANDI.W #$ffff, D0
	BNE FLAGSZ
	ORI.W #%001, D1
FLAGSZ:
	MOVE.W D1, 16(SP)
	MOVE.L (SP)+, D1
	MOVE.L (SP)+, D0
	RTS
	;--- FSUBR: FIN SUBRUTINAS



	;--- IDECOD: INICIO DECOD
	;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
	;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
	;*** especificada en el enunciado
DECOD:
	; ESCRIBID VUESTRO CODIGO AQUI
	MOVE.L D0, -(SP) ; save current value of D0
	MOVE.W 8(SP), D0 ; load instruction
	BTST #15, D0
	BEQ.S DECOD_END ; if bit 15 = 0 jump to end
	LSL.W #1, D0 ; left shift to "normalize" 5 bit opcode to 4 bit opcode
	BTST #15, D0
	BNE.S DECOD_END ; if bit 15 = 1 jump to end
	MOVE.W #%0111000000000000, D0 ; if bit 15 = 0 then instruction = EXIT
DECOD_END:
	; shift right the four MSb to the four LSb
	LSR.W #8, D0
	LSR.W #4, D0
	MOVE.W D0, 10(SP) ; save instruction ID to reserved space
	MOVE.L (SP)+, D0 ; restore value of D0
	RTS

	;--- FDECOD: FIN DECOD
	END	START

