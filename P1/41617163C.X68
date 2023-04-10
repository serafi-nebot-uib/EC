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
	* The DICT shift offset is calculated using the following technique:
	* 1. Offset current index by DISP: index + DISP
	* 2. Wrap around the vector by calculating the overflow amount
	*	formula (% = remainder operation): (index + DISP) % DICT_SIZE
	* e.g.:
	*	(DICT_IN_INDEX + DISP) % DICT_SIZE = DICT_OUT_INDEX
	* 
	*	DISP = 4
	*	DICT_SIZE = 5
	*	
	*	(0 + 4) % 5 = 4
	*	(1 + 4) % 5 = 0
	*	(2 + 4) % 5 = 1
	*	(3 + 4) % 5 = 2
	*	(4 + 4) % 5 = 3
	MOVEA.L #0, A0
	MOVE.W #DICT_SIZE-1, D0
DROT_LP:
	MOVE.L D0, D1
	ADD.W #DISP, D1
	MOVE.L #DICT_SIZE, D2
	DIVU D2, D1
	* DIV[U,S] stores the remainder in the 2 most significant bytes
	* therfore, the result must be shifted right by 16 bits.
	* since, LS[L,R] only allow shifts from 1 and 8 places two 8-bit shift
	* operations are performed
	LSR.L #8, D1
	LSR.L #8, D1
	* since we have calculated the indexes of DICT_IN and DICT_OUT
	* the indexed addressing mode is used
	MOVEA.L D0, A0
	MOVEA.L D1, A1
	MOVE.B DICT_IN(A0), DICT_OUT(A1)
	DBRA D0, DROT_LP

	* Variable list for clarity:
	*	NCHANGES: number of changes
	*	D0: text rotate loop counter
	*	D1: tmp char from TEXT_IN
	*	D2: text rotate check loop counter
	*	A0: TEXT_[IN,OUT] index
	*	A1: DICT_[IN,OUT] index
	*	D3: tmp char from DICT_IN (used to compare with D1)
	CLR.W NCHANGES
	MOVE.W #TEXT_SIZE-1, D0
TROT_LP:
	MOVEA.L D0, A0
	* load current character from TEXT_IN
	MOVE.B TEXT_IN(A0), D1
	MOVE.L #DICT_SIZE-1, D2
TROT_CHK_LP: 
	MOVEA.L D2, A1
	MOVE.B DICT_IN(A1), D3
	* if the current character is equal to one from DICT_IN,
	* change it for its corresponding character from DICT_OUT
	CMP.W D1, D3
	BNE TROT_CHK_NE
	MOVE.B DICT_OUT(A1), D1
	ADDI.W #1, NCHANGES
	* exit loop because there can only be one match
	JMP TROT_CHK_DONE
TROT_CHK_NE:
	DBRA D2, TROT_CHK_LP
TROT_CHK_DONE:
	* move calculated character to TEXT_OUT
	MOVE.B D1, TEXT_OUT(A0)
	DBRA D0, TROT_LP

	TRAP #15

	END START
