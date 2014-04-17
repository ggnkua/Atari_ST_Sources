*****************************  palette.s  *******************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/palette.s,v $
* =======================================================================
* $Author: lozben $	$Date: 91/01/03 15:14:02 $     $Locker:  $
* =======================================================================
*
* $Log:	palette.s,v $
* Revision 3.0  91/01/03  15:14:02  lozben
* New generation VDI
* 
* Revision 2.5  90/06/22  18:15:57  lozben
* In the first 16 entrees we changed some of the old values of "6's"
* to new values of "9's", This helps for the human eyes to notice the
* different intenciies in some of the pens.
* 
* Revision 2.4  89/08/15  13:11:26  lozben
* Changed some of the inittial color settings. Doubled some values
* since the range has doubled (4 bits per gun now).
* 
* Revision 2.3  89/07/28  15:03:57  lozben
* Deleted old and unused data.
* 
* Revision 2.2  89/03/01  16:55:59  lozben
* *** Initial Revision ***
* 
*************************************************************************

*+
* pallette.s:
*
* This is the new color initialization table. The LUT hardware registers
* should be initialized to these at power up. 
*
* Registers   0 - 15 standard settings
* Registers  16 - 31 are initialized to 16 shades of gray. Register 16 being
*                    white (lightest) and 31 being black (darkest).
* Registers 32 - 253 are a color sweep of the HSV (hue, saturtion, value) color
*                    model. We keep saturation at 100% and just load the hues
*                    of the current level (value). We load 90 hues from level
*                    15, 66 hues from level 11, 42 hues from level 7, and 24
*                    hues from level 4, for a total of 222 hues.
* Register 254 - 255 are loaded with white and black respectively.
*-
		.globl	_colors
	.text

_colors:
*--- 16 standard colors
	dc.l	$ffffff			; 0 white
	dc.l	$ff0000			; 1 red
	dc.l	$00ff00			; 2 green
	dc.l	$ffff00			; 3 yellow
	dc.l	$0000ff			; 4 blue
	dc.l	$ff00ff			; 5 magenta
	dc.l	$00ffff			; 6 cyan
	dc.l	$bbbbbb			; 7 "low white"
	dc.l	$888888			; 8 grey
	dc.l	$aa0000			; 9 dark red
	dc.l	$00aa00			; 10 dark green
	dc.l	$aaaa00			; 11 dark yellow
	dc.l	$0000aa			; 12 dark blue
	dc.l	$aa00aa			; 13 dark magenta
	dc.l	$00aaaa			; 14 dark cyan
	dc.l	$000000			; 15 black

*--- 16 shades off gray
	dc.l	$ffffff			; white
	dc.l	$eeeeee
	dc.l	$dddddd
	dc.l	$cccccc
	dc.l	$bbbbbb
	dc.l	$aaaaaa
	dc.l	$999999
	dc.l	$888888
	dc.l	$777777
	dc.l	$666666
	dc.l	$555555
	dc.l	$444444
	dc.l	$333333
	dc.l	$222222
	dc.l	$111111
	dc.l	$000000			; black

*+
* HSV level 15 (90 hues)
*-
	dc.l	$ff0000			; red
	dc.l	$ff0011
	dc.l	$ff0022
	dc.l	$ff0033
	dc.l	$ff0044
	dc.l	$ff0055
	dc.l	$ff0066
	dc.l	$ff0077
	dc.l	$ff0088
	dc.l	$ff0099
	dc.l	$ff00aa
	dc.l	$ff00bb
	dc.l	$ff00cc
	dc.l	$ff00dd
	dc.l	$ff00ee

	dc.l	$ff00ff			; magenta
	dc.l	$ee00ff
	dc.l	$dd00ff
	dc.l	$cc00ff
	dc.l	$bb00ff
	dc.l	$aa00ff
	dc.l	$9900ff
	dc.l	$8800ff
	dc.l	$7700ff
	dc.l	$6600ff
	dc.l	$5500ff
	dc.l	$4400ff
	dc.l	$3300ff
	dc.l	$2200ff
	dc.l	$1100ff

	dc.l	$0000ff			; blue
	dc.l	$0011ff
	dc.l	$0022ff
	dc.l	$0033ff
	dc.l	$0044ff
	dc.l	$0055ff
	dc.l	$0066ff
	dc.l	$0077ff
	dc.l	$0088ff
	dc.l	$0099ff
	dc.l	$00aaff
	dc.l	$00bbff
	dc.l	$00ccff
	dc.l	$00ddff
	dc.l	$00eeff

	dc.l	$00ffff			; cyan
	dc.l	$00ffee
	dc.l	$00ffdd
	dc.l	$00ffcc
	dc.l	$00ffbb
	dc.l	$00ffaa
	dc.l	$00ff99
	dc.l	$00ff88
	dc.l	$00ff77
	dc.l	$00ff66
	dc.l	$00ff55
	dc.l	$00ff44
	dc.l	$00ff33
	dc.l	$00ff22
	dc.l	$00ff11

	dc.l	$00ff00			; green
	dc.l	$11ff00
	dc.l	$22ff00
	dc.l	$33ff00
	dc.l	$44ff00
	dc.l	$55ff00
	dc.l	$66ff00
	dc.l	$77ff00
	dc.l	$88ff00
	dc.l	$99ff00
	dc.l	$aaff00
	dc.l	$bbff00
	dc.l	$ccff00
	dc.l	$ddff00
	dc.l	$eeff00

	dc.l	$ffff00			; yellow
	dc.l	$ffee00
	dc.l	$ffdd00
	dc.l	$ffcc00
	dc.l	$ffbb00
	dc.l	$ffaa00
	dc.l	$ff9900
	dc.l	$ff8800
	dc.l	$ff7700
	dc.l	$ff6600
	dc.l	$ff5500
	dc.l	$ff4400
	dc.l	$ff3300
	dc.l	$ff2200
	dc.l	$ff1100

*+
* HSV level 11 (66 hues)
*-
	dc.l	$bb0000			; red
	dc.l	$bb0011
	dc.l	$bb0022
	dc.l	$bb0033
	dc.l	$bb0044
	dc.l	$bb0055
	dc.l	$bb0066
	dc.l	$bb0077
	dc.l	$bb0088
	dc.l	$bb0099
	dc.l	$bb00aa

	dc.l	$bb00bb			; magenta
	dc.l	$aa00bb
	dc.l	$9900bb
	dc.l	$8800bb
	dc.l	$7700bb
	dc.l	$6600bb
	dc.l	$5500bb
	dc.l	$4400bb
	dc.l	$3300bb
	dc.l	$2200bb
	dc.l	$1100bb

	dc.l	$0000bb			; blue
	dc.l	$0011bb
	dc.l	$0022bb
	dc.l	$0033bb
	dc.l	$0044bb
	dc.l	$0055bb
	dc.l	$0066bb
	dc.l	$0077bb
	dc.l	$0088bb
	dc.l	$0099bb
	dc.l	$00aabb

	dc.l	$00bbbb			; cyan
	dc.l	$00bbaa
	dc.l	$00bb99
	dc.l	$00bb88
	dc.l	$00bb77
	dc.l	$00bb66
	dc.l	$00bb55
	dc.l	$00bb44
	dc.l	$00bb33
	dc.l	$00bb22
	dc.l	$00bb11

	dc.l	$00bb00			; green
	dc.l	$11bb00
	dc.l	$22bb00
	dc.l	$33bb00
	dc.l	$44bb00
	dc.l	$55bb00
	dc.l	$66bb00
	dc.l	$77bb00
	dc.l	$88bb00
	dc.l	$99bb00
	dc.l	$aabb00

	dc.l	$bbbb00			; yellow
	dc.l	$bbaa00
	dc.l	$bb9900
	dc.l	$bb8800
	dc.l	$bb7700
	dc.l	$bb6600
	dc.l	$bb5500
	dc.l	$bb4400
	dc.l	$bb3300
	dc.l	$bb2200
	dc.l	$bb1100

*+
* HSV level 7 (42 hues)
*-
	dc.l	$770000			; red
	dc.l	$770011
	dc.l	$770022
	dc.l	$770033
	dc.l	$770044
	dc.l	$770055
	dc.l	$770066

	dc.l	$770077			; magenta
	dc.l	$660077
	dc.l	$550077
	dc.l	$440077
	dc.l	$330077
	dc.l	$220077
	dc.l	$110077

	dc.l	$000077			; blue
	dc.l	$001177
	dc.l	$002277
	dc.l	$003377
	dc.l	$004477
	dc.l	$005577
	dc.l	$006677

	dc.l	$007777			; cyan
	dc.l	$007766
	dc.l	$007755
	dc.l	$007744
	dc.l	$007733
	dc.l	$007722
	dc.l	$007711

	dc.l	$007700			; green
	dc.l	$117700
	dc.l	$227700
	dc.l	$337700
	dc.l	$447700
	dc.l	$557700
	dc.l	$667700

	dc.l	$777700			; yellow
	dc.l	$776600
	dc.l	$775500
	dc.l	$774400
	dc.l	$773300
	dc.l	$772200
	dc.l	$771100

*+
* HSV level 4 (24 hues)
*-
	dc.l	$440000			; red
	dc.l	$440011
	dc.l	$440022
	dc.l	$440033

	dc.l	$440044			; magenta
	dc.l	$330044
	dc.l	$220044
	dc.l	$110044

	dc.l	$000044			; blue
	dc.l	$001144
	dc.l	$002244
	dc.l	$003344

	dc.l	$004444			; cyan
	dc.l	$004433
	dc.l	$004422
	dc.l	$004411

	dc.l	$004400			; green
	dc.l	$114400
	dc.l	$224400
	dc.l	$334400

	dc.l	$444400			; yellow
	dc.l	$443300
	dc.l	$442200
	dc.l	$441100

*+
* Registers 254, 255
*-
	dc.l	$ffffff			; white
	dc.l    $000000			; black

	.end
