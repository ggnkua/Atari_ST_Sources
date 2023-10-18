
===================
 PICTURE NEOchrome
===================

 $0000-$0003	:	leer
 $0004-$0023	:	Farbregister
 $0030		:	immer $80 (Belegung unbekannt)
 $0031		:	xy   x = 
 				- Zweitfarbe.
 				- Linkes Ende der Palettenrotation
 			     y = 
 				- Rechtes Ende der Palettenrotation
 $0032		:	$00 = keine VBL-Rotation
 			$80 = VBL-Rotation
 $0033		:	Rotationsgeschwindigkeit
 			Negativ: Von rechts nach links
 			Positiv: Von links nach rechts
 $0034-$007F	:	Belegung unbekannt
 $0080-$7D80	:	Bit-map Bild
 
 
 
================== 
 PICTURE SPeCtrum
==================

 Bemerkung: Ein Spectrumbild hat nur 199 Zeilen!
 
 .SPC ( C = Crunched = Komprimiert )
 - Die Daten sind Komprimiert wie es Degas-Elite macht
 - Bei den Paletten wird nur das Farbreg $00 komprimiert.

 $0000-$0001	:	"SP"
 $0002-$0003	:	null
 $0004-$0007	:	Datenlaenge
 $0008-$000B	:	Palettenlaenge
 $000C-$xxxx	:	Daten
 $xxxy-$yyyy	:	Paletten
 
 .SPU ( U = Uncrunched = Entpackt )
 
 $0000-$7CFF	:	Daten
 $8000-$C79F	:	Paletten: Drei Paletten pro Zeile  
 
 