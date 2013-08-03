; -----------------------------------------------------------------
; ------- Mega fast playroutine for D.O.C-SoundTracker V2.1 -------
; -----------------------------------------------------------------
; ---------- Improved and omptimized by Unknown of D.O.C ----------
; --------------- Based on the playroutine from TJC ---------------
; ------------ Transferred to the ST by Vantage/ST-CNX ------------
; -----------------------------------------------------------------

mt_init:lea mt_data(pc),a0
add.l #$01d8,a0
move.l #$0080,d0
moveq #$00,d1
mt_init1:
move.l d1,d2
subq.w #1,d0
mt_init2:
move.b (a0)+,d1
cmp.b d2,d1
bgt.s mt_init1
dbf d0,mt_init2
addq.b #1,d2

mt_init3:
lea mt_data(pc),a0
lea mt_sample1(pc),a1
asl.l #$08,d2
asl.l #$02,d2
add.l #$0258,d2
add.l a0,d2
moveq #$0e,d0
mt_init4:
move.l d2,(a1)+
moveq #$00,d1
move.w 42(a0),d1
asl.l #1,d1
add.l d1,d2
add.l #$1e,a0
dbf d0,mt_init4

lea mt_sample1(pc),a0
moveq #$00,d0
mt_clear:
move.l (a0,d0),a1
clr.l (a1)
addq.l #4,d0
cmp.l #$3c,d0
bne.s mt_clear

clr.w $dff0a8
clr.w $dff0b8
clr.w $dff0c8
clr.w $dff0d8
clr.l mt_partnrplay
clr.l mt_partnote
clr.l mt_partpoint

move.b mt_data+$1d6,mt_maxpart+1
rts

mt_end: clr.w $dff0a8
clr.w $dff0b8
clr.w $dff0c8
clr.w $dff0d8
move.w #$000f,$dff096
rts

mt_music:
addq.l #1,mt_counter
mt_cool:cmp.l #6,mt_counter
bne.s mt_notsix
clr.l mt_counter
bra mt_rout2

mt_notsix:
lea mt_aud1temp(pc),a6
tst.b 3(a6)
beq.s mt_arp1
lea $dff0a0,a5
bsr.s mt_arprout
mt_arp1:lea mt_aud2temp(pc),a6
tst.b 3(a6)
beq.s mt_arp2
lea $dff0b0,a5
bsr.s mt_arprout
mt_arp2:lea mt_aud3temp(pc),a6
tst.b 3(a6)
beq.s mt_arp3
lea $dff0c0,a5
bsr.s mt_arprout
mt_arp3:lea mt_aud4temp(pc),a6
tst.b 3(a6)
beq.s mt_arp4
lea $dff0d0,a5
bra.s mt_arprout
mt_arp4:rts

mt_arprout:
move.b 2(a6),d0
and.b #$0f,d0
tst.b d0
beq.s mt_arpegrt
cmp.b #1,d0
beq.s mt_portup
cmp.b #2,d0
beq.s mt_portdwn
rts

mt_portup:
moveq #$00,d0
move.b 3(a6),d0
sub.w d0,22(a6)
cmp.w #$71,22(a6)
bpl.s mt_ok1
move.w #$71,22(a6)
mt_ok1: move.w 22(a6),6(a5)
rts

mt_portdwn:
moveq #$00,d0
move.b 3(a6),d0
add.w d0,22(a6)
cmp.w #$358,22(a6)
bmi.s mt_ok2
move.w #$358,22(a6)
mt_ok2: move.w 22(a6),6(a5)
rts

mt_arpegrt:
cmp.l #1,mt_counter
beq.s mt_loop2
cmp.l #2,mt_counter
beq.s mt_loop3
cmp.l #3,mt_counter
beq.s mt_loop4
cmp.l #4,mt_counter
beq.s mt_loop2
cmp.l #5,mt_counter
beq.s mt_loop3
rts

mt_loop2:
moveq #$00,d0
move.b 3(a6),d0
lsr.b #4,d0
bra.s mt_cont
mt_loop3:
moveq #$00,d0
move.b 3(a6),d0
and.b #$0f,d0
bra.s mt_cont
mt_loop4:
move.w 16(a6),d2
bra.s mt_endpart
mt_cont:
asl.w #1,d0
moveq #$00,d1
move.w 16(a6),d1
lea mt_arpeggio(pc),a0
mt_loop5:
move.w (a0,d0),d2
cmp.w (a0),d1
beq.s mt_endpart
addq.l #2,a0
bra.s mt_loop5
mt_endpart:
move.w d2,6(a5)
rts

mt_rout2:
lea mt_data(pc),a0
move.l a0,a3
add.l #$0c,a3
move.l a0,a2
add.l #$1d8,a2
add.l #$258,a0
move.l mt_partnrplay,d0
moveq #$00,d1
move.b (a2,d0),d1
asl.l #$08,d1
asl.l #$02,d1
add.l mt_partnote,d1
move.l d1,mt_partpoint
clr.w mt_dmacon

lea $dff0a0,a5
lea mt_aud1temp(pc),a6
bsr mt_playit
lea $dff0b0,a5
lea mt_aud2temp(pc),a6
bsr mt_playit
lea $dff0c0,a5
lea mt_aud3temp(pc),a6
bsr mt_playit
lea $dff0d0,a5
lea mt_aud4temp(pc),a6
bsr mt_playit
move.w #$008a,d1
mt_loop:dbf d1,mt_loop
move.w #$8000,d0
or.w mt_dmacon,d0
move.w d0,$dff096

lea mt_aud4temp(pc),a6
cmp.w #1,14(a6)
bne.s mt_voice3
move.l 10(a6),$dff0d0
move.w #1,$dff0d4
mt_voice3:
lea mt_aud3temp(pc),a6
cmp.w #1,14(a6)
bne.s mt_voice2
move.l 10(a6),$dff0c0
move.w #1,$dff0c4
mt_voice2:
lea mt_aud2temp(pc),a6
cmp.w #1,14(a6)
bne.s mt_voice1
move.l 10(a6),$dff0b0
move.w #1,$dff0b4
mt_voice1:
lea mt_aud1temp(pc),a6
cmp.w #1,14(a6)
bne.s mt_voice0
move.l 10(a6),$dff0a0
move.w #1,$dff0a4
mt_voice0:
move.l mt_partnote,d0
add.l #$10,d0
move.l d0,mt_partnote
cmp.l #$400,d0
bne.s mt_stop
mt_higher:
clr.l mt_partnote
addq.l #1,mt_partnrplay
moveq #$00,d0
move.w mt_maxpart,d0
move.l mt_partnrplay,d1
cmp.l d0,d1
bne.s mt_stop
clr.l mt_partnrplay

mt_stop:tst.w mt_status
beq.s mt_stop2
clr.w mt_status
bra.s mt_higher
mt_stop2:
rts

mt_playit:
move.l (a0,d1),(a6)
addq.l #4,d1
moveq #$00,d2
move.b 2(a6),d2
and.b #$f0,d2
lsr.b #4,d2
tst.b d2
beq.s mt_nosamplechange

moveq #$00,d3
lea mt_samples(pc),a1
move.l d2,d4
asl.l #2,d2
mulu #$1e,d4
move.l (a1,d2),4(a6)
move.w (a3,d4),8(a6)
move.w 2(a3,d4),18(a6)
move.w 4(a3,d4),d3
tst.w d3
beq.s mt_displace
move.l 4(a6),d2
add.l d3,d2
move.l d2,4(a6)
move.l d2,10(a6)
move.w 6(a3,d4),8(a6)
move.w 6(a3,d4),14(a6)
move.w 18(a6),8(a5)
bra.s mt_nosamplechange

mt_displace:
move.l 4(a6),d2
add.l d3,d2
move.l d2,10(a6)
move.w 6(a3,d4),14(a6)
move.w 18(a6),8(a5)
mt_nosamplechange:
tst.w (a6)
beq.s mt_retrout
move.w (a6),16(a6)
move.w 20(a6),$dff096
move.l 4(a6),(a5)
move.w 8(a6),4(a5)
move.w (a6),6(a5)
move.w 20(a6),d0
or.w d0,mt_dmacon

mt_retrout:
tst.w (a6)
beq.s mt_nonewper
move.w (a6),22(a6)

mt_nonewper:
move.b 2(a6),d0
and.b #$0f,d0
cmp.b #11,d0
beq.s mt_posjmp
cmp.b #12,d0
beq.s mt_setvol
cmp.b #13,d0
beq.s mt_break
cmp.b #14,d0
beq.s mt_setfil
cmp.b #15,d0
beq.s mt_setspeed
rts

mt_posjmp:
not.w mt_status
moveq #$00,d0
move.b 3(a6),d0
subq.b #$01,d0
move.l d0,mt_partnrplay
rts

mt_setvol:
move.b 3(a6),8(a5)
rts

mt_break:
not.w mt_status
rts

mt_setfil:
moveq #$00,d0
move.b 3(a6),d0
and.b #$01,d0
rol.b #$01,d0
and.b #$fd,$bfe001
or.b d0,$bfe001
rts

mt_setspeed:
move.b 3(a6),d0
and.b #$0f,d0
beq.s mt_back
clr.l mt_counter
move.b d0,mt_cool+5
mt_back:rts

mt_aud1temp:
blk.w 10,0
dc.w $0001
blk.w 2,0
mt_aud2temp:
blk.w 10,0
dc.w $0002
blk.w 2,0
mt_aud3temp:
blk.w 10,0
dc.w $0004
blk.w 2,0
mt_aud4temp:
blk.w 10,0
dc.w $0008
blk.w 2,0
mt_partnote: dc.l 0
mt_partnrplay:dc.l 0
mt_counter:dc.l 0
mt_partpoint:dc.l 0
mt_samples:dc.l 0
mt_sample1:blk.l 15,0
mt_maxpart:dc.w $0000
mt_dmacon:dc.w $0000
mt_status:dc.w $0000

mt_arpeggio:
dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000

mt_data:
blk.b 0,0


A little help by Vantage/ST-CNX:
                                       __________
$DFF096=DMA Control Register                    |
$DFF0A0=Audio channel 0 (bits 16-18)            |
$DFF0A4=Data length audio channel 0             |
$DFF0A8=Volume audio channel 0                  |
$DFF0B0=Audio channel 1 (bits 16-18)            |
$DFF0B4=Data length audio channel 1             |
$DFF0B8=Volume audio channel 1                  |- Amiga Registers
$DFF0C0=Audio channel 2 (bits 16-18)            |
$DFF0C4=Data length audio channel 2             |
$DFF0C8=Volume audio channel 2                  |
$DFF0D0=Audio channel 3 (bits 16-18)            |
$DFF0D4=Data length audio channel 3             |
$DFF0D8=Volume audio channel 3         _________|


ST Connexion:One jump ahead !
