; 1- MEGA ST
adapt:    dc.w $0102
          dc.l $2740
          dc.l $e4f
          dc.l $c76
          dc.l $26e6
          dc.l $27a8
          dc.l $e22
          dc.l $e8a
; 2- 520/1040 V 1.0
          dc.w $0100
          dc.l $26e0            ;adresses souris
          dc.l $e09             ;adresse joystick
          dc.l $db0             ;buffer clavier
          dc.l $2686            ;table VDI 1
          dc.l $2748            ;table VDI 2
          dc.l $ddc             ;vecteur inter souris
          dc.l $e44             ;depart d'un son
; 3- 520/1040 V 1.1
          dc.w $0101
          dc.l $26e0            ;adresses souris
          dc.l $e09             ;adresse joystick
          dc.l $db0             ;buffer clavier
          dc.l $2686            ;table VDI 1
          dc.l $2748            ;table VDI 2
          dc.l $ddc             ;vecteur inter souris
          dc.l $e44             ;depart d'un son
; 4- ROMS 1.4
	dc.w $0104
          dc.l $2882            ;adresses souris
          dc.l $e6b             ;adresse joystick
          dc.l $c92             ;buffer clavier
          dc.l $2828            ;table VDI 1
          dc.l $28ea            ;table VDI 2
          dc.l $e3e             ;vecteur inter souris
          dc.l $ea6             ;depart d'un son
; 5- ROMS 1.6
	dc.w $0106
          dc.l $28c2            ;adresses souris
          dc.l $eab             ;adresse joystick
          dc.l $cd2             ;buffer clavier
          dc.l $2868            ;table VDI 1
          dc.l $292a            ;table VDI 2
          dc.l $e7e             ;vecteur inter souris
          dc.l $ee6             ;depart d'un son
; 6- Vide
          dc.w $ffff
          dc.l 0,0,0,0,0,0,0
; 7- Vide
	dc.w $ffff
	dc.l 0,0,0,0,0,0,0
NbAdapt:	equ 7
