
; 16 (!) bit audio system beachten



		text


; ----------------------------------------------------------
; 17.09.00/vk
; berechnet alle benoetigten lautstaerke-tabellen.
; rettet alle register
calcVolumeTables
		movem.l	d0-a6,-(sp)
		bsr.s	calcMainVolumeTable
		bsr.s	calcSingleVolumeTables
		movem.l	(sp)+,d0-a6
		rts


; ----------------------------------------------------------
; 17.09.00/vk
; berechnet die main-lautstaerke-tabelle, die aus den addierten
; 8 bit-samplewerten (im addierten word-format) den letztlich
; abzuspielenden 16 bit-samplewert (low/high) erstellt.
; es werden keine register gerettet.
calcMainVolumeTable

		lea	mainVolumeTable-2*128*AUDIOSYSSAMPLESPERCHANNEL,a0

		move.w	#-128*AUDIOSYSSAMPLESPERCHANNEL,d1
		moveq	#256/AUDIOSYSSAMPLESPERCHANNEL,d2
		move.w	#256*AUDIOSYSSAMPLESPERCHANNEL-1,d0
cmvtLoop
		move.w	d1,d3
		muls.w	d2,d3
		rol.w	#8,d3
		move.w	d3,(a0)+

		addq.w	#1,d1

		dbra	d0,cmvtLoop

		rts


; ----------------------------------------------------------
; 17.09.00/vk
; berechnet die einzelnen lautstaerke-tabellen fuer die
; verschiedenen lautstaerke-indizes, die ein sample
; besitzen kann (insgesamt 17 Tabellen)
calcSingleVolumeTables

		lea	volumeTables,a0
		moveq	#16,d0
csvtLoop	move.w	d0,d1
		movea.l	(a0)+,a1
		bsr.s	calcCurrentVolumeTable

		dbra	d0,csvtLoop

		rts


; ----------------------------------------------------------
; 17.09.00/vk
; berechnet die aktuelle lautstaerken-tabelle.
; aufbau der tabelle:   0.w = wert fuer 0
;                     127.w = wert fuer 127
;                     128.w = wert fuer -1
;                     255.w = wert fuer -128
; d1 = staerkeindex (0..16)
; a1 = pointer auf tabelle
; rettet alle register.
calcCurrentVolumeTable

		movem.l	d5-d7/a1,-(sp)

		moveq	#0,d6
		move.w	#255,d7
ccvtLoop	move.w	d6,d5
		ext.w	d5
		muls.w	d1,d5
		asr.w	#4,d5
		move.w	d5,(a1)+
		addq.w	#1,d6
		dbra	d7,ccvtLoop		

		movem.l	(sp)+,d5-d7/a1

		rts




		data


; lautstaerketabellen fuer die indizes 0..16 (insgesamt 17 tabellen a 256 words)
volumeTables	dc.l	vt00
		dc.l	vt01
		dc.l	vt02
		dc.l	vt03
		dc.l	vt04
		dc.l	vt05
		dc.l	vt06
		dc.l	vt07
		dc.l	vt08
		dc.l	vt09
		dc.l	vt10
		dc.l	vt11
		dc.l	vt12
		dc.l	vt13
		dc.l	vt14
		dc.l	vt15
		dc.l	vt16



		bss


; mainvolumetable, benoetigt zum zusammenmischen der samples
		ds.w	128*AUDIOSYSSAMPLESPERCHANNEL
mainVolumeTable	ds.w	128*AUDIOSYSSAMPLESPERCHANNEL


; einzelne volumetables
vt00		ds.w	256
vt01		ds.w	256
vt02		ds.w	256
vt03		ds.w	256
vt04		ds.w	256
vt05		ds.w	256
vt06		ds.w	256
vt07		ds.w	256
vt08		ds.w	256
vt09		ds.w	256
vt10		ds.w	256
vt11		ds.w	256
vt12		ds.w	256
vt13		ds.w	256
vt14		ds.w	256
vt15		ds.w	256
vt16		ds.w	256

