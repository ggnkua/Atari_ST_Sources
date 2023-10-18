; Aufbau einer Degas-Elite-Datei:
; Wort 0: Aufl”sung - 2=hoch, 1=mittel, 0=niedrig
;						  - ist das oberste Bit gesetzt, dann sind die Daten
;						    komprimiert. z.B. 0x8002=komprimiert, hohe Aufl”sung
; Wort 1-16: Farbpalette
; Es folgen die Bilddaten.
; Anschliežend:
; 4 W”rter linke Begrenzungen fr die 4 Farbanimationskan„le
; 4 W”rter rechte Begrenzungen fr die 4 Farbanimationskan„le
; 4 W”rter Richtungsflag fr die 4 Farbanimationskan„le
; 4 W”rter Zeitverz”gerung fr die 4 Farbanimationskan„le
; 
; DECOMPRESS PICTURE
; D0.L - Anzahl der Bytes komprimiert
; A0.L - Pointer auf komprimierte Daten
; A1.L - Pointer auf Puffer fr unkomprimierte Daten
; Register D1 und D2 werden berschrieben. Turbo-C sichert diese von selbst.
; von Turbo-C aus:
; void decompress(long count, void *source, void *destbuffer);

decompress: 		subq		#1,d0 				; decrease # of bytes left
						ble		dec_fin				; =0? end of bit image reached
						move.b	(a0)+,d1 			; get next byte
						bpl.s 	bitstring			; >=0: bit string
						cmp.b 	#$80,d1				; dummy value ($80)?
						beq.s 	decompress			; yes: ignore it

runlen:				neg.b 	d1 					; run length: d0.w = counter
						ext		d1
						subq		#1,d0 				; decrease # of bytes left
						move.b	(a0)+,d2 			; d1 = repeated byte
lloop: 				move.b	d2,(a1)+ 			; store byte
						dbf		d1,rlloop
						bra.s 	decompress

bitstring:			and		#$7f,d1				; bit string: d0.w = counter
bsloop: 				subq		#1,d0 				; decrease # of bytes left
						move.b	(a0)+,(a1)+ 		; copy bytes
						dbf		d1,bsloop
						bra.s 	decompress
dec_fin:				rts
