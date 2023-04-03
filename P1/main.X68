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
	MOVEA #0, A0 * set A0 to 0 to point at the first element of DICT_
	MOVE.W #DICT_SIZE-1, D0 * D0 as loop counter (DICT_SIZE-1 ... -1 =
	* DICT_SIZE)
DROT_LP:
	* DICT_OUT_INDEX = (INDEX + (DISP - 1)) % DICT_SIZE
	MOVE.L A0, D1
	* subtract 1 from offset in order to get the correct index
	* because DICT_[IN,OUT] are 0 indexed vectors
	ADD.W #DISP-1, D1
	MOVE.L #DICT_SIZE, D2
	* calculate the remainer of the index in order to wrap around the vector
	DIVU D2, D1
	* shift the result of D1 / D2 to get the remainder
	* the remainder is stored in the lower word (smallest address of the two
	* words contained in D1) it must be shifted right 1 word (16 bits)
	* 
	* a shift right of 16 bits cannot be performed with a single instruction
	* so it is split into two 8 bit shifts
	LSR.L #8, D1
	LSR.L #8, D1
	* perform the rotation from DICT_IN into DICT_OUT
	MOVEA D1, A1
	MOVE.B DICT_IN(A1), DICT_OUT(A0)
	ADDA #1, A0 * advance DICT_OUT index by one (1 Byte)
	DBRA D0, DROT_LP

	MOVE.W #TEXT_SIZE-1, D0
	CLR.W NCHANGES
TROT_LP:
	MOVE.L D0, A0
	MOVE.B TEXT_IN(A0), D1
	MOVE.L #DICT_SIZE-1, D2
CHK_LP:
	MOVEA D2, A1
	MOVE.B DICT_IN(A1), D3
	CMP.W D1, D3
	BNE CHK_NE
	MOVE.B DICT_OUT(A1), D1
	ADDI.W #1, NCHANGES
	JMP CHK_DONE
CHK_NE:
	DBRA D2, CHK_LP
CHK_DONE:
	MOVE.B D1, TEXT_OUT(A0)
	DBRA D0, TROT_LP

	TRAP #15

	END START
