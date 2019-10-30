 '
 ' Affichage d'un bloc BITBLT + Masque au format DRAW.
 '
 DEF PROC Put_Block(Fic$,X%,Y%,M%)
   LOCAL Size%L,Buffer%L,L%,H%
   OPEN "I",16,Fic$:Size%L= LOF(16): CLOSE 16
   Buffer%L= MEMORY(Size%L): BLOAD Fic$,Buffer%L
   L%= WPEEK(Buffer%L+2):H%= WPEEK(Buffer%L+4): MOUSEOFF
   IF WPEEK(Buffer%L)>=$80 THEN
     WPOKE Buffer%L, WPEEK(Buffer%L) AND $7F
     BITBLT Buffer%L+Size%L/2 TO X%,Y%,L%,H%,4
     BITBLT Buffer%L TO X%,Y%,L%,H%,7
   ELSE
     BITBLT Buffer%L TO X%,Y%,L%,H%,M%
   ENDIF
   FRE (Buffer%L): MOUSEON
 END_PROC
