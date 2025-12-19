;¯Hier ein kleiner Hardcopy-Treiber fr die DeskJet Besitzer.
;¯Fr den SEKA (quick'n'dirty) Assembler, kann aber wohl  leicht an andere
;¯angepasst werden. (Was umgekehrt nicht so  einfach ist) Der Treiber ist nur fr
;¯die hohe Aufl”sung,  und h„lt sich an folgende Felder der Druckeranpassung:

;¯Punkte/Zeile:    1280 -> 300dpi;          960 -> 150dpi
;¯Qualit„t    :    Test -> Draft;       Maximum -> Normal
;¯Drucker Port: Printer -> Centronics     Modem -> RS232

;¯die anderen Einstellungen werden ignoriert.

; --- entlang der gestrichelten Linie ausschneiden ---
;                                        gk, 20.12.89
; Hardcopy function - for HP Deskjet+
; (older Deskjet and Laserjet should work, too)

hcflag          EQU $04EE
physbase        EQU $044E
hcvec           EQU $0502

start:          bra     entry           ; branch behind resident part

prtbyte:                                ; send byte in d0 to printer
                movem.l D1-D2/A0-A2,-(SP) ; save registers killed by BIOS

                move.w  D0,-(SP)        ; push char
                move.w  device(PC),-(SP) ; and device
                move.w  #3,-(SP)        ; Bconout
                trap    #13
                addq.w  #6,SP
                movem.l (SP)+,D1-D2/A0-A2
                rts

prtstr:                                 ; print string, adress in a0; d0 is used
                move.b  (A0)+,D0        ; get byte
                beq.s   qprtstr         ; done ?
                bsr.s   prtbyte         ; no, output and continue
                bra.s   prtstr

qprtstr:        rts

init:           move.w  #-1,-(SP)
                move.w  #$21,-(SP)      ; Setprt: get config.
                trap    #14
                addq.w  #4,SP
                move.w  D0,prtset       ; save config bits
                move.w  #0,D1
                btst    #4,D0           ; setup device acc to bit 4
                beq.s   init1
                move.w  #1,D1
init1:          move.w  D1,device
                move.l  #$74333030,resol ; 300 dpi
                btst    #2,D0           ; 1280 = 300, 960 = 150 dpi
                beq.s   init2
                move.l  #$74313530,resol ; 150 dpi
init2:          move.b  #'1',D1
                btst    #3,D0           ; setup quality acc to bit 3
                beq.s   init3
                move.b  #'2',D1
init3:          move.b  D1,qual
                rts


dohc:                                   ;DC.W $4AFC      ; used to call debugger if active
                movem.l D0-A6,-(SP)     ; safety first
                bsr.s   init            ; setup vectors & config
                movea.l physbase.w,A4   ; get screen base
                move.w  #399,D6         ; counts lines
                lea     iniseq(PC),A0   ; print graphics init string
                bsr.s   prtstr
;
doline:         lea     lininit(PC),A0  ; print line init string
                bsr.s   prtstr
                move.w  #79,D7          ; setup byte counter

linlop:         move.b  (A4),D0         ; get value, inc
                not.b   (A4)+           ; invert on screen
                bsr     prtbyte         ; and output it
                dbra    D7,linlop       ; loop on colums (bytes)
                tst.w   hcflag.w        ; test for user cancel request
                dbne    D6,doline       ; loop on lines
                lea     termseq(PC),A0  ; send termination sequence
                bsr     prtstr

qhc:            move.l  A4,D0           ; compute how many bytes
                movea.l physbase.w,A4   ; were actually transmitted
                sub.w   A4,D0
                subq.w  #1,D0
invback:        not.b   (A4)+           ; and re-invert only these
                dbra    D0,invback
                movem.l (SP)+,D0-A6     ; restore registers
                rts

prtset:         DC.W 0          ; printer setup stored here
device:         DC.W 0          ; where to output to

                EVEN

iniseq:         DC.B 27,"*rB"   ; prophylactic END RASTER GRAPHICS
                DC.B 27,"*"     ; set resolution part 1
resol:          DC.B "t300R"    ; part 2, MUST be on even address
                DC.B 27,"*r640S" ; set 640 pixel width
                DC.B 27,"*b0M"  ; set non-runlength mode (stay compatible
; to PCL Level III devices)
                DC.B 27,"*r"
qual:           DC.B "1Q"       ; Draft (1) or letter (2) quality
                DC.B 27,"*r0A",0 ; start at leftmost position
lininit:        DC.B 27,"*b80W",0 ; Transfer raster graphics
termseq:        DC.B 27,"*rB"   ; end raster graphics
                DC.B $0D,$0A,0  ; line feed -> delete for adjacent graphics

                EVEN
;
; --- resident part ends here ---
;
entry:          pea     setvec(PC)      ; execute vector setup in Supervisor mode
                move.w  #38,-(SP)
                trap    #14
                addq.l  #6,SP

                clr.w   -(SP)
                move.l  #entry-start+$0100,-(SP) ; compute resident size
                move.w  #$31,-(SP)      ; terminate'n'stay
                trap    #1

setvec:         lea     dohc(PC),A0
                move.l  A0,hcvec
                rts

                END
