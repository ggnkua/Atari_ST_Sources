		EXPORT	my_vst_arbpt32
		EXPORT	my_vqt_pairkern
		
********************************
* eigenes vqt_pairkern-Binding *
********************************

my_vqt_pairkern:
		move.w	#$eb,opcode		* Funktionsnummer -> contrl[0]
		clr.w	sintin			* contrl[1]=0
		move.w	#2,saddrin		* contrl[3]=2
		move.w	d0,contrl+12	* contrl[6]=Device handle
		move.w	d1,intin		* intin[0]=ch1
		move.w	d2,intin+2		* intin[1]=ch2
		
		movem.l	a0-a1,-(a7)
		bsr		vdi				* VDI-Aufruf
		movem.l	(a7)+,a0-a1
		
		move.l	intout,(a0)		* x
		move.l	intout+4,(a1)	* y

		rts		

********************************
* eigenes vst_arbpt32-Binding  *
********************************

my_vst_arbpt32:
		move.w	#$f6,opcode		* Funktionsnummer -> contrl[0]
		clr.w	sintin			* contrl[1]=0
		move.w	#2,saddrin		* contrl[3]=2
		move.w	d0,contrl+12	* contrl[6]=Device handle
		move.l	d1,intin		* intin[0]=fractional cell height
		
		movem.l	a0-a1,-(a7)
		bsr		vdi				* VDI-Aufruf
		movem.l	(a7)+,a0-a1
		
		move.l	intout,d0		* set_point
		
		move.l	a2,-(a7)
		move.l	12(a7),a2
		move.w	ptsout+4,(a2)	* cell_w kommt Åber den Stack
		move.l	8(a7),a2
		move.w	ptsout+6,(a2)	* cell_h kommt Åber den Stack
		move.l	(a7)+,a2

		move.w	ptsout+2,(a1)
		move.w	ptsout,(a0)

		rts		
		
		
**************************
* allgemeiner VDI-Aufruf *
**************************
vdi:      move.l    #vdipb,d1
          moveq     #$73,d0             * Code fÅr VDI
          trap      #2
          rts

          data

vdipb:    dc.l      contrl,intin,ptsin,intout,ptsout

          bss

oldvec:   ds.l      1

contrl:
opcode:   ds.w      1
sintin:   ds.w      1
sintout:  ds.w      1
saddrin:  ds.w      1
saddrout: ds.w      1
          ds.w      6

intin:    ds.w      128
ptsin:    ds.w      256
intout:   ds.w      128
ptsout:   ds.w      128
addrin:   ds.l      128
addrout:  ds.l      128

*********************
* Ende von speedo.s *
*********************
