*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : Serafí Nebot Ginard
* Date       : 19/05/2023
* Description: Emulador de la HAL9000
*-----------------------------------------------------------
	ORG $1000
EMEM:
	DC.W $000F,$C012,$400A,$D222,$8000,$CA22,$8000,$0001

	; DC.W $E082,$E09B,$E0B4,$E01D,$2020,$C006,$2031,$C017
	; DC.W $F160,$F170,$CE70,$3040,$EFFD,$501E,$4008,$8000
	; DC.W $0001,$0001,$0001,$0001,$0001,$0001,$0000,$0000
	; DC.W $0000
EIR:	DC.W 0 ;eregistro de instruccion
EPC:	DC.W 0 ;econtador de programa
	ORG $1020
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
	MULU #2, D1 ; multiply address by 2 (each position contains 2 Bytes)
	MOVEA.W D1, A0
	MOVE.W EMEM(A0), EIR ; load current instruction to EIR
	ADDQ.W #1, EPC ; increase EPC by 1 *after* fetch
	;--- FFETCH: FIN FETCH

    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
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
	; multiply instruction index by 6 (each jump instruction occuppies 6
	; bytes)
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

	MOVE.W EIR, D2
	LSR.W #1, D2
	ANDI.W #%11111111, D2

	MOVE.W EIR, D3
	ANDI.W #%1, D3

	MULU.W #2, D2
	MOVEA.L D2, A2
	MOVE.W EMEM(A2), D2
	MOVE.W D3, -(SP)
	MOVE.W D2, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%011, -(SP)
	MOVE.L D2, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ESTO:
	CLR.L D3

	MOVE.W EIR, D2
	ANDI.W #%1, D2

	MOVE.W EIR, D3
	LSR.W #1, D3
	ANDI.W #%11111111, D3

	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2
	MULU.W #2, D3
	MOVEA.L D3, A3
	MOVE.W D2, EMEM(A3)

	JMP FETCH
ELOIP:
	CLR.L D4

	MOVE.W EIR, D2
	LSR.W #4, D2
	ANDI.W #%111, D2

	MOVE.W EIR, D3
	ANDI.W #%1, D3

	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D4

	MOVE.W D3, -(SP)
	MOVE.L D4, D5
	MULU.W #2, D5
	MOVEA.L D5, A2
	MOVE.W EMEM(A2), -(SP)
	JSR RSET
	ADDQ.L #4, SP

	ADDQ.W #1, D4
	MOVE.W D2, -(SP)
	MOVE.W D4, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%011, -(SP)
	MOVE.L D4, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ESTIP:
	CLR.L D4

	MOVE.W EIR, D2
	ANDI.W #%1, D2

	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D4

	MOVE.L D4, D5
	MULU.W #2, D5
	MOVEA.L D5, A4
	MOVE.W D2, EMEM(A4)

	ADDQ.W #1, D4
	MOVE.W D3, -(SP)
	MOVE.W D4, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	JMP FETCH
EGOI:
	MOVE.W EIR, D2
	LSR.W #1, D2
	ANDI.W #%11111111, D2

	MOVE.W D2, EPC

	JMP FETCH
EGOZ:
	MOVE.W ESR, D2
	ANDI.W #%1, D2
	BEQ FETCH
	JMP EGOI
EGON:
	MOVE.W ESR, D2
	ANDI.W #%10, D2
	BEQ FETCH
	JMP EGOI
EEXIT:
	SIMHALT
ECOPY:
	CLR.L D2

	MOVE.W EIR, D2
	LSR.W #4, D2
	ANDI.W #%111, D2

	MOVE.W EIR, D3
	ANDI.W #%111, D3

	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	MOVE.W D3, -(SP)
	MOVE.W D2, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%011, -(SP)
	MOVE.L D2, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
EADD:
	CLR.L D2
	CLR.L D3

	MOVE.W EIR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	MOVE.W EIR, D4
	ANDI.W #%111, D4

	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D3

	ADD.L D2, D3
	MOVE.W D4, -(SP)
	MOVE.W D3, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%111, -(SP)
	MOVE.L D3, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ESUB:
	CLR.L D2
	CLR.L D3

	MOVE.W EIR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	MOVE.W EIR, D4
	ANDI.W #%111, D4

	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D3

	NOT.W D3
	ADDQ.L #1, D3
	ADD.L D2, D3

	MOVE.W D4, -(SP)
	MOVE.W D3, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%111, -(SP)
	MOVE.L D3, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
EAND:
	CLR.L D3

	MOVE.W EIR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	MOVE.W EIR, D4
	ANDI.W #%111, D4

	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D3

	AND.W D2, D3
	MOVE.W D4, -(SP)
	MOVE.W D3, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%111, -(SP)
	MOVE.L D3, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ESET:
	CLR.L D2

	MOVE.W EIR, D2
	LSR.W #3, D2
	ANDI.W #%11111111, D2
	EXT.W D2

	MOVE.W EIR, D3
	ANDI.W #%111, D3

	MOVE.W D3, -(SP)
	MOVE.W D2, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%011, -(SP)
	MOVE.L D2, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
EADQ:
	CLR.L D2
	CLR.L D4

	MOVE.W EIR, D2
	LSR.W #3, D2
	ANDI.W #%11111111, D2
	EXT.W D2

	MOVE.W EIR, D3
	ANDI.W #%111, D3

	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D4

	ADD.L D2, D4
	MOVE.W D3, -(SP)
	MOVE.W D4, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%111, -(SP)
	MOVE.L D4, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ELSH:
	CLR.L D3
	CLR.L D5

	MOVE.W EIR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2
	BNE ELSH_N8
	ORI.W #%1000, D2
ELSH_N8:
	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D5

	MOVE.W EIR, D4
	ANDI.W #1, D4
	BNE ELSH_N0
	LSL.L D2, D5
	JMP ELSH_END
ELSH_N0:
	LSR.L D2, D5
ELSH_END:
	MOVE.W D3, -(SP)
	MOVE.W D5, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	MOVE.W #%111, -(SP)
	MOVE.L D5, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
	;--- FEXEC: FIN EJECUCION

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI

	; ESCRIBID VUESTRO CODIGO AQUI
RGET:
	MOVE.L D0, -(SP)
	MOVE.L A0, -(SP)
	CLR.L D0
	MOVE.W 12(SP), D0 ; load register number

	; multiply D0 by 10 (each register instruction batch occuppies 10 Bytes)
	MULU #10, D0
	MOVEA.L D0, A0
	JMP RGLIST(A0) ; jump to corresponding register number
RGLIST:
RGT0:
	MOVE.W ET0, D0
	JMP RG_END
RGT1:
	MOVE.W ET1, D0
	JMP RG_END
RGX2:
	MOVE.W EX2, D0
	JMP RG_END
RGX3:
	MOVE.W EX3, D0
	JMP RG_END
RGX4:
	MOVE.W EX4, D0
	JMP RG_END
RGX5:
	MOVE.W EX5, D0
	JMP RG_END
RGX6:
	MOVE.W EX6, D0
	JMP RG_END
RGX7:
	MOVE.W EX7, D0
	JMP RG_END
RG_END:
	MOVE.W D0, 12(SP)
	MOVE.L (SP)+, A0
	MOVE.L (SP)+, D0
	RTS

RSET:
	MOVE.L D0, -(SP)
	MOVE.L D1, -(SP)
	MOVE.L A0, -(SP)
	CLR.L D0
	MOVE.W 18(SP), D0 ; load register number
	MOVE.W 16(SP), D1 ; load register value

	; multiply D0 by 10 (each register instruction batch occuppies 10 Bytes)
	MULU #10, D0
	MOVEA.L D0, A0
	JMP RSLIST(A0) ; jump to corresponding register number
RSLIST:
RST0:
	MOVE.W D1, ET0
	JMP RS_END
RST1:
	MOVE.W D1, ET1
	JMP RS_END
RSX2:
	MOVE.W D1, EX2
	JMP RS_END
RSX3:
	MOVE.W D1, EX3
	JMP RS_END
RSX4:
	MOVE.W D1, EX4
	JMP RS_END
RSX5:
	MOVE.W D1, EX5
	JMP RS_END
RSX6:
	MOVE.W D1, EX6
	JMP RS_END
RSX7:
	MOVE.W D1, EX7
	JMP RS_END
RS_END:
	MOVE.L (SP)+, A0
	MOVE.L (SP)+, D1
	MOVE.L (SP)+, D0
	RTS

FLAGS:
	MOVE.L D0, -(SP)
	MOVE.L D1, -(SP)
	MOVE.L D2, -(SP)
	MOVE.L 16(SP), D0 ; load value
	MOVE.W 20(SP), D2 ; load selected flags to update
	MOVE.L D0, D1

	; shift right 14 bits so that negative and carry bits
	; can be OR'ed together with Z flag
	LSR.L #8, D1
	LSR.L #6, D1
	ANDI.W #%110, D1
	; check if value is 0
	ANDI.W #$ffff, D0
	BNE FLAGSNZ
	ORI.W #%001, D1 ; value = 0 -> set Z bit to 1
FLAGSNZ:
	; mask selected flags' values
	AND.W D2, D1
	; negate mask so that selected flags are cleared
	NOT.W D2
	ANDI.W #%111, D2
	AND.W D2, ESR ; clear selected flags
	OR.W D1, ESR ; update selected flags
	MOVE.L (SP)+, D2
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
	BTST.L #15, D0
	BEQ.S DECOD_END ; if bit 15 = 0 jump to end
	LSL.W #1, D0 ; left shift to "normalize" 5 bit opcode to 4 bit opcode
	BTST.L #15, D0
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

