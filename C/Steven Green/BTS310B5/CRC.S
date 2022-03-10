/*	CRC-32 Routinen (c) St.Slabihoud 1992,1993	*/

#ifdef __PUREC__

	EXPORT Z_32UpdateCRC,Z_UpdateCRC,xcrc
	IMPORT cr3tab,crctab

	PRINT " Fast-CRC Routinen eingebunden! "

/* Z_32UpdateCRC (c,crc) */
/* A1 Tabelle						 */
/* D0 Byte							 */
/* D1 CRC								 */

Z_32UpdateCRC:
			lea			cr3tab,a1
			moveq		#0,d2
			move.b  d0,d2					/* Byte-Wert					*/
      eor.b   d1,d2 				/* XOR mit alter CRC	*/
			add.w		d2,d2
			add.w		d2,d2
			lsr.l		#8,d1
      move.l  0(a1,d2.w),d0
      eor.l   d1,d0
			rts

/* Z_UpdateCRC (c,crc)	 */
/* A1 Tabelle						 */
/* D0 Byte							 */
/* D1 CRC								 */

Z_UpdateCRC:
			lea			crctab,a1
			move.w	d1,d2
			lsr.w		#8,d2
			eor.b		d0,d2
			add.w		d2,d2
			lsl.w		#8,d1
      move.w  0(a1,d2.w),d0
      eor.w   d1,d0
			rts

/* xcrc(crc,c)	 				 */
/* A1 Tabelle						 */
/* D0 CRC								 */
/* D1 Byte							 */

xcrc:
			lea			crctab,a1
			move.w	d0,d2
			lsr.w		#8,d2
			eor.b		d1,d2
			add.w		d2,d2
			lsl.w		#8,d0
      move.w  0(a1,d2.w),d1
      eor.w   d1,d0
			rts
#endif