	ORG $1000

N	EQU 100
SUM	DS.L 1

START:
	CLR SUM
	CLR D1
	MOVE.W #N+1, D0
LOOP:
	ADD.W #-1, D0
	ADD.L D0, D1
	CMP #0, D0
	BGT LOOP
	MOVE.W D1, SUM
	
	SIMHALT

	END START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
