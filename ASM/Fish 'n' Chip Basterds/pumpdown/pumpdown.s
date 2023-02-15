;Pump Down The Volume!
;16 Byte Atari ST "intro" by Spice Boys
;Lovebyte 2023
;50000 BPM VT52 bell!
l337: pea rulz(pc)
 move.w #9,-(sp)
 trap #1		
 bra.s l337
rulz: dc.b "SB~",7
