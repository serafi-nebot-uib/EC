*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : Serafí Nebot Ginard
* Date       : 19/05/2023
* Description: Emulador de la HAL9000
*-----------------------------------------------------------
	ORG $1000
EMEM:	
	DC.W $E4E2,$E673,$E004,$E005,$D230,$D451,$8000

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
	ADDQ.W #1, EPC ; increase EPC by 1 after fetch
	;--- FFETCH: FIN FETCH

    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

		; ESCRIBID VUESTRO CODIGO AQUI
	SUBQ.W #2, SP ; reserve 1 word for instruction id
	MOVE.W EIR, -(SP) ; pass instruction to decode
	JSR DECOD
	ADDQ.W #2, SP ; pop instruction to decode from stack
	MOVE.W (SP)+, D1 ; retrieve instruction's id
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

	; NOTE on the following list of EINSTRUCTIONS implementations
	;   - RGET and RSET subroutines are used to get or set eregisters
	;   - EMEM is accessed with indexed mode
	;       (indexes are multiplied by 2 as each ememory cell contains 2 Bytes)
	;   - AND instruction is used in instead of BTST as the former allows
	;       all possible sizes and the latter only allows byte and longword
	;   - FLAGS subroutine is used to update specific flags
	;   - Arithmetic operations are performed with longword size as the
	;       result will contain the carry bit (passed to FLAGS subroutine)
ELOA:
	CLR.L D2

	; load M operand to D2
	MOVE.W EIR, D2
	LSR.W #1, D2
	ANDI.W #%11111111, D2

	; load Ti operand to D3
	MOVE.W EIR, D3
	ANDI.W #%1, D3

	; load value at address M
	MULU.W #2, D2
	MOVEA.L D2, A2
	MOVE.W EMEM(A2), D2

	; set Ti to the value at address M (Ti <- [M])
	MOVE.W D3, -(SP)
	MOVE.W D2, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; update NZ falgs from ESR
	MOVE.W #%011, -(SP)
	MOVE.L D2, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ESTO:
	CLR.L D3

	; load Ti operand to D2
	MOVE.W EIR, D2
	ANDI.W #%1, D2

	; load M operand to D3
	MOVE.W EIR, D3
	LSR.W #1, D3
	ANDI.W #%11111111, D3

	; get value of Ti
	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	; store value of Ti to address M (M <- [Ti])
	MULU.W #2, D3
	MOVEA.L D3, A3
	MOVE.W D2, EMEM(A3)

	JMP FETCH
ELOIP:
	CLR.L D4

	; load Xb operand to D2
	MOVE.W EIR, D2
	LSR.W #4, D2
	ANDI.W #%111, D2

	; load Ti operand to D3
	MOVE.W EIR, D3
	ANDI.W #%1, D3

	; get value of Xb
	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D4

	; set value at address Xb to Ti (Ti <- [[Xb]])
	MOVE.W D3, -(SP)
	MOVE.L D4, D5
	MULU.W #2, D5
	MOVEA.L D5, A2
	MOVE.W EMEM(A2), -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; set Xb to Xb + 1 (Xb <- [Xb] + 1)
	ADDQ.W #1, D4
	MOVE.W D2, -(SP)
	MOVE.W D4, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; set flags NZ from ESR
	MOVE.W #%011, -(SP)
	MOVE.L D4, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ESTIP:
	CLR.L D4

	; load Ti operand to D2
	MOVE.W EIR, D2
	ANDI.W #%1, D2

	; load Xb operand to D3
	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	; get value of Ti
	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	; get value of Xb
	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D4

	; load value at address Xb
	MOVE.L D4, D5
	MULU.W #2, D5
	MOVEA.L D5, A4
	MOVE.W D2, EMEM(A4)

	; set Xb to Xb + 1 (Xb <- [Xb] + 1)
	ADDQ.W #1, D4
	MOVE.W D3, -(SP)
	MOVE.W D4, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	JMP FETCH
EGOI:
	; load M operand to D2
	MOVE.W EIR, D2
	LSR.W #1, D2
	ANDI.W #%11111111, D2

	; set EPC to M (EPC <- M)
	MOVE.W D2, EPC

	JMP FETCH
EGOZ:
	; check Z flag from ESR
	MOVE.W ESR, D2
	ANDI.W #%1, D2
	BEQ FETCH ; Z = 0 -> end instruction execution
	JMP EGOI ; unconditional jump
EGON:
	; check N flag from ESR
	MOVE.W ESR, D2
	MOVE.W ESR, D2
	ANDI.W #%10, D2
	BEQ FETCH ; N = 0 -> end instruction execution
	JMP EGOI ; unconditional jump
EEXIT:
	SIMHALT
ECOPY:
	CLR.L D2

	; load Rb operand to D2
	MOVE.W EIR, D2
	LSR.W #4, D2
	ANDI.W #%111, D2

	; load Rc operand to D3
	MOVE.W EIR, D3
	ANDI.W #%111, D3

	; get value of Rb
	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	; set Rc to the value of Rb (Rc <- [Rb])
	MOVE.W D3, -(SP)
	MOVE.W D2, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; update NZ flags from ESR
	MOVE.W #%011, -(SP)
	MOVE.L D2, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
EADD:
	CLR.L D2
	CLR.L D3

	; load Ra operand to D2
	MOVE.W EIR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	; load Rb operand to D3
	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	; load Rc operand to D4
	MOVE.W EIR, D4
	ANDI.W #%111, D4

	; get value of Ra
	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	; get value of Rb
	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D3

	; set Rc to Rb + Ra (Rc <- [Rb] + [Ra])
	ADD.L D2, D3
	MOVE.W D4, -(SP)
	MOVE.W D3, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; update CNZ flags from ESR
	MOVE.W #%111, -(SP)
	MOVE.L D3, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ESUB:
	CLR.L D2
	CLR.L D3

	; load Ra operand to D2
	MOVE.W EIR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	; load Rb operand to D3
	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	; load Rc operand to D4
	MOVE.W EIR, D4
	ANDI.W #%111, D4

	; get value of Ra
	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	; get value of Rb
	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D3

	; subtract Ra to Rb (Rb + (Ra' + 1))
	NOT.W D2
	ADDQ.L #1, D2
	ADD.L D2, D3

	; set Rc to Rb - Ra
	MOVE.W D4, -(SP)
	MOVE.W D3, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; update CNZ flags from ESR
	MOVE.W #%111, -(SP)
	MOVE.L D3, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
EAND:
	CLR.L D3

	; load Ra operand to D2
	MOVE.W EIR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2

	; load Rb operand to D3
	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	; load Rc operand to D4
	MOVE.W EIR, D4
	ANDI.W #%111, D4

	; get value of Ra
	MOVE.W D2, -(SP)
	JSR RGET
	MOVE.W (SP)+, D2

	; get value of Rb
	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D3

	; set Rc to Rb and Ra (Rc <- [Rb] and [Rc])
	AND.W D2, D3
	MOVE.W D4, -(SP)
	MOVE.W D3, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; update flags CNZ from ESR
	MOVE.W #%111, -(SP)
	MOVE.L D3, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ESET:
	CLR.L D2

	; load k operand to D2
	MOVE.W EIR, D2
	LSR.W #3, D2
	ANDI.W #%11111111, D2
	EXT.W D2 ; sign extend form byte to word size

	; load Rc operand to D3
	MOVE.W EIR, D3
	ANDI.W #%111, D3

	; set Rc to k (Rc <- k)
	MOVE.W D3, -(SP)
	MOVE.W D2, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; update flags NZ from ESR
	MOVE.W #%011, -(SP)
	MOVE.L D2, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
EADQ:
	CLR.L D2
	CLR.L D4

	; load k operand to D2
	MOVE.W EIR, D2
	LSR.W #3, D2
	ANDI.W #%11111111, D2
	EXT.W D2 ; sign extend from byte to word size

	; load Rc operand to D3
	MOVE.W EIR, D3
	ANDI.W #%111, D3

	; get value of Rc
	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D4

	; add k to the value of Rc
	ADD.L D2, D4
	;  set Rc to Rc + k (Rc <- [Rc] + k)
	MOVE.W D3, -(SP)
	MOVE.W D4, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; update CNZ flags from ESR
	MOVE.W #%111, -(SP)
	MOVE.L D4, -(SP)
	JSR FLAGS
	ADDQ.L #6, SP

	JMP FETCH
ELSH:
	CLR.L D3
	CLR.L D5

	; load p operand to D2
	MOVE.W EIR, D2
	LSR.W #8, D2
	ANDI.W #%111, D2
	; if p = 0 -> p = 8
	BNE ELSH_N8
	ORI.W #%1000, D2
ELSH_N8:
	; load Rb operand to D3
	MOVE.W EIR, D3
	LSR.W #4, D3
	ANDI.W #%111, D3

	; get value of Rb
	MOVE.W D3, -(SP)
	JSR RGET
	MOVE.W (SP)+, D5

	; load n operand to D4
	MOVE.W EIR, D4
	ANDI.W #1, D4
	; check value of n
	BNE ELSH_N0
	LSL.L D2, D5 ; n = 0 -> left shift
	JMP ELSH_END
ELSH_N0:
	LSR.L D2, D5 ; n = 1 -> right shift
ELSH_END:
	; set Rb to shifted value
	MOVE.W D3, -(SP)
	MOVE.W D5, -(SP)
	JSR RSET
	ADDQ.L #4, SP

	; update CNZ flags from ESR
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

