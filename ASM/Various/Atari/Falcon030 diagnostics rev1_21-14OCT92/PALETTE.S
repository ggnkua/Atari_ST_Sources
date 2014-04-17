*****************************  palette.s  *******************************
*
* $Revision: 3.0 $      $Source: /u/lozben/projects/vdi/mtaskvdi/RCS/palette.s,v $
* =======================================================================
* $Author: lozben $     $Date: 91/01/03 15:14:02 $     $Locker:  $
* =======================================================================
*************************************************************************

        .globl _colors
*+
* pallette.s:
*
* This is the new color initialization table for the TT. The TT LUT hardware
* registers should be initialized to these at power up. 
*
* Registers   0 - 15 should should be initialized to the original ST colors.
* Registers  16 - 31 are initialized to 16 shades of gray. Register 16 being
*                    white (lightest) and 31 being black (darkest).
* Registers 32 - 253 are a color sweep of the HSV (hue, saturtion, value) color
*                    model. We keep saturation at 100% and just load the hues
*                    of the current level (value). We load 90 hues from level
*                    15, 66 hues from level 11, 42 hues from level 7, and 24
*                    hues from level 4, for a total of 222 hues.
* Register 254 - 255 are loaded with white and black respectively.
*-
        .data

_colors:
*--- 16 original ST settings
        dc.w    $fff                    ; 0 white
        dc.w    $f00                    ; 1 red
        dc.w    $0f0                    ; 2 green
        dc.w    $ff0                    ; 3 yellow
        dc.w    $00f                    ; 4 blue
        dc.w    $f0f                    ; 5 magenta
        dc.w    $0ff                    ; 6 cyan
        dc.w    $aaa                    ; 7 "low white"
        dc.w    $666                    ; 8 grey
        dc.w    $f99                    ; 9 light red
        dc.w    $9f9                    ; 10 light green
        dc.w    $ff9                    ; 11 light yellow
        dc.w    $99f                    ; 12 light blue
        dc.w    $f9f                    ; 13 light magenta
        dc.w    $9ff                    ; 14 light cyan
        dc.w    $000                    ; 15 black

*--- 16 shades of gray
        dc.w    $fff                    ; white
        dc.w    $eee
        dc.w    $ddd
        dc.w    $ccc
        dc.w    $bbb
        dc.w    $aaa
        dc.w    $999
        dc.w    $888
        dc.w    $777
        dc.w    $666
        dc.w    $555
        dc.w    $444
        dc.w    $333
        dc.w    $222
        dc.w    $111
        dc.w    $000                    ; black

*+
* HSV level 15 (90 hues)
*-
        dc.w    $f00                    ; red
        dc.w    $f01
        dc.w    $f02
        dc.w    $f03
        dc.w    $f04
        dc.w    $f05
        dc.w    $f06
        dc.w    $f07
        dc.w    $f08
        dc.w    $f09
        dc.w    $f0a
        dc.w    $f0b
        dc.w    $f0c
        dc.w    $f0d
        dc.w    $f0e

        dc.w    $f0f                    ; magenta
        dc.w    $e0f
        dc.w    $d0f
        dc.w    $c0f
        dc.w    $b0f
        dc.w    $a0f
        dc.w    $90f
        dc.w    $80f
        dc.w    $70f
        dc.w    $60f
        dc.w    $50f
        dc.w    $40f
        dc.w    $30f
        dc.w    $20f
        dc.w    $10f

        dc.w    $00f                    ; blue
        dc.w    $01f
        dc.w    $02f
        dc.w    $03f
        dc.w    $04f
        dc.w    $05f
        dc.w    $06f
        dc.w    $07f
        dc.w    $08f
        dc.w    $09f
        dc.w    $0af
        dc.w    $0bf
        dc.w    $0cf
        dc.w    $0df
        dc.w    $0ef

        dc.w    $0ff                    ; cyan
        dc.w    $0fe
        dc.w    $0fd
        dc.w    $0fc
        dc.w    $0fb
        dc.w    $0fa
        dc.w    $0f9
        dc.w    $0f8
        dc.w    $0f7
        dc.w    $0f6
        dc.w    $0f5
        dc.w    $0f4
        dc.w    $0f3
        dc.w    $0f2
        dc.w    $0f1

        dc.w    $0f0                    ; green
        dc.w    $1f0
        dc.w    $2f0
        dc.w    $3f0
        dc.w    $4f0
        dc.w    $5f0
        dc.w    $6f0
        dc.w    $7f0
        dc.w    $8f0
        dc.w    $9f0
        dc.w    $af0
        dc.w    $bf0
        dc.w    $cf0
        dc.w    $df0
        dc.w    $ef0

        dc.w    $ff0                    ; yellow
        dc.w    $fe0
        dc.w    $fd0
        dc.w    $fc0
        dc.w    $fb0
        dc.w    $fa0
        dc.w    $f90
        dc.w    $f80
        dc.w    $f70
        dc.w    $f60
        dc.w    $f50
        dc.w    $f40
        dc.w    $f30
        dc.w    $f20
        dc.w    $f10

*+
* HSV level 11 (66 hues)
*-
        dc.w    $b00                    ; red
        dc.w    $b01
        dc.w    $b02
        dc.w    $b03
        dc.w    $b04
        dc.w    $b05
        dc.w    $b06
        dc.w    $b07
        dc.w    $b08
        dc.w    $b09
        dc.w    $b0a

        dc.w    $b0b                    ; magenta
        dc.w    $a0b
        dc.w    $90b
        dc.w    $80b
        dc.w    $70b
        dc.w    $60b
        dc.w    $50b
        dc.w    $40b
        dc.w    $30b
        dc.w    $20b
        dc.w    $10b

        dc.w    $00b                    ; blue
        dc.w    $01b
        dc.w    $02b
        dc.w    $03b
        dc.w    $04b
        dc.w    $05b
        dc.w    $06b
        dc.w    $07b
        dc.w    $08b
        dc.w    $09b
        dc.w    $0ab

        dc.w    $0bb                    ; cyan
        dc.w    $0ba
        dc.w    $0b9
        dc.w    $0b8
        dc.w    $0b7
        dc.w    $0b6
        dc.w    $0b5
        dc.w    $0b4
        dc.w    $0b3
        dc.w    $0b2
        dc.w    $0b1

        dc.w    $0b0                    ; green
        dc.w    $1b0
        dc.w    $2b0
        dc.w    $3b0
        dc.w    $4b0
        dc.w    $5b0
        dc.w    $6b0
        dc.w    $7b0
        dc.w    $8b0
        dc.w    $9b0
        dc.w    $ab0

        dc.w    $bb0                    ; yellow
        dc.w    $ba0
        dc.w    $b90
        dc.w    $b80
        dc.w    $b70
        dc.w    $b60
        dc.w    $b50
        dc.w    $b40
        dc.w    $b30
        dc.w    $b20
        dc.w    $b10

*+
* HSV level 7 (42 hues)
*-
        dc.w    $700                    ; red
        dc.w    $701
        dc.w    $702
        dc.w    $703
        dc.w    $704
        dc.w    $705
        dc.w    $706

        dc.w    $707                    ; magenta
        dc.w    $607
        dc.w    $507
        dc.w    $407
        dc.w    $307
        dc.w    $207
        dc.w    $107

        dc.w    $007                    ; blue
        dc.w    $017
        dc.w    $027
        dc.w    $037
        dc.w    $047
        dc.w    $057
        dc.w    $067

        dc.w    $077                    ; cyan
        dc.w    $076
        dc.w    $075
        dc.w    $074
        dc.w    $073
        dc.w    $072
        dc.w    $071

        dc.w    $070                    ; green
        dc.w    $170
        dc.w    $270
        dc.w    $370
        dc.w    $470
        dc.w    $570
        dc.w    $670

        dc.w    $770                    ; yellow
        dc.w    $760
        dc.w    $750
        dc.w    $740
        dc.w    $730
        dc.w    $720
        dc.w    $710

*+
* HSV level 4 (24 hues)
*-
        dc.w    $400                    ; red
        dc.w    $401
        dc.w    $402
        dc.w    $403

        dc.w    $404                    ; magenta
        dc.w    $304
        dc.w    $204
        dc.w    $104

        dc.w    $004                    ; blue
        dc.w    $014
        dc.w    $024
        dc.w    $034

        dc.w    $044                    ; cyan
        dc.w    $043
        dc.w    $042
        dc.w    $041

        dc.w    $040                    ; green
        dc.w    $140
        dc.w    $240
        dc.w    $340

        dc.w    $440                    ; yellow
        dc.w    $430

	dc.w	$004d	
	dc.w	$4b42

*+
* Registers 254, 255
*-
        dc.w    $fff                    ; white
        dc.w    $000                    ; black


             
