
;***************************************************************************
;
;   XGRAPHIX.S
;
;   - Atari XE graphics routines
;
;   02/27/89 created
;
;   09/09/93 11:00
;
;**************************************************************************/

    .include "atari.sh"
    .include "x6502.sh"

    .data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Lookup Tables
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; given an 8 bit number, return a 16 bit number with double width bits

Lmp8to16:
  dc.w $0000, $0003, $000C, $000F, $0030, $0033, $003C, $003F ; $00
  dc.w $00C0, $00C3, $00CC, $00CF, $00F0, $00F3, $00FC, $00FF ; $08
  dc.w $0300, $0303, $030C, $030F, $0330, $0333, $033C, $033F ; $10
  dc.w $03C0, $03C3, $03CC, $03CF, $03F0, $03F3, $03FC, $03FF ; $18
  dc.w $0C00, $0C03, $0C0C, $0C0F, $0C30, $0C33, $0C3C, $0C3F ; $20
  dc.w $0CC0, $0CC3, $0CCC, $0CCF, $0CF0, $0CF3, $0CFC, $0CFF ; $28
  dc.w $0F00, $0F03, $0F0C, $0F0F, $0F30, $0F33, $0F3C, $0F3F ; $30
  dc.w $0FC0, $0FC3, $0FCC, $0FCF, $0FF0, $0FF3, $0FFC, $0FFF ; $38
  dc.w $3000, $3003, $300C, $300F, $3030, $3033, $303C, $303F ; $40
  dc.w $30C0, $30C3, $30CC, $30CF, $30F0, $30F3, $30FC, $30FF ; $48
  dc.w $3300, $3303, $330C, $330F, $3330, $3333, $333C, $333F ; $50
  dc.w $33C0, $33C3, $33CC, $33CF, $33F0, $33F3, $33FC, $33FF ; $58
  dc.w $3C00, $3C03, $3C0C, $3C0F, $3C30, $3C33, $3C3C, $3C3F ; $60
  dc.w $3CC0, $3CC3, $3CCC, $3CCF, $3CF0, $3CF3, $3CFC, $3CFF ; $68
  dc.w $3F00, $3F03, $3F0C, $3F0F, $3F30, $3F33, $3F3C, $3F3F ; $70
  dc.w $3FC0, $3FC3, $3FCC, $3FCF, $3FF0, $3FF3, $3FFC, $3FFF ; $78
  dc.w $C000, $C003, $C00C, $C00F, $C030, $C033, $C03C, $C03F ; $80
  dc.w $C0C0, $C0C3, $C0CC, $C0CF, $C0F0, $C0F3, $C0FC, $C0FF ; $88
  dc.w $C300, $C303, $C30C, $C30F, $C330, $C333, $C33C, $C33F ; $90
  dc.w $C3C0, $C3C3, $C3CC, $C3CF, $C3F0, $C3F3, $C3FC, $C3FF ; $98
  dc.w $CC00, $CC03, $CC0C, $CC0F, $CC30, $CC33, $CC3C, $CC3F ; $A0
  dc.w $CCC0, $CCC3, $CCCC, $CCCF, $CCF0, $CCF3, $CCFC, $CCFF ; $A8
  dc.w $CF00, $CF03, $CF0C, $CF0F, $CF30, $CF33, $CF3C, $CF3F ; $B0
  dc.w $CFC0, $CFC3, $CFCC, $CFCF, $CFF0, $CFF3, $CFFC, $CFFF ; $B8
  dc.w $F000, $F003, $F00C, $F00F, $F030, $F033, $F03C, $F03F ; $C0
  dc.w $F0C0, $F0C3, $F0CC, $F0CF, $F0F0, $F0F3, $F0FC, $F0FF ; $C8
  dc.w $F300, $F303, $F30C, $F30F, $F330, $F333, $F33C, $F33F ; $D0
  dc.w $F3C0, $F3C3, $F3CC, $F3CF, $F3F0, $F3F3, $F3FC, $F3FF ; $D8
  dc.w $FC00, $FC03, $FC0C, $FC0F, $FC30, $FC33, $FC3C, $FC3F ; $E0
  dc.w $FCC0, $FCC3, $FCCC, $FCCF, $FCF0, $FCF3, $FCFC, $FCFF ; $E8
  dc.w $FF00, $FF03, $FF0C, $FF0F, $FF30, $FF33, $FF3C, $FF3F ; $F0
  dc.w $FFC0, $FFC3, $FFCC, $FFCF, $FFF0, $FFF3, $FFFC, $FFFF ; $F8

; the inverse of the above
; dc.w ~$0000, ~$0003, ~$000C, ~$000F, ~$0030, ~$0033, ~$003C, ~$003F
; dc.w ~$00C0, ~$00C3, ~$00CC, ~$00CF, ~$00F0, ~$00F3, ~$00FC, ~$00FF
; dc.w ~$0300, ~$0303, ~$030C, ~$030F, ~$0330, ~$0333, ~$033C, ~$033F
; dc.w ~$03C0, ~$03C3, ~$03CC, ~$03CF, ~$03F0, ~$03F3, ~$03FC, ~$03FF
; dc.w ~$0C00, ~$0C03, ~$0C0C, ~$0C0F, ~$0C30, ~$0C33, ~$0C3C, ~$0C3F
; dc.w ~$0CC0, ~$0CC3, ~$0CCC, ~$0CCF, ~$0CF0, ~$0CF3, ~$0CFC, ~$0CFF
; dc.w ~$0F00, ~$0F03, ~$0F0C, ~$0F0F, ~$0F30, ~$0F33, ~$0F3C, ~$0F3F
; dc.w ~$0FC0, ~$0FC3, ~$0FCC, ~$0FCF, ~$0FF0, ~$0FF3, ~$0FFC, ~$0FFF
; dc.w ~$3000, ~$3003, ~$300C, ~$300F, ~$3030, ~$3033, ~$303C, ~$303F
; dc.w ~$30C0, ~$30C3, ~$30CC, ~$30CF, ~$30F0, ~$30F3, ~$30FC, ~$30FF
; dc.w ~$3300, ~$3303, ~$330C, ~$330F, ~$3330, ~$3333, ~$333C, ~$333F
; dc.w ~$33C0, ~$33C3, ~$33CC, ~$33CF, ~$33F0, ~$33F3, ~$33FC, ~$33FF
; dc.w ~$3C00, ~$3C03, ~$3C0C, ~$3C0F, ~$3C30, ~$3C33, ~$3C3C, ~$3C3F
; dc.w ~$3CC0, ~$3CC3, ~$3CCC, ~$3CCF, ~$3CF0, ~$3CF3, ~$3CFC, ~$3CFF
; dc.w ~$3F00, ~$3F03, ~$3F0C, ~$3F0F, ~$3F30, ~$3F33, ~$3F3C, ~$3F3F
; dc.w ~$3FC0, ~$3FC3, ~$3FCC, ~$3FCF, ~$3FF0, ~$3FF3, ~$3FFC, ~$3FFF
; dc.w ~$C000, ~$C003, ~$C00C, ~$C00F, ~$C030, ~$C033, ~$C03C, ~$C03F
; dc.w ~$C0C0, ~$C0C3, ~$C0CC, ~$C0CF, ~$C0F0, ~$C0F3, ~$C0FC, ~$C0FF
; dc.w ~$C300, ~$C303, ~$C30C, ~$C30F, ~$C330, ~$C333, ~$C33C, ~$C33F
; dc.w ~$C3C0, ~$C3C3, ~$C3CC, ~$C3CF, ~$C3F0, ~$C3F3, ~$C3FC, ~$C3FF
; dc.w ~$CC00, ~$CC03, ~$CC0C, ~$CC0F, ~$CC30, ~$CC33, ~$CC3C, ~$CC3F
; dc.w ~$CCC0, ~$CCC3, ~$CCCC, ~$CCCF, ~$CCF0, ~$CCF3, ~$CCFC, ~$CCFF
; dc.w ~$CF00, ~$CF03, ~$CF0C, ~$CF0F, ~$CF30, ~$CF33, ~$CF3C, ~$CF3F
; dc.w ~$CFC0, ~$CFC3, ~$CFCC, ~$CFCF, ~$CFF0, ~$CFF3, ~$CFFC, ~$CFFF
; dc.w ~$F000, ~$F003, ~$F00C, ~$F00F, ~$F030, ~$F033, ~$F03C, ~$F03F
; dc.w ~$F0C0, ~$F0C3, ~$F0CC, ~$F0CF, ~$F0F0, ~$F0F3, ~$F0FC, ~$F0FF
; dc.w ~$F300, ~$F303, ~$F30C, ~$F30F, ~$F330, ~$F333, ~$F33C, ~$F33F
; dc.w ~$F3C0, ~$F3C3, ~$F3CC, ~$F3CF, ~$F3F0, ~$F3F3, ~$F3FC, ~$F3FF
; dc.w ~$FC00, ~$FC03, ~$FC0C, ~$FC0F, ~$FC30, ~$FC33, ~$FC3C, ~$FC3F
; dc.w ~$FCC0, ~$FCC3, ~$FCCC, ~$FCCF, ~$FCF0, ~$FCF3, ~$FCFC, ~$FCFF
; dc.w ~$FF00, ~$FF03, ~$FF0C, ~$FF0F, ~$FF30, ~$FF33, ~$FF3C, ~$FF3F
; dc.w ~$FFC0, ~$FFC3, ~$FFCC, ~$FFCF, ~$FFF0, ~$FFF3, ~$FFFC, ~$FFFF


; given an 8 bit number, return a 32 bit number with quad width bits

Lmp8to32:
  dc.w $0000, $0000, $0000, $000F, $0000, $00F0, $0000, $00FF ; $00
  dc.w $0000, $0F00, $0000, $0F0F, $0000, $0FF0, $0000, $0FFF ; $04
  dc.w $0000, $F000, $0000, $F00F, $0000, $F0F0, $0000, $F0FF ; $08
  dc.w $0000, $FF00, $0000, $FF0F, $0000, $FFF0, $0000, $FFFF ; $0C
  dc.w $000F, $0000, $000F, $000F, $000F, $00F0, $000F, $00FF ; $10
  dc.w $000F, $0F00, $000F, $0F0F, $000F, $0FF0, $000F, $0FFF ; $14
  dc.w $000F, $F000, $000F, $F00F, $000F, $F0F0, $000F, $F0FF ; $18
  dc.w $000F, $FF00, $000F, $FF0F, $000F, $FFF0, $000F, $FFFF ; $1C

  dc.w $00F0, $0000, $00F0, $000F, $00F0, $00F0, $00F0, $00FF ; $20
  dc.w $00F0, $0F00, $00F0, $0F0F, $00F0, $0FF0, $00F0, $0FFF ; $24
  dc.w $00F0, $F000, $00F0, $F00F, $00F0, $F0F0, $00F0, $F0FF ; $28
  dc.w $00F0, $FF00, $00F0, $FF0F, $00F0, $FFF0, $00F0, $FFFF ; $2C
  dc.w $00FF, $0000, $00FF, $000F, $00FF, $00F0, $00FF, $00FF ; $30
  dc.w $00FF, $0F00, $00FF, $0F0F, $00FF, $0FF0, $00FF, $0FFF ; $34
  dc.w $00FF, $F000, $00FF, $F00F, $00FF, $F0F0, $00FF, $F0FF ; $38
  dc.w $00FF, $FF00, $00FF, $FF0F, $00FF, $FFF0, $00FF, $FFFF ; $3C

  dc.w $0F00, $0000, $0F00, $000F, $0F00, $00F0, $0F00, $00FF ; $40
  dc.w $0F00, $0F00, $0F00, $0F0F, $0F00, $0FF0, $0F00, $0FFF ; $44
  dc.w $0F00, $F000, $0F00, $F00F, $0F00, $F0F0, $0F00, $F0FF ; $48
  dc.w $0F00, $FF00, $0F00, $FF0F, $0F00, $FFF0, $0F00, $FFFF ; $4C
  dc.w $0F0F, $0000, $0F0F, $000F, $0F0F, $00F0, $0F0F, $00FF ; $50
  dc.w $0F0F, $0F00, $0F0F, $0F0F, $0F0F, $0FF0, $0F0F, $0FFF ; $54
  dc.w $0F0F, $F000, $0F0F, $F00F, $0F0F, $F0F0, $0F0F, $F0FF ; $58
  dc.w $0F0F, $FF00, $0F0F, $FF0F, $0F0F, $FFF0, $0F0F, $FFFF ; $5C

  dc.w $0FF0, $0000, $0FF0, $000F, $0FF0, $00F0, $0FF0, $00FF ; $60
  dc.w $0FF0, $0F00, $0FF0, $0F0F, $0FF0, $0FF0, $0FF0, $0FFF ; $64
  dc.w $0FF0, $F000, $0FF0, $F00F, $0FF0, $F0F0, $0FF0, $F0FF ; $68
  dc.w $0FF0, $FF00, $0FF0, $FF0F, $0FF0, $FFF0, $0FF0, $FFFF ; $6C
  dc.w $0FFF, $0000, $0FFF, $000F, $0FFF, $00F0, $0FFF, $00FF ; $70
  dc.w $0FFF, $0F00, $0FFF, $0F0F, $0FFF, $0FF0, $0FFF, $0FFF ; $74
  dc.w $0FFF, $F000, $0FFF, $F00F, $0FFF, $F0F0, $0FFF, $F0FF ; $78
  dc.w $0FFF, $FF00, $0FFF, $FF0F, $0FFF, $FFF0, $0FFF, $FFFF ; $7C

  dc.w $F000, $0000, $F000, $000F, $F000, $00F0, $F000, $00FF ; $80
  dc.w $F000, $0F00, $F000, $0F0F, $F000, $0FF0, $F000, $0FFF ; $84
  dc.w $F000, $F000, $F000, $F00F, $F000, $F0F0, $F000, $F0FF ; $88
  dc.w $F000, $FF00, $F000, $FF0F, $F000, $FFF0, $F000, $FFFF ; $8C
  dc.w $F00F, $0000, $F00F, $000F, $F00F, $00F0, $F00F, $00FF ; $90
  dc.w $F00F, $0F00, $F00F, $0F0F, $F00F, $0FF0, $F00F, $0FFF ; $94
  dc.w $F00F, $F000, $F00F, $F00F, $F00F, $F0F0, $F00F, $F0FF ; $98
  dc.w $F00F, $FF00, $F00F, $FF0F, $F00F, $FFF0, $F00F, $FFFF ; $9C

  dc.w $F0F0, $0000, $F0F0, $000F, $F0F0, $00F0, $F0F0, $00FF ; $A0
  dc.w $F0F0, $0F00, $F0F0, $0F0F, $F0F0, $0FF0, $F0F0, $0FFF ; $A4
  dc.w $F0F0, $F000, $F0F0, $F00F, $F0F0, $F0F0, $F0F0, $F0FF ; $A8
  dc.w $F0F0, $FF00, $F0F0, $FF0F, $F0F0, $FFF0, $F0F0, $FFFF ; $AC
  dc.w $F0FF, $0000, $F0FF, $000F, $F0FF, $00F0, $F0FF, $00FF ; $B0
  dc.w $F0FF, $0F00, $F0FF, $0F0F, $F0FF, $0FF0, $F0FF, $0FFF ; $B4
  dc.w $F0FF, $F000, $F0FF, $F00F, $F0FF, $F0F0, $F0FF, $F0FF ; $B8
  dc.w $F0FF, $FF00, $F0FF, $FF0F, $F0FF, $FFF0, $F0FF, $FFFF ; $BC

  dc.w $FF00, $0000, $FF00, $000F, $FF00, $00F0, $FF00, $00FF ; $C0
  dc.w $FF00, $0F00, $FF00, $0F0F, $FF00, $0FF0, $FF00, $0FFF ; $C4
  dc.w $FF00, $F000, $FF00, $F00F, $FF00, $F0F0, $FF00, $F0FF ; $C8
  dc.w $FF00, $FF00, $FF00, $FF0F, $FF00, $FFF0, $FF00, $FFFF ; $CC
  dc.w $FF0F, $0000, $FF0F, $000F, $FF0F, $00F0, $FF0F, $00FF ; $D0
  dc.w $FF0F, $0F00, $FF0F, $0F0F, $FF0F, $0FF0, $FF0F, $0FFF ; $D4
  dc.w $FF0F, $F000, $FF0F, $F00F, $FF0F, $F0F0, $FF0F, $F0FF ; $D8
  dc.w $FF0F, $FF00, $FF0F, $FF0F, $FF0F, $FFF0, $FF0F, $FFFF ; $DC

  dc.w $FFF0, $0000, $FFF0, $000F, $FFF0, $00F0, $FFF0, $00FF ; $E0
  dc.w $FFF0, $0F00, $FFF0, $0F0F, $FFF0, $0FF0, $FFF0, $0FFF ; $E4
  dc.w $FFF0, $F000, $FFF0, $F00F, $FFF0, $F0F0, $FFF0, $F0FF ; $E8
  dc.w $FFF0, $FF00, $FFF0, $FF0F, $FFF0, $FFF0, $FFF0, $FFFF ; $EC
  dc.w $FFFF, $0000, $FFFF, $000F, $FFFF, $00F0, $FFFF, $00FF ; $F0
  dc.w $FFFF, $0F00, $FFFF, $0F0F, $FFFF, $0FF0, $FFFF, $0FFF ; $F4
  dc.w $FFFF, $F000, $FFFF, $F00F, $FFFF, $F0F0, $FFFF, $F0FF ; $F8
  dc.w $FFFF, $FF00, $FFFF, $FF0F, $FFFF, $FFF0, $FFFF, $FFFF ; $FC

; the inverse of the above
; dc.w ~$0000, ~$0000, ~$0000, ~$000F, ~$0000, ~$00F0, ~$0000, ~$00FF
; dc.w ~$0000, ~$0F00, ~$0000, ~$0F0F, ~$0000, ~$0FF0, ~$0000, ~$0FFF
; dc.w ~$0000, ~$F000, ~$0000, ~$F00F, ~$0000, ~$F0F0, ~$0000, ~$F0FF
; dc.w ~$0000, ~$FF00, ~$0000, ~$FF0F, ~$0000, ~$FFF0, ~$0000, ~$FFFF
; dc.w ~$000F, ~$0000, ~$000F, ~$000F, ~$000F, ~$00F0, ~$000F, ~$00FF
; dc.w ~$000F, ~$0F00, ~$000F, ~$0F0F, ~$000F, ~$0FF0, ~$000F, ~$0FFF
; dc.w ~$000F, ~$F000, ~$000F, ~$F00F, ~$000F, ~$F0F0, ~$000F, ~$F0FF
; dc.w ~$000F, ~$FF00, ~$000F, ~$FF0F, ~$000F, ~$FFF0, ~$000F, ~$FFFF

; dc.w ~$00F0, ~$0000, ~$00F0, ~$000F, ~$00F0, ~$00F0, ~$00F0, ~$00FF
; dc.w ~$00F0, ~$0F00, ~$00F0, ~$0F0F, ~$00F0, ~$0FF0, ~$00F0, ~$0FFF
; dc.w ~$00F0, ~$F000, ~$00F0, ~$F00F, ~$00F0, ~$F0F0, ~$00F0, ~$F0FF
; dc.w ~$00F0, ~$FF00, ~$00F0, ~$FF0F, ~$00F0, ~$FFF0, ~$00F0, ~$FFFF
; dc.w ~$00FF, ~$0000, ~$00FF, ~$000F, ~$00FF, ~$00F0, ~$00FF, ~$00FF
; dc.w ~$00FF, ~$0F00, ~$00FF, ~$0F0F, ~$00FF, ~$0FF0, ~$00FF, ~$0FFF
; dc.w ~$00FF, ~$F000, ~$00FF, ~$F00F, ~$00FF, ~$F0F0, ~$00FF, ~$F0FF
; dc.w ~$00FF, ~$FF00, ~$00FF, ~$FF0F, ~$00FF, ~$FFF0, ~$00FF, ~$FFFF

; dc.w ~$0F00, ~$0000, ~$0F00, ~$000F, ~$0F00, ~$00F0, ~$0F00, ~$00FF
; dc.w ~$0F00, ~$0F00, ~$0F00, ~$0F0F, ~$0F00, ~$0FF0, ~$0F00, ~$0FFF
; dc.w ~$0F00, ~$F000, ~$0F00, ~$F00F, ~$0F00, ~$F0F0, ~$0F00, ~$F0FF
; dc.w ~$0F00, ~$FF00, ~$0F00, ~$FF0F, ~$0F00, ~$FFF0, ~$0F00, ~$FFFF
; dc.w ~$0F0F, ~$0000, ~$0F0F, ~$000F, ~$0F0F, ~$00F0, ~$0F0F, ~$00FF
; dc.w ~$0F0F, ~$0F00, ~$0F0F, ~$0F0F, ~$0F0F, ~$0FF0, ~$0F0F, ~$0FFF
; dc.w ~$0F0F, ~$F000, ~$0F0F, ~$F00F, ~$0F0F, ~$F0F0, ~$0F0F, ~$F0FF
; dc.w ~$0F0F, ~$FF00, ~$0F0F, ~$FF0F, ~$0F0F, ~$FFF0, ~$0F0F, ~$FFFF

; dc.w ~$0FF0, ~$0000, ~$0FF0, ~$000F, ~$0FF0, ~$00F0, ~$0FF0, ~$00FF
; dc.w ~$0FF0, ~$0F00, ~$0FF0, ~$0F0F, ~$0FF0, ~$0FF0, ~$0FF0, ~$0FFF
; dc.w ~$0FF0, ~$F000, ~$0FF0, ~$F00F, ~$0FF0, ~$F0F0, ~$0FF0, ~$F0FF
; dc.w ~$0FF0, ~$FF00, ~$0FF0, ~$FF0F, ~$0FF0, ~$FFF0, ~$0FF0, ~$FFFF
; dc.w ~$0FFF, ~$0000, ~$0FFF, ~$000F, ~$0FFF, ~$00F0, ~$0FFF, ~$00FF
; dc.w ~$0FFF, ~$0F00, ~$0FFF, ~$0F0F, ~$0FFF, ~$0FF0, ~$0FFF, ~$0FFF
; dc.w ~$0FFF, ~$F000, ~$0FFF, ~$F00F, ~$0FFF, ~$F0F0, ~$0FFF, ~$F0FF
; dc.w ~$0FFF, ~$FF00, ~$0FFF, ~$FF0F, ~$0FFF, ~$FFF0, ~$0FFF, ~$FFFF

; dc.w ~$F000, ~$0000, ~$F000, ~$000F, ~$F000, ~$00F0, ~$F000, ~$00FF
; dc.w ~$F000, ~$0F00, ~$F000, ~$0F0F, ~$F000, ~$0FF0, ~$F000, ~$0FFF
; dc.w ~$F000, ~$F000, ~$F000, ~$F00F, ~$F000, ~$F0F0, ~$F000, ~$F0FF
; dc.w ~$F000, ~$FF00, ~$F000, ~$FF0F, ~$F000, ~$FFF0, ~$F000, ~$FFFF
; dc.w ~$F00F, ~$0000, ~$F00F, ~$000F, ~$F00F, ~$00F0, ~$F00F, ~$00FF
; dc.w ~$F00F, ~$0F00, ~$F00F, ~$0F0F, ~$F00F, ~$0FF0, ~$F00F, ~$0FFF
; dc.w ~$F00F, ~$F000, ~$F00F, ~$F00F, ~$F00F, ~$F0F0, ~$F00F, ~$F0FF
; dc.w ~$F00F, ~$FF00, ~$F00F, ~$FF0F, ~$F00F, ~$FFF0, ~$F00F, ~$FFFF

; dc.w ~$F0F0, ~$0000, ~$F0F0, ~$000F, ~$F0F0, ~$00F0, ~$F0F0, ~$00FF
; dc.w ~$F0F0, ~$0F00, ~$F0F0, ~$0F0F, ~$F0F0, ~$0FF0, ~$F0F0, ~$0FFF
; dc.w ~$F0F0, ~$F000, ~$F0F0, ~$F00F, ~$F0F0, ~$F0F0, ~$F0F0, ~$F0FF
; dc.w ~$F0F0, ~$FF00, ~$F0F0, ~$FF0F, ~$F0F0, ~$FFF0, ~$F0F0, ~$FFFF
; dc.w ~$F0FF, ~$0000, ~$F0FF, ~$000F, ~$F0FF, ~$00F0, ~$F0FF, ~$00FF
; dc.w ~$F0FF, ~$0F00, ~$F0FF, ~$0F0F, ~$F0FF, ~$0FF0, ~$F0FF, ~$0FFF
; dc.w ~$F0FF, ~$F000, ~$F0FF, ~$F00F, ~$F0FF, ~$F0F0, ~$F0FF, ~$F0FF
; dc.w ~$F0FF, ~$FF00, ~$F0FF, ~$FF0F, ~$F0FF, ~$FFF0, ~$F0FF, ~$FFFF

; dc.w ~$FF00, ~$0000, ~$FF00, ~$000F, ~$FF00, ~$00F0, ~$FF00, ~$00FF
; dc.w ~$FF00, ~$0F00, ~$FF00, ~$0F0F, ~$FF00, ~$0FF0, ~$FF00, ~$0FFF
; dc.w ~$FF00, ~$F000, ~$FF00, ~$F00F, ~$FF00, ~$F0F0, ~$FF00, ~$F0FF
; dc.w ~$FF00, ~$FF00, ~$FF00, ~$FF0F, ~$FF00, ~$FFF0, ~$FF00, ~$FFFF
; dc.w ~$FF0F, ~$0000, ~$FF0F, ~$000F, ~$FF0F, ~$00F0, ~$FF0F, ~$00FF
; dc.w ~$FF0F, ~$0F00, ~$FF0F, ~$0F0F, ~$FF0F, ~$0FF0, ~$FF0F, ~$0FFF
; dc.w ~$FF0F, ~$F000, ~$FF0F, ~$F00F, ~$FF0F, ~$F0F0, ~$FF0F, ~$F0FF
; dc.w ~$FF0F, ~$FF00, ~$FF0F, ~$FF0F, ~$FF0F, ~$FFF0, ~$FF0F, ~$FFFF

; dc.w ~$FFF0, ~$0000, ~$FFF0, ~$000F, ~$FFF0, ~$00F0, ~$FFF0, ~$00FF
; dc.w ~$FFF0, ~$0F00, ~$FFF0, ~$0F0F, ~$FFF0, ~$0FF0, ~$FFF0, ~$0FFF
; dc.w ~$FFF0, ~$F000, ~$FFF0, ~$F00F, ~$FFF0, ~$F0F0, ~$FFF0, ~$F0FF
; dc.w ~$FFF0, ~$FF00, ~$FFF0, ~$FF0F, ~$FFF0, ~$FFF0, ~$FFF0, ~$FFFF
; dc.w ~$FFFF, ~$0000, ~$FFFF, ~$000F, ~$FFFF, ~$00F0, ~$FFFF, ~$00FF
; dc.w ~$FFFF, ~$0F00, ~$FFFF, ~$0F0F, ~$FFFF, ~$0FF0, ~$FFFF, ~$0FFF
; dc.w ~$FFFF, ~$F000, ~$FFFF, ~$F00F, ~$FFFF, ~$F0F0, ~$FFFF, ~$F0FF
; dc.w ~$FFFF, ~$FF00, ~$FFFF, ~$FF0F, ~$FFFF, ~$FFF0, ~$FFFF, ~$FFFF

; mapping from one of 128 8-bit colors to equivalent ST colors
rgwRainbow::
    dc.w    $000, $111, $222, $333, $444, $555, $666, $777
    dc.w    $200, $320, $430, $541, $650, $653, $764, $775
    dc.w    $200, $420, $530, $742, $753, $754, $754, $765
    dc.w    $200, $400, $500, $630, $643, $754, $754, $765
    dc.w    $400, $500, $511, $600, $744, $755, $755, $766
    dc.w    $301, $402, $513, $613, $634, $645, $756, $766
    dc.w    $202, $303, $404, $526, $636, $646, $757, $767
    dc.w    $203, $204, $325, $426, $446, $557, $667, $667
    dc.w    $003, $004, $115, $226, $346, $457, $567, $667
    dc.w    $003, $004, $115, $236, $346, $457, $567, $667
    dc.w    $012, $023, $234, $345, $366, $466, $577, $677
    dc.w    $022, $032, $043, $243, $354, $465, $576, $676
    dc.w    $020, $030, $040, $242, $353, $464, $575, $676
    dc.w    $220, $230, $342, $352, $463, $473, $674, $775
    dc.w    $220, $330, $332, $442, $553, $663, $664, $775
    dc.w    $210, $320, $432, $540, $543, $654, $764, $775


; table that maps ANTIC mode to number of bytes on ST screen

; mpMdScrBytes:
;    dc.w    0
;    dc.w    160
;    dc.w    8*160
;    dc.w    10*160
;    dc.w    8*160
;    dc.w    16*160
;    dc.w    8*160
;    dc.w    16*160
;    dc.w    8*160
;    dc.w    4*160
;    dc.w    4*160
;    dc.w    2*160
;    dc.w    1*160
;    dc.w    2*160
;    dc.w    1*160
;    dc.w    1*160
    
; tables of structures to map each ANTIC mode to:
;   - number of 8-bit bytes per scan line
;   - number of bytes offset to first byte display
;   - number of bytes displayed
;   - an unused word
;
;   each structure is 8 bytes long
;

; this table is required to handle 32 column displays

; mpMd32:
;    dc.w     0, 0,  0,  0
;    dc.w     0, 0,  0,  160
;    dc.w    32, 0, 32,  8*160
;    dc.w    32, 0, 32,  10*160
;    dc.w    32, 0, 32,  8*160
;    dc.w    32, 0, 32,  16*160
;    dc.w    16, 0, 16,  8*160
;    dc.w    16, 0, 16,  16*160
;    dc.w     8, 0,  8,  8*160
;    dc.w     8, 0,  8,  4*160
;    dc.w    16, 0, 16,  4*160
;    dc.w    16, 0, 16,  2*160
;    dc.w    16, 0, 16,  1*160
;    dc.w    32, 0, 32,  2*160
;    dc.w    32, 0, 32,  1*160
;    dc.w    32, 0, 32,  1*160

; this table is required to handle 40 column displays

; mpMd40:
;    dc.w     0, 0,  0,  0
;    dc.w     0, 0,  0,  160
;    dc.w    40, 0, 40,  8*160
;    dc.w    40, 0, 40,  10*160
;    dc.w    40, 0, 40,  8*160
;    dc.w    40, 0, 40,  16*160
;    dc.w    20, 0, 20,  8*160
;    dc.w    20, 0, 20,  16*160
;    dc.w    10, 0, 10,  8*160
;    dc.w    10, 0, 10,  4*160
;    dc.w    20, 0, 20,  4*160
;    dc.w    20, 0, 20,  2*160
;    dc.w    20, 0, 20,  1*160
;    dc.w    40, 0, 40,  2*160
;    dc.w    40, 0, 40,  1*160
;    dc.w    40, 0, 40,  1*160

; this table is required to handle 48 column displays

; mpMd48:
;    dc.w     0, 0,  0,  0
;    dc.w     0, 0,  0,  160
;    dc.w    48, 4, 40,  8*160
;    dc.w    48, 4, 40,  10*160
;    dc.w    48, 4, 40,  8*160
;    dc.w    48, 4, 40,  16*160
;    dc.w    24, 2, 20,  8*160
;    dc.w    24, 2, 20,  16*160
;    dc.w    12, 1, 10,  8*160
;    dc.w    12, 1, 10,  4*160
;    dc.w    24, 2, 20,  4*160
;    dc.w    24, 2, 20,  2*160
;    dc.w    24, 2, 20,  1*160
;    dc.w    48, 4, 40,  2*160
;    dc.w    48, 4, 40,  1*160
;    dc.w    48, 4, 40,  1*160

; this tabel maps the screen width (0-3) to one of the above tables

; mpmpMd:
;    dc.l    0
;    dc.l    mpMd32
;    dc.l    mpMd40
;    dc.l    mpMd48


; maps ANTIC mode to address of plotting routine, color

mpModeC:
    dc.l    0,  0
    dc.l    0,  0
    dc.l    mode_2C,    plot_2C
    dc.l    mode_3C,    plot_3C
    dc.l    mode_4C,    plot_4C
    dc.l    mode_5C,    plot_5C
    dc.l    mode_6C,    plot_6C
    dc.l    mode_7C,    plot_7C
    dc.l    mode_8C,    plot_8C
    dc.l    mode_9C,    plot_9C
    dc.l    mode_AC,    plot_AC
    dc.l    mode_BC,    plot_BC
    dc.l    mode_CC,    plot_CC
    dc.l    mode_DC,    plot_DC
    dc.l    mode_EC,    plot_EC
    dc.l    mode_FC,    plot_FC

; maps ANTIC mode to address of plotting routine, monochrome

mpModeM:
    dc.l    0,  0
    dc.l    0,  0
    dc.l    mode_2M,    plot_2M
    dc.l    mode_3M,    plot_3M
    dc.l    mode_4M,    plot_4M
    dc.l    mode_5M,    plot_5M
    dc.l    mode_6M,    plot_6M
    dc.l    mode_7M,    plot_7M
    dc.l    mode_8M,    plot_8M
    dc.l    mode_9M,    plot_9M
    dc.l    mode_AM,    plot_AM
    dc.l    mode_BM,    plot_BM
    dc.l    mode_CM,    plot_CM
    dc.l    mode_DM,    plot_DM
    dc.l    mode_EM,    plot_EM
    dc.l    mode_FM,    plot_FM


__rgDL::
    dc.b    24          ; scan line (0 - 255)
    dc.b    2           ; ANTIC mode (0 - 15)
    dc.w    40000       ; start of screen block (6502 address)
    dc.w    960         ; length of screen block (6502 bytes)
    dc.w    40960       ; end of screen block (6502 address)
    dc.w    $E000       ; character base (6502 address)
    dc.w    40          ; count of bytes
    dc.l    plot_2M     ; pointer to byte plot function
    dc.l    _lScrPtrs   ; pointer to screen pointers

    dc.w    0



    .text

; # of bitplanes

_planes::
    dc.w    0

; bytes per scan line

_bytes_lin::
    dc.w    0
_bytes_2lin::
    dc.w    0
_bytes_3lin::
    dc.w    0
_bytes_4lin::
    dc.w    0
_bytes_5lin::
    dc.w    0
_bytes_6lin::
    dc.w    0
_bytes_7lin::
    dc.w    0
_bytes_8lin::
    dc.w    0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; clear the WStat array and rgDL array

_clearDL::
    movem.l d1-d7/a0-a3,-(sp)

    move.w  _uAtMin,d0      ; check lowest screen byte
    cmpi.w  #$8000,d0       ; if above 32K, no need to clear
    bcc     .1

    ; clear WStat for first 32K of RAM
    lea     _lWStat0,a0
    move.w  #2047,d0
.l0:
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    dbf     d0,.l0

.1:
    lea     _lWStat0,a0
    lea     $8000(a0),a0
    move.w  _uAtRAM,d0
    andi.w  #$7FFF,d0
    lsr.w   #4,d0
    subq.l  #1,d0
.l1:
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    clr.l   (a0)+
    dbf     d0,.l1

    clr.l   _rgDL
    move.w  _uAtRAM,_uAtMin

    movem.l (sp)+,d1-d7/a0-a3
    rts
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; generate new DL structures

; A0 - pointer to DL
; A1 - pointer to lookup table
; A2 - pointer to display list byte
; A3 - pointer to screen map
; A6 - WStat
;
; D2 - loop counter
; D3 - ST screen byte
; D4 - address of 6502 memory
; D5 - DL byte
; D6 - scan line #
; D7 - 6502 memory

_newDL::
    bsr     _clearDL        ; clear old DL arrays

    movem.l d1-d7/a0-a3/a6,-(sp)

    lea     _rgDL,a0
    lea     _lScrPtrs,a3
    moveq   #8,d6           ; scan line # starts at 8
    move.l  _lScr,d3
    sub.l   #3200,d3        ; go back 20 scan lines
    tst.w   _fIsMono
    beq.s   .1
    add.l   #20,d3          ; monochrome adjustment
.1:
    move.l  _lMemory,d7
    move.l  d7,d4
    move.w  _dlisth,d7
    move.l  d7,a2           ; start of DL

loop:
    move.w  a2,d0
    cmp.w   _uAtRAM,d0      ; check if DL is in ROM
    bcc     exit_new        ; if so, get out

    cmp.w   _uAtMin,d0
    bcc     .loop1
    move.w  d0,_uAtMin

.loop1:
    move.b  (a2)+,d5
    andi.w  #$7F,d5
loop2:
    cmpi.w  #228,d6         ; check scan line #
    bcc     .exit

    lea     _lWStat0,a6
    move.b  #$83,-1(a6,a2.w)
    move.b  d5,d0
    andi.w  #$0F,d0
    beq     mode_0         ; is it blank scan lines

    cmpi.b  #1,d0          ; is it JMP
    beq     mode_1

    ; the byte is $2 - $F. Check for a new address
    btst    #6,d5
    beq.s   .3

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)
    move.b  #$83,1(a6,a2.w)

    movep.w 1(a2),d4        ; fetch new video address
    move.b  (a2),d4
    addq.l  #2,a2
    bclr    #6,d5

    cmp.w   _uAtMin,d4
    bcc     .3
    move.w  d0,_uAtMin

.3:
    andi.w  #$0F,d5

    ; start setting up DL block
    move.b  d5,bMode(a0)
    move.b  d6,bScan(a0)
    move.l  a3,plPtrs(a0)
    move.w  d4,uStart(a0)
    clr.w   uLen(a0)
    move.w  d4,uEnd(a0)
    move.w  _chbase,uChbase(a0)

    lea     mpModeM,a1

    tst.w   _fIsMono
    bne     .m

    lea     mpModeC,a1
.m:
    add.w   d0,d0
    add.w   d0,d0
    add.w   d0,d0
    adda.w  d0,a1
    move.l  4(a1),pfPlot(a0)
    move.l  (a1),a1
    jmp     (a1)

.exit:
exit_new:
    clr.l   (a0)        ; last DL block

    ; clear to remainder of screen
    move.l  d3,a0
    not     d3
    lsr.w   #2,d3
.fff:
    clr.l   (a0)+
    dbf     d3,.fff

    movem.l (sp)+,d1-d7/a0-a3/a6
    clr.b   _fRedraw
    rts


    ; opcode $x0 - skip x+1 scan lines
mode_0:
    move.b  #1,bMode(a0)
    move.b  d6,bScan(a0)
    lea     plot_1,a1
    move.l  a1,pfPlot(a0)

    clr.w   uStart(a0)
    clr.w   uLen(a0)
    clr.w   uEnd(a0)

.mode_00:
    cmpi.w  #228,d6         ; check scan line #
    bcc     .m0

    andi.w  #$0070,d5
    addi.w  #$10,d5     ; $10 - $80

    move.w  d5,d0
    lsr.w   #4,d0
    add.w   d0,d6       ; increment scan line #

    move.w  d5,d0
    add.w   d0,d0
    add.w   d0,d0
    add.w   d5,d0       ; * 5
    add.w   d0,d0       ; *2 = *10 (it was already * 16 = *160)
    move.w  d0,cb(a0)
    move.l  d3,a1
    add.w   d0,d3       ; increment ST screen location

    ; clear ST screen scan lines
    lsr.w   #4,d0
    subq.w  #1,d0
.mc:
    clr.l   (a1)+
    clr.l   (a1)+
    clr.l   (a1)+
    clr.l   (a1)+
    dbf     d0,.mc

    move.b  (a2)+,d5    ; grab next display list byte
    lea     _lWStat0,a6
    move.b  #$83,-1(a6,a2.w)
    andi.w  #$7F,d5
    move.b  d5,d0
    andi.w  #$0F,d0     ; is it another $x0 opcode
    beq.s   .mode_00    ; yes, same DL

.m0:
    lea     sizeDL(a0),a0   ; next DL

    bra     loop2



    ; opcode $x1 - JMP DL
mode_1:
    btst    #6,d5       ; check for end of DL byte
    bne     exit_new

    lea     _lWStat0,a6
    move.b  #$83,-1(a6,a2.w)

    lea     _lWStat0,a6
    move.b  #$83,(a6,a2.w)
    move.b  #$83,1(a6,a2.w)

    movep.w 1(a2),d7
    move.b  (a2),d7
    addq.l  #2,a2
    move.l  d7,a2       ; load new display list location

    addq.l  #1,d6       ; skip one scan line
    addi.w  #160,d3

    bra     loop



mode_2C:
mode_4C:
mode_5C:
    move.w  #40,cb(a0)

.m21:
    add.w   #40,uLen(a0)
    add.w   #40,uEnd(a0)

    ; put 40 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    move.l  d3,a1
    moveq   #$FF,d1
    moveq   #19,d2
.m2:
    move.l  a1,(a3)+    ; screen map byte
    move.l d1,0(a1)
    move.l d1,160(a1)
    move.l d1,320(a1)
    move.l d1,480(a1)
    move.l d1,640(a1)
    move.l d1,800(a1)
    move.l d1,960(a1)
    move.l d1,1120(a1)
    addq.l  #1,a1
    move.b  d0,(a6)+    ; WStat byte

    move.l  a1,(a3)+    ; screen map byte
    addq.l  #7,a1
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m2

    move.l  a1,d3
    addi.w  #1120,d3    ; skip to next line
    add.w   #40,d4
    addq.w  #8,d6       ; skip 8 scan lines

    cmpi.b  #5,d5       ; is it mode 5?
    bne.s   .m5

    addi.w  #1280,d3    ; antic mode 5 is twice as high
    addq.w  #8,d6       ; skip 8 scan lines

.m5:
    cmpi.w  #228,d6
    bcc.s   .m2x

    cmp.b   (a2),d5     ; is next DL byte also 2?
    bne.s   .m2x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m21

.m2x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop

mode_2M:
mode_4M:
mode_5M:
    move.w  #40,cb(a0)

.m21:
    add.w   #40,uLen(a0)
    add.w   #40,uEnd(a0)

    ; put 40 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #39,d2
.m2:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #1,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m2

    addi.w  #1240,d3    ; skip to next line
    add.w   #40,d4
    addq.w  #8,d6       ; skip 8 scan lines

    cmpi.b  #5,d5       ; is it mode 5?
    bne.s   .m5

    addi.w  #1280,d3    ; antic mode 5 is twice as high
    addq.w  #8,d6       ; skip 8 scan lines

.m5:
    cmpi.w  #228,d6
    bcc.s   .m2x

    cmp.b   (a2),d5     ; is next DL byte also 2?
    bne.s   .m2x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m21

.m2x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop



mode_3C:
    move.w  #40,cb(a0)

.m21:
    add.w   #40,uLen(a0)
    add.w   #40,uEnd(a0)

    ; put 40 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    move.l  d3,a1
    moveq   #$FF,d1
    moveq   #19,d2
.m2:
    move.l  a1,(a3)+    ; screen map byte
    move.l d1,0(a1)
    move.l d1,160(a1)
    move.l d1,320(a1)
    move.l d1,480(a1)
    move.l d1,640(a1)
    move.l d1,800(a1)
    move.l d1,960(a1)
    move.l d1,1120(a1)
    move.l d1,1280(a1)
    move.l d1,1440(a1)
    addq.l  #1,a1
    move.b  d0,(a6)+    ; WStat byte

    move.l  a1,(a3)+    ; screen map byte
    addq.l  #7,a1
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m2

    move.l  a1,d3
    addi.w  #1440,d3    ; skip to next line
    add.w   #40,d4
    addi.w  #10,d6      ; skip 10 scan lines
    cmpi.w  #228,d6
    bcc.s   .m2x

    cmp.b   (a2),d5     ; is next DL byte also 3?
    bne.s   .m2x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m21

.m2x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop

mode_3M:
    move.w  #40,cb(a0)

.m21:
    add.w   #40,uLen(a0)
    add.w   #40,uEnd(a0)

    ; put 40 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #39,d2
.m2:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #1,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m2

    addi.w  #1560,d3    ; skip to next line
    add.w   #40,d4
    addi.w  #10,d6      ; skip 10 scan lines
    cmpi.w  #228,d6
    bcc.s   .m2x

    cmp.b   (a2),d5     ; is next DL byte also 3?
    bne.s   .m2x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m21

.m2x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop


mode_6C:
mode_7C:
    move.w  #20,cb(a0)

.m21:
    add.w   #20,uLen(a0)
    add.w   #20,uEnd(a0)

    ; put 20 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    move.l  d3,a1
    moveq   #19,d2
.m2:
    move.l  a1,(a3)+    ; screen map byte
    addq.l  #8,a1
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m2

    move.l  a1,d3
    addi.w  #1120,d3    ; skip to next line
    add.w   #20,d4
    addq.w  #8,d6       ; skip 8 scan lines

    cmpi.b  #7,d5       ; is it mode 7?
    bne.s   .m7

    addi.w  #1280,d3    ; antic mode 7 is twice as high
    addq.w  #8,d6       ; skip 8 scan lines

.m7:
    cmpi.w  #228,d6
    bcc.s   .m2x

    cmp.b   (a2),d5     ; is next DL byte also 6?
    bne.s   .m2x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m21

.m2x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop

mode_6M:
mode_7M:
    move.w  #20,cb(a0)

.m21:
    add.w   #20,uLen(a0)
    add.w   #20,uEnd(a0)

    ; put 20 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #19,d2
.m2:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #2,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m2

    addi.w  #1240,d3    ; skip to next line
    add.w   #20,d4
    addq.w  #8,d6       ; skip 8 scan lines

    cmpi.b  #7,d5       ; is it mode 7?
    bne.s   .m7

    addi.w  #1280,d3    ; antic mode 7 is twice as high
    addq.w  #8,d6       ; skip 8 scan lines

.m7:
    cmpi.w  #228,d6
    bcc.s   .m2x

    cmp.b   (a2),d5     ; is next DL byte also 6?
    bne.s   .m2x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m21

.m2x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop


mode_8C:
    move.w  #10,cb(a0)

.m81:
    add.w   #10,uLen(a0)
    add.w   #10,uEnd(a0)

    ; put 10 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #9,d2
.m8:
    move.l  d3,(a3)+    ; screen map byte
    addi.w  #16,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m8

    add.w   #10,d4
    addq.w  #8,d6       ; skip 8 scan lines
    addi.w  #1120,d3

    cmpi.w  #228,d6
    bcc.s   .m8x

    cmp.b   (a2),d5    ; is next DL byte also 8?
    bne.s   .m8x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m81

.m8x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop

mode_8M:
    move.w  #10,cb(a0)

.m81:
    add.w   #10,uLen(a0)
    add.w   #10,uEnd(a0)

    ; put 10 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #9,d2
.m8:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #4,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m8

    addi.w  #1240,d3    ; skip to next line
    add.w   #10,d4
    addq.w  #8,d6       ; skip 8 scan line

    cmpi.w  #228,d6
    bcc.s   .m8x

    cmp.b   (a2),d5    ; is next DL byte also 8?
    bne.s   .m8x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m81

.m8x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop


mode_9C:
    move.w  #10,cb(a0)

.m91:
    add.w   #10,uLen(a0)
    add.w   #10,uEnd(a0)

    ; put 10 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #9,d2
.m9:
    move.l  d3,(a3)+    ; screen map byte
    addi.w  #16,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m9

    add.w   #10,d4
    addq.w  #4,d6       ; skip 1 scan line
    addi.w  #480,d3

    cmpi.w  #228,d6
    bcc.s   .m9x

    cmp.b   (a2),d5    ; is next DL byte also 9?
    bne.s   .m9x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m91

.m9x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop

mode_9M:
    move.w  #10,cb(a0)

.m91:
    add.w   #10,uLen(a0)
    add.w   #10,uEnd(a0)

    ; put 10 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #9,d2
.m9:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #4,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.m9

    addi.w  #600,d3    ; skip to next line
    add.w   #10,d4
    addq.w  #4,d6       ; skip 4 scan line

    cmpi.w  #228,d6
    bcc.s   .m9x

    cmp.b   (a2),d5    ; is next DL byte also 9?
    bne.s   .m9x

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .m91

.m9x:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop



mode_AC:
    move.w  #20,cb(a0)

.mA1:
    add.w   #20,uLen(a0)
    add.w   #20,uEnd(a0)

    ; put 20 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #19,d2
.mA:
    move.l  d3,(a3)+    ; screen map byte
    addi.l  #8,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.mA

    add.w   #20,d4
    addq.w  #4,d6       ; skip 4 scan lines
    addi.w  #480,d3

    cmpi.w  #228,d6
    bcc.s   .mAx

    cmp.b   (a2),d5    ; is next DL byte also A?
    bne.s   .mAx

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .mA1

.mAx:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop

mode_AM:
    move.w  #20,cb(a0)

.mA1:
    add.w   #20,uLen(a0)
    add.w   #20,uEnd(a0)

    ; put 20 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #19,d2
.mA:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #2,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.mA

    addi.w  #600,d3    ; skip to next line
    add.w   #20,d4
    addq.w  #4,d6       ; skip 4 scan line

    cmpi.w  #228,d6
    bcc.s   .mAx

    cmp.b   (a2),d5    ; is next DL byte also A?
    bne.s   .mAx

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .mA1

.mAx:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop


mode_BC:
mode_CC:
    move.w  #20,cb(a0)

.mC1:
    add.w   #20,uLen(a0)
    add.w   #20,uEnd(a0)

    ; put 20 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #19,d2
.mC:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #8,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.mC

    add.w   #20,d4
    addq.w  #1,d6       ; skip 1 scan line

    cmpi.b  #$B,d5      ; is it mode B?
    bne.s   .mB

    addi.w  #160,d3
    addq.w  #1,d6       ; skip 1 scan lines

.mB:
    cmpi.w  #228,d6
    bcc.s   .mCx

    cmp.b   (a2),d5    ; is next DL byte also C?
    bne.s   .mCx

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .mC1

.mCx:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop

mode_BM:
mode_CM:
    move.w  #20,cb(a0)

.mC1:
    add.w   #20,uLen(a0)
    add.w   #20,uEnd(a0)

    ; put 20 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #19,d2
.mC:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #2,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.mC

    addi.w  #120,d3    ; skip to next line
    add.w   #20,d4
    addq.w  #1,d6       ; skip 1 scan line

    cmpi.b  #$B,d5      ; is it mode B?
    bne.s   .mB

    addi.w  #160,d3
    addq.w  #1,d6       ; skip 1 scan lines

.mB:
    cmpi.w  #228,d6
    bcc.s   .mCx

    cmp.b   (a2),d5    ; is next DL byte also C?
    bne.s   .mCx

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .mC1

.mCx:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop


mode_DC:
mode_EC:
mode_FC:
    move.w  #40,cb(a0)

.mF1:
    add.w   #40,uLen(a0)
    add.w   #40,uEnd(a0)

    ; put 40 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #19,d2
.mF:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #1,d3
    move.b  d0,(a6)+    ; WStat byte
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #7,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.mF

    add.w   #40,d4
    addq.w  #1,d6       ; skip 1 scan line

    cmpi.b  #$D,d5      ; is it mode D?
    bne.s   .mD

    addi.w  #160,d3
    addq.w  #1,d6       ; skip 1 scan lines

.mD:
    cmpi.w  #228,d6
    bcc.s   .mFx

    cmp.b   (a2),d5    ; is next DL byte also F?
    bne.s   .mFx

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .mF1

.mFx:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop

mode_DM:
mode_EM:
mode_FM:
    move.w  #40,cb(a0)

.mF1:
    add.w   #40,uLen(a0)
    add.w   #40,uEnd(a0)

    ; put 40 pointers in screen map
    ; and set WStat bytes for that scan line
    lea     _lWStat0,a6
    adda.w  d4,a6
    move.b  #$82,d0
    moveq   #39,d2
.mF:
    move.l  d3,(a3)+    ; screen map byte
    addq.l  #1,d3
    move.b  d0,(a6)+    ; WStat byte
    dbf     d2,.mF

    addi.w  #120,d3    ; skip to next line
    add.w   #40,d4
    addq.w  #1,d6       ; skip 1 scan line

    cmpi.b  #$D,d5      ; is it mode D?
    bne.s   .mD

    addi.w  #160,d3
    addq.w  #1,d6       ; skip 1 scan lines

.mD:
    cmpi.w  #228,d6
    bcc.s   .mFx

    cmp.b   (a2),d5    ; is next DL byte also F?
    bne.s   .mFx

    lea     _lWStat0,a6
    move.b  #$83,0(a6,a2.w)

    addq.l  #1,a2       ; yes, so continue with same DL
    bra     .mF1

.mFx:
    lea     sizeDL(a0),a0   ; next DL
    bra     loop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; redraw the entire screen based on the DL structers. Does not change DLs

_Redraw::
    movem.l d1-d7/a1-a3/a6,-(sp)

    move.l  _lMemory,d5
    move.l  d5,d6
    move.l  d5,d7
    lea     _rgDL,a0

.loop:
    move.w  bScan(a0),d1    ; get scan line and mode
    beq.s   .exit

    move.l  plPtrs(a0),a3   ; screen pointers

    move.w  uStart(a0),d5   ; 6502 address of block
    move.w  uLen(a0),d1     ; count of bytes - 1
    subq.w  #1,d1

    move.l  pfPlot(a0),a2
    jsr     (a2)            ; go plot

.next:
    lea     sizeDL(a0),a0
    bra.s   .loop

.exit:
    movem.l (sp)+,d1-d7/a1-a3/a6
    clr.b   _fRedraw
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Text and graphics plotting routines
;
; Each routine is entrant only from assembler, as they use register
; passing. Register usage is identical to that of the redraw routine
; so no registers need to be saved. When calling from a write service
; routine, the necessary registers need to be set up. 
; None of the routines uses A4 or A5. Those registers must NOT change!
; Color routines do not use bit plane 3, reserved for PMG
;
; Register usage:
;
;   A0 - pointer to DL structure
;   A1 - pointer to ST screen byte
;   A2 - pointer to font / 6502 memory
;   A3 - pointer to screen map
;   A6 -
;
;   D0 - scratch
;   D1 - count of bytes to plot - 1
;   D2 -
;   D3 - 
;   D4 -
;   D5 - current 6502 memory location
;   D6 - font address
;   D7 - 6502 memory
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode 2 - text mode 0, 40*24 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_2C:
plot_4C:
plot_5C:
    move.w  uChbase(a0),d7
    andi.w  #~1023,d7
    move.l  d7,d6       ; pointer to font

.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    clr.w   d0
    move.b  (a2),d0     ; get byte to poke
    addq.l  #1,d5

    move.l  (a3)+,a1    ; pointer to screen memory

    add.b   d0,d0
    bcs     .inv
    add.w   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    move.b  (a2)+,4(a1)
    move.b  (a2)+,164(a1)
    move.b  (a2)+,324(a1)
    move.b  (a2)+,484(a1)
    move.b  (a2)+,644(a1)
    move.b  (a2)+,804(a1)
    move.b  (a2)+,964(a1)
    move.b  (a2)+,1124(a1)

    dbf     d1,.loop
    rts

.inv:
    add.w   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,4(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,164(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,324(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,484(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,644(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,804(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,964(a1)
    move.b  (a2),d0
    not.b   d0
    move.b  d0,1124(a1)

    dbf     d1,.loop
    rts

plot_2M:
plot_4M:
plot_5M:
    move.w  uChbase(a0),d7
    andi.w  #~1023,d7
    move.l  d7,d6       ; pointer to font

.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    clr.w   d0
    move.b  (a2),d0     ; get byte to poke
    addq.l  #1,d5

    move.l  (a3)+,a1    ; pointer to screen memory

    add.b   d0,d0
    bcs     .inv
    add.w   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    move.b  (a2),(a1)
    move.b  (a2)+,80(a1)
    move.b  (a2),160(a1)
    move.b  (a2)+,240(a1)
    move.b  (a2),320(a1)
    move.b  (a2)+,400(a1)
    move.b  (a2),480(a1)
    move.b  (a2)+,560(a1)
    move.b  (a2),640(a1)
    move.b  (a2)+,720(a1)
    move.b  (a2),800(a1)
    move.b  (a2)+,880(a1)
    move.b  (a2),960(a1)
    move.b  (a2)+,1040(a1)
    move.b  (a2),1120(a1)
    move.b  (a2),1200(a1)

    dbf     d1,.loop
    rts

.inv:
    add.w   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,(a1)
    move.b  d0,80(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,160(a1)
    move.b  d0,240(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,320(a1)
    move.b  d0,400(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,480(a1)
    move.b  d0,560(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,640(a1)
    move.b  d0,720(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,800(a1)
    move.b  d0,880(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,960(a1)
    move.b  d0,1040(a1)
    move.b  (a2),d0
    not.b   d0
    move.b  d0,1120(a1)
    move.b  d0,1200(a1)

    dbf     d1,.loop
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode 3 - text mode 0+, 40*19 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_3C:
    move.w  uChbase(a0),d7
    andi.w  #~1023,d7
    move.l  d7,d6       ; pointer to font

.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    clr.w   d0
    move.b  (a2),d0     ; get byte to poke
    addq.l  #1,d5

    move.l  (a3)+,a1    ; pointer to screen memory

    add.b   d0,d0
    bcs     .inv
    add.w   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    andi.w  #$300,d0     ; extract name bits
    cmpi.w  #$300,d0
    beq.s   .lc

    move.b  (a2)+,4(a1)
    move.b  (a2)+,164(a1)
    move.b  (a2)+,324(a1)
    move.b  (a2)+,484(a1)
    move.b  (a2)+,644(a1)
    move.b  (a2)+,804(a1)
    move.b  (a2)+,964(a1)
    move.b  (a2)+,1124(a1)
    clr.b   1284(a1)
    clr.b   1444(a1)

    dbf     d1,.loop
    rts

.lc:
    clr.b   4(a1)
    clr.b   164(a1)
    move.b  (a2)+,1284(a1)
    move.b  (a2)+,1444(a1)
    move.b  (a2)+,324(a1)
    move.b  (a2)+,484(a1)
    move.b  (a2)+,644(a1)
    move.b  (a2)+,804(a1)
    move.b  (a2)+,964(a1)
    move.b  (a2)+,1124(a1)

    dbf     d1,.loop
    rts

.inv:
    add.w   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    andi.w  #$300,d0     ; extract name bits
    cmpi.w  #$300,d0
    beq.s   .ilc

    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,4(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,164(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,324(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,484(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,644(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,804(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,964(a1)
    move.b  (a2),d0
    not.b   d0
    move.b  d0,1124(a1)
    st      1284(a1)
    st      1444(a1)

    dbf     d1,.loop
    rts

.ilc:
    st      4(a1)
    st      164(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,1284(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,1444(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,324(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,484(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,644(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,804(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,964(a1)
    move.b  (a2),d0
    not.b   d0
    move.b  d0,1124(a1)

    dbf     d1,.loop
    rts

plot_3M:
    move.w  uChbase(a0),d7
    andi.w  #~1023,d7
    move.l  d7,d6       ; pointer to font

.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    clr.w   d0
    move.b  (a2),d0     ; get byte to poke
    addq.l  #1,d5

    move.l  (a3)+,a1    ; pointer to screen memory

    add.b   d0,d0
    bcs     .inv
    add.w   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    andi.w  #$300,d0     ; extract name bits
    cmpi.w  #$300,d0
    beq.s   .lc

    move.b  (a2),(a1)
    move.b  (a2)+,80(a1)
    move.b  (a2),160(a1)
    move.b  (a2)+,240(a1)
    move.b  (a2),320(a1)
    move.b  (a2)+,400(a1)
    move.b  (a2),480(a1)
    move.b  (a2)+,560(a1)
    move.b  (a2),640(a1)
    move.b  (a2)+,720(a1)
    move.b  (a2),800(a1)
    move.b  (a2)+,880(a1)
    move.b  (a2),960(a1)
    move.b  (a2)+,1040(a1)
    move.b  (a2),1120(a1)
    move.b  (a2),1200(a1)
    clr.b   1280(a1)
    clr.b   1360(a1)
    clr.b   1440(a1)
    clr.b   1520(a1)

    dbf     d1,.loop
    rts

.lc:
    clr.b   (a1)
    clr.b   80(a1)
    clr.b   160(a1)
    clr.b   240(a1)
    move.b  (a2),1280(a1)
    move.b  (a2)+,1360(a1)
    move.b  (a2),1440(a1)
    move.b  (a2)+,1520(a1)
    move.b  (a2),320(a1)
    move.b  (a2)+,400(a1)
    move.b  (a2),480(a1)
    move.b  (a2)+,560(a1)
    move.b  (a2),640(a1)
    move.b  (a2)+,720(a1)
    move.b  (a2),800(a1)
    move.b  (a2)+,880(a1)
    move.b  (a2),960(a1)
    move.b  (a2)+,1040(a1)
    move.b  (a2),1120(a1)
    move.b  (a2)+,1200(a1)

    dbf     d1,.loop
    rts

.inv:
    add.w   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    andi.w  #$300,d0     ; extract name bits
    cmpi.w  #$300,d0
    beq.s   .ilc

    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,(a1)
    move.b  d0,80(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,160(a1)
    move.b  d0,240(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,320(a1)
    move.b  d0,400(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,480(a1)
    move.b  d0,560(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,640(a1)
    move.b  d0,720(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,800(a1)
    move.b  d0,880(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,960(a1)
    move.b  d0,1040(a1)
    move.b  (a2),d0
    not.b   d0
    move.b  d0,1120(a1)
    move.b  d0,1200(a1)
    st      1280(a1)
    st      1360(a1)
    st      1440(a1)
    st      1520(a1)

    dbf     d1,.loop
    rts

.ilc:
    st      (a1)
    st      80(a1)
    st      160(a1)
    st      240(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,1280(a1)
    move.b  d0,1360(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,1440(a1)
    move.b  d0,1520(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,320(a1)
    move.b  d0,400(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,480(a1)
    move.b  d0,560(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,640(a1)
    move.b  d0,720(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,800(a1)
    move.b  d0,880(a1)
    move.b  (a2)+,d0
    not.b   d0
    move.b  d0,960(a1)
    move.b  d0,1040(a1)
    move.b  (a2),d0
    not.b   d0
    move.b  d0,1120(a1)
    move.b  d0,1200(a1)

    dbf     d1,.loop
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode 6 - text mode 1, 20*24 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_6C:
    move.w  uChbase(a0),d7
    andi.w  #~1023,d7
    move.l  d7,d6       ; pointer to font

.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    clr.w   d0
    move.b  (a2),d0     ; get byte to poke
    addq.l  #1,d5

    move.l  (a3)+,a1    ; pointer to screen memory

    add.b   d0,d0
    add.b   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    lea     Lmp8to16,a6

    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,(a1)
    clr.l   2(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,160(a1)
    clr.l   162(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,320(a1)
    clr.l   322(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,480(a1)
    clr.l   482(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,640(a1)
    clr.l   642(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,800(a1)
    clr.l   802(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,960(a1)
    clr.l   962(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,1120(a1)
    clr.l   1122(a1)

    dbf     d1,.loop
    rts


plot_6M:
    move.w  uChbase(a0),d7
    andi.w  #~1023,d7
    move.l  d7,d6       ; pointer to font

.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    clr.w   d0
    move.b  (a2),d0     ; get byte to poke
    addq.l  #1,d5

    move.l  (a3)+,a1    ; pointer to screen memory

    add.b   d0,d0
    add.b   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    lea     Lmp8to16,a6

    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,(a1)
    move.w  d0,80(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,160(a1)
    move.w  d0,240(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,320(a1)
    move.w  d0,400(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,480(a1)
    move.w  d0,560(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,640(a1)
    move.w  d0,720(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,800(a1)
    move.w  d0,880(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,960(a1)
    move.w  d0,1040(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,1120(a1)
    move.w  d0,1200(a1)

    dbf     d1,.loop
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode 7 - text mode 2, 20*12 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_7C:
    move.w  uChbase(a0),d7
    andi.w  #~1023,d7
    move.l  d7,d6       ; pointer to font

.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    clr.w   d0
    move.b  (a2),d0     ; get byte to poke
    addq.l  #1,d5

    move.l  (a3)+,a1    ; pointer to screen memory

    add.b   d0,d0
    add.b   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    lea     Lmp8to16,a6

    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,(a1)
    clr.l   2(a1)
    move.w  d0,160(a1)
    clr.l   162(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,320(a1)
    clr.l   322(a1)
    move.w  d0,480(a1)
    clr.l   482(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,640(a1)
    clr.l   642(a1)
    move.w  d0,800(a1)
    clr.l   802(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,960(a1)
    clr.l   962(a1)
    move.w  d0,1120(a1)
    clr.l   1122(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,1280(a1)
    clr.l   1282(a1)
    move.w  d0,1440(a1)
    clr.l   1442(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,1600(a1)
    clr.l   1602(a1)
    move.w  d0,1760(a1)
    clr.l   1762(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,1920(a1)
    clr.l   1922(a1)
    move.w  d0,2080(a1)
    clr.l   2082(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,2240(a1)
    clr.l   2242(a1)
    move.w  d0,2400(a1)
    clr.l   2402(a1)

    dbf     d1,.loop
    rts

plot_7M:
    move.w  uChbase(a0),d7
    andi.w  #~1023,d7
    move.l  d7,d6       ; pointer to font

.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    clr.w   d0
    move.b  (a2),d0     ; get byte to poke
    addq.l  #1,d5

    move.l  (a3)+,a1    ; pointer to screen memory

    add.b   d0,d0
    add.b   d0,d0
    add.w   d0,d0
    move.l  d6,a2       ; pointer to font
    add.w   d0,a2       ; pointer to char data

    lea     Lmp8to16,a6

    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,(a1)
    move.w  d0,80(a1)
    move.w  d0,160(a1)
    move.w  d0,240(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,320(a1)
    move.w  d0,400(a1)
    move.w  d0,480(a1)
    move.w  d0,560(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,640(a1)
    move.w  d0,720(a1)
    move.w  d0,800(a1)
    move.w  d0,880(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,960(a1)
    move.w  d0,1040(a1)
    move.w  d0,1120(a1)
    move.w  d0,1200(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,1280(a1)
    move.w  d0,1360(a1)
    move.w  d0,1440(a1)
    move.w  d0,1520(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,1600(a1)
    move.w  d0,1680(a1)
    move.w  d0,1760(a1)
    move.w  d0,1840(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,1920(a1)
    move.w  d0,2000(a1)
    move.w  d0,2080(a1)
    move.w  d0,2160(a1)
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    move.w  0(a6,d0.w),d0
    move.w  d0,2240(a1)
    move.w  d0,2320(a1)
    move.w  d0,2400(a1)
    move.w  d0,2480(a1)

    dbf     d1,.loop
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode 8 - gr. 3, 40*25 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_8C:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    add.w   d0,d0
    lea     Lmp8to32,a2
    move.l  0(a2,d0.w),d0
    move.w  D0,8(a1)
    move.w  D0,168(a1)
    move.w  D0,328(a1)
    move.w  D0,488(a1)
    move.w  D0,648(a1)
    move.w  D0,808(a1)
    move.w  D0,968(a1)
    move.w  D0,1128(a1)

    clr.l   10(a1)
    clr.l   170(a1)
    clr.l   330(a1)
    clr.l   490(a1)
    clr.l   650(a1)
    clr.l   810(a1)
    clr.l   970(a1)
    clr.l   1130(a1)

    swap    D0
    move.w  D0,(a1)
    move.w  D0,160(a1)
    move.w  D0,320(a1)
    move.w  D0,480(a1)
    move.w  D0,640(a1)
    move.w  D0,800(a1)
    move.w  D0,960(a1)
    move.w  D0,1120(a1)

    clr.l   2(a1)
    clr.l   162(a1)
    clr.l   322(a1)
    clr.l   482(a1)
    clr.l   642(a1)
    clr.l   802(a1)
    clr.l   962(a1)
    clr.l   1122(a1)

    dbf     d1,.loop
;    move.l  a2,d5
    rts

plot_8M:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    add.w   d0,d0
    lea     Lmp8to32,a2
    move.l  0(a2,d0.w),d0
    move.l  d0,(a1)
    move.l  d0,80(a1)
    move.l  d0,160(a1)
    move.l  d0,240(a1)
    move.l  d0,320(a1)
    move.l  d0,400(a1)
    move.l  d0,480(a1)
    move.l  d0,560(a1)
    move.l  d0,640(a1)
    move.l  d0,720(a1)
    move.l  d0,800(a1)
    move.l  d0,880(a1)
    move.l  d0,960(a1)
    move.l  d0,1040(a1)
    move.l  d0,1120(a1)
    move.l  d0,1200(a1)

    dbf     d1,.loop
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode 9 - gr. 4, 80*50 mode mono
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_9C:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    add.w   d0,d0
    lea     Lmp8to32,a2
    move.l  0(a2,d0.w),d0
    move.w  D0,8(a1)
    move.w  D0,168(a1)
    move.w  D0,328(a1)
    move.w  D0,488(a1)

    clr.l   10(a1)
    clr.l   170(a1)
    clr.l   330(a1)
    clr.l   490(a1)

    swap    D0
    move.w  D0,(a1)
    move.w  D0,160(a1)
    move.w  D0,320(a1)
    move.w  D0,480(a1)

    clr.l   2(a1)
    clr.l   162(a1)
    clr.l   322(a1)
    clr.l   482(a1)

    dbf     d1,.loop
;    move.l  a2,d5
    rts

plot_9M:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    add.w   d0,d0
    lea     Lmp8to32,a2
    move.l  0(a2,d0.w),d0
    move.l  d0,(a1)
    move.l  d0,80(a1)
    move.l  d0,160(a1)
    move.l  d0,240(a1)
    move.l  d0,320(a1)
    move.l  d0,400(a1)
    move.l  d0,480(a1)
    move.l  d0,560(a1)

    dbf     d1,.loop
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode A - gr. 5, 80*50 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_AC:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    lea     Lmp8to16,a2
    add.w   d0,a2

    move.w  (a2),d0
    andi.w  #$3333,d0
    move.w  d0,(a0)
    add.w   d0,d0
    add.w   d0,d0
    or.w    (a0),d0
    move.w  d0,(a1)
    move.w  d0,160(a1)
    move.w  d0,320(a1)
    move.w  d0,480(a1)

    move.w  (a2),d0
    andi.w  #$CCCC,d0
    move.w  d0,(a0)
    lsr.w   #2,d0
    or.w    (a0),d0
    move.w  d0,2(a1)
    move.w  d0,162(a1)
    move.w  d0,322(a1)
    move.w  d0,482(a1)

    clr.l   4(a1)
    clr.l   164(a1)
    clr.l   324(a1)
    clr.l   484(a1)

    dbf     d1,.loop
;    move.l  a2,d5
    rts

plot_AM:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    lea     Lmp8to16,a2
    move.w  0(a2,d0.w),d0
    move.w  d0,(a1)
    move.w  d0,80(a1)
    move.w  d0,160(a1)
    move.w  d0,240(a1)
    move.w  d0,320(a1)
    move.w  d0,400(a1)
    move.w  d0,480(a1)
    move.w  d0,560(a1)

    dbf     d1,.loop
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode B - gr. 6, 160*100 mode mono
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_BC:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    lea     Lmp8to16,a2
    move.w  0(a2,d0.w),d0
    move.w  d0,(a1)
    clr.w   2(a1)
    clr.l   4(a1)
    move.w  d0,160(a1)
    clr.w   162(a1)
    clr.l   164(a1)

    dbf     d1,.loop
;    move.l  a2,d5
    rts

plot_BM:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    lea     Lmp8to16,a2
    move.w  0(a2,d0.w),d0
    move.w  d0,(a1)
    move.w  d0,80(a1)
    move.w  d0,160(a1)
    move.w  d0,240(a1)

    dbf     d1,.loop
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode C - gr. 14, 160*200 mode mono
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_CC:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    lea     Lmp8to16,a2
    move.w  0(a2,d0.w),d0
    move.w  d0,(a1)
    clr.w   2(a1)
    clr.l   4(a1)

    dbf     d1,.loop
;    move.l  a2,d5
    rts

plot_CM:
.loop:
    move.l  d5,a2       ; pointer to 6502 memory
    addq.l   #1,d5
    move.l  (a3)+,a1    ; pointer to screen memory
    clr.w   d0
    move.b  (a2)+,d0
    add.w   d0,d0
    lea     Lmp8to16,a2
    move.w  0(a2,d0.w),d0
    move.w  d0,(a1)
    move.w  d0,80(a1)

    dbf     d1,.loop
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode D - gr. 7, 160*100 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_DC:
    move.l  d5,a2       ; pointer to 6502 memory
.loop:
    move.l  (a3)+,a1    ; pointer to screen memory

    move.b  (a2),d0     ; bit plane 0
    andi.b  #$55,d0
    move.b  d0,(a1)
    add.b   d0,d0
    or.b    d0,(a1)  
    move.b  (a1),160(a1)  
    move.b  (a2)+,d0    ; bit plane 1
    andi.b  #$AA,d0
    move.b  d0,2(a1)
    lsr.b   #1,d0
    or.b    d0,2(a1)  
    move.b  2(a1),162(a1)
    clr.b   4(a1)
    clr.b   164(a1)

    dbf     d1,.loop
    move.l  a2,d5
    rts

plot_DM:
    move.l  d5,a2       ; pointer to 6502 memory
.loop:
    move.l  (a3)+,a1    ; pointer to screen memory
    move.b  (a2),(a1)
    move.b  (a2),80(a1)
    move.b  (a2),160(a1)
    move.b  (a2),240(a1)

    dbf     d1,.loop
    move.l  a2,d5
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode E - gr. 15, 160*200 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_EC:
    move.l  d5,a2       ; pointer to 6502 memory
.loop:
    move.l  (a3)+,a1    ; pointer to screen memory

    move.b  (a2),d0     ; bit plane 0
    andi.b  #$55,d0
    move.b  d0,(a1)
    add.b   d0,d0
    or.b    d0,(a1)  
    move.b  (a2)+,d0    ; bit plane 1
    andi.b  #$AA,d0
    move.b  d0,2(a1)
    lsr.b   #1,d0
    or.b    d0,2(a1)  
    clr.b   4(a1)

    dbf     d1,.loop
    move.l  a2,d5
    rts

plot_EM:
    bra     plot_FM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Antic mode F - gr. 8, 320*200 mode
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

plot_FC:
    move.l  d5,a2       ; pointer to 6502 memory
.loop:
    move.l  (a3)+,a1    ; pointer to screen memory
    move.b  (a2)+,4(a1)
    st      (a1)
    st      2(a1)

    dbf     d1,.loop
    move.l  a2,d5
    rts

plot_FM:
    move.l  d5,a2       ; pointer to 6502 memory
.loop:
    move.l  (a3)+,a1    ; pointer to screen memory
    move.b  (a2),(a1)
    move.b  (a2)+,80(a1)

    dbf     d1,.loop
    move.l  a2,d5
    rts

plot_1:
    rts


