		EXPORT	wind_get
		IMPORT	aes, intin

;ACHTUNG, Prototyp: int wind_get(int handle, int field, ...);
wind_get:	lea	intin,A0
		move.w	D1,-(A7)	;sichere field
		move.w	D0,(A0)+	;handle
		move.w	D1,(A0)+	;field
		move.l	#$68020500,D0
		bsr	aes
		move.w	(A7)+,D1	;hole field
		move.l	4(A7),A1
		move.w	(A0)+,(A1)	;gib ersten Parameter zurck
		move.l	#%0001_1000_0111_0000_0000,D2
*			  ^19  ^15  ^11  ^7   ^3
		btst	D1,D2		;Nur einen Parameter?
		bne.b	ret		;Ja =>
		move.l	8(A7),A1
		move.w	(A0)+,(A1)
		move.l	12(A7),A1
		move.w	(A0)+,(A1)
		move.l	16(A7),A1
		move.w	(A0)+,(A1)
ret:		rts		

*  #  | Name	      | Anzahl Parameter (1 -> 1, 4 -> 0)
*-----+---------------+----------------------------------
*  0	-		-
*  1	WF_RESVD	-
*  2	-		-
*  3	-		-
*  4	WF_W[ORK]XYWH	4
*  5	WF_C[URR]XYWH	4
*  6	WF_P[REV]XYWH	4
*  7	WF_F[ULL]XYWH	4
*  8	WF_HSLIDE	1
*  9	WF_VSLIDE	1
* 10	WF_TOP		1
* 11	WF_FIRSTXYWH	4
* 12	WF_NEXTXYWH	4
* 13	WF_RESVD2	-
* 14	-		-
* 15	WF_HSLSIZE	1
* 16	WF_VSLSIZE	1
* 17	WF_SCREEN	4
