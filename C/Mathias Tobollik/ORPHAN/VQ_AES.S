;/*----------------------------------------------------------------*/
;/* vq_aes()                                                       */
;/*                                                                */
;/* testen, ob das AES installiert ist                             */
;/*                                                                */
;/* frei nach W. Behne, A. Kromke                                  */
;/* int c't 3/91, S.242                                            */
;/*----------------------------------------------------------------*/

GLOBL	vq_aes

vq_aes:	move.w	#$c9,d0
		trap #2
		cmpi.w	#$c9,d0		; hat das AES d0 gel”scht ?
		sne		d0
		ext.w	d0
		rts