;Tabulatorgrîûe:	3
;Kommentare:																;ab Spalte 60

;Assemblerteil von MT_AES.C
;AK	16.3.96
;sb	11.9.96

						EXPORT	_mt_aes
						EXPORT	_crystal
						EXPORT	_appl_yield
						EXPORT	_GemParBlk

						OFFSET												;typedef struct
																				;{
AESPB_contrl:		DS.l	1												;	WORD	*contrl;
AESPB_global:		DS.l	1												;	WORD	*global;
AESPB_intin:		DS.l	1												;	WORD	*intin;
AESPB_intout:		DS.l	1												;	WORD	*intout;
AESPB_addrin:		DS.l	1												;	void	**addrin;
AESPB_addrout:		DS.l	1												;	void	**addrout;
sizeof_AESPB:																;} AESPB;


						OFFSET												;typedef struct
																				;{
APD_contrl:			DS.w	5												;	WORD	contrl[5];
APD_intin:			DS.w	16												;	WORD	intin[16];
APD_intout:			DS.w	16												;	WORD	intout[16];
APD_addrin:			DS.l	16												;	void	*addrin[16];
APD_addrout:		DS.l	16												;	void	*addrout[16];
sizeof_PARMDATA:															;} PARMDATA;

						OFFSET												;typedef struct
																				;{
GPB_contrl:			DS.w	15												;	WORD	contrl[15];
GPB_global:			DS.w	15												;	WORD	global[15];
GPB_intin:			DS.w	16												;	WORD	intin[16];
GPB_intout:			DS.w	16												;	WORD	intout[16];
GPB_addrin:			DS.l	16												;	void	*addrin[16];
GPB_addrout:		DS.l	16												;	void	*addrout[16];
sizeof_GEMPARBLK:															;} GEMPARBLK;

						TEXT

;void _mt_aes( PARMDATA *d, WORD *ctrldata,	WORD *global );
;Vorgaben:
;Register d0-d2/a0-a1 kînnen verÑndert werden
;Eingaben:
;a0.l PARMDATA *d
;a1.l WORD *ctrldata
;4(sp).l WORD *global
;Ausgaben:
;-
_mt_aes:				move.l	a2,-(sp)
						lea		-sizeof_AESPB(sp),sp					;Platz fÅr AESPB
						movea.l	sp,a2
						move.l	a0,(a2)+									;contrl

						move.l	(a1)+,(a0)+								;contrl[0/1]
						move.l	(a1)+,(a0)+								;contrl[2/3]
						clr.w		(a0)+										;contrl[5]
						
						move.l	sizeof_AESPB+8(sp),(a2)+			;global Åbergeben?
						bne.s		aes_intin
						move.l	#_GemParBlk+GPB_global,-4(a2)
aes_intin:			move.l	a0,(a2)+									;WORD	intin[16]
						lea		APD_intout-APD_intin(a0),a0
						move.l	a0,(a2)+									;WORD	intout[16]
						lea		APD_addrin-APD_intout(a0),a0
						move.l	a0,(a2)+									;void	*addrin[16]
						lea		APD_addrout-APD_addrin(a0),a0
						move.l	a0,(a2)+									;void	*addrout[16]

						move.w	#200,d0									;AES
						move.l	sp,d1
						trap		#2

						lea		sizeof_AESPB(sp),sp
						movea.l	(sp)+,a2
						rts


;void	_crystal( AESPB *aespb );
;Vorgaben:
;Register d0-d2/a0-a1 kînnen verÑndert werden
;Eingaben:
;a0.l	AESPB *aespb
;Ausgaben:
;-
_crystal:			move.l	a2,-(sp)
						move.w	#200,d0									;AES
						move.l	a0,d1
						trap		#2
						movea.l	(sp)+,a2
						rts

;void	_appl_yield( void );
;Vorgaben:
;Register d0-d2/a0-a1 kînnen verÑndert werden
;Eingaben:
;-
;Ausgaben:
;-
_appl_yield:		move.l	a2,-(sp)
						move.w	#201,d0									;appl_yield()
						trap		#2
						movea.l	(sp)+,a2
						rts

						BSS

						EVEN
_GemParBlk:			DS.b	sizeof_GEMPARBLK

						END
