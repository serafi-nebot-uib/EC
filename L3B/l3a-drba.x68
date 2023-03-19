	ORG $1000

N	EQU 100
SUM	DS.L 1

START:
	MOVE.L #N, D0
	CLR.L SUM
LOOP:
	ADD.L D0, SUM
	DBRA D0, LOOP

	SIMHALT

	END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
