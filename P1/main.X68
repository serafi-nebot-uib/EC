*--------------------------------------------
* Titulo : P1 (2022-2023) - Caesar Cipher
* Autores: Serafí Nebot Ginard
*--------------------------------------------
		ORG $1000
DISP:		EQU 3
DICT_SIZE:	EQU 5
DICT_IN:	DC.B 'ABCDE'
DICT_OUT:	DS.B DICT_SIZE
TEXT_SIZE:	EQU 26
TEXT_IN:	DC.B 'ESTRUCTURA DE COMPUTADORES'
TEXT_OUT:	DS.B TEXT_SIZE
NCHANGES:	DS.W 1
		DS.W 0
*--------------------------------------------

START:
	MOVEA #0, A0
	MOVE.W #DICT_SIZE-1, D0
ROT_LOOP:
	MOVE.L A0, D1
	* subtract 1 from offset in order to get the correct index
	* because DICT_[IN,OUT] are 0 indexed vectors
	ADD.W #DISP-1, D1
	MOVE.L #DICT_SIZE, D2
	* calculate the remainer of the index in order to wrap around the vector
	DIVU D2, D1
	LSR.L #8, D1
	LSR.L #8, D1
	MOVEA D1, A1
	* perform the rotation
	MOVE.B DICT_IN(A1), DICT_OUT(A0)
	ADDA #1, A0
	DBRA D0, ROT_LOOP

	SIMHALT
	END START
