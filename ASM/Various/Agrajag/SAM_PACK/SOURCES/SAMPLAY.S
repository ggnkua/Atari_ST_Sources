Replay		move.w  d0,sam_rate
        	move.w  d1,norm_crn
                move.l  a0,-(sp)        ;Stack sample filename
                move.l  #-1,-(sp)
                move.w  #$48,-(sp)      ;Free memory
                trap    #1              ;Malloc
                addq.l  #6,sp
                move.l  d0,memfree
                move.l  d0,-(sp)
                move.w  #$48,-(sp)      ;Reserve all free memory
                trap    #1              ;Malloc
                addq.l  #6,sp
                move.l  d0,memstrt      ;Start of free memory
                movea.l (sp)+,a0        ;restore sample filename
                clr.w   -(sp)           ;Readonly
                move.l  a0,-(sp)        ;Filename
                move.w  #$3d,-(sp)
                trap    #1              ;Fopen
                addq.l  #8,sp
                bmi     desktop         ;Error opening file
                move.w  d0,handle
                move.l  memstrt,-(sp)   ;Buffer address
                move.l  memfree,-(sp)   ;Buffer length
                move.w  handle,-(sp)    ;File handle nr
                move.w  #$3f,-(sp)
                trap    #1              ;Fread
                adda.l  #$0c,sp
                tst.l   d0
                bmi     desktop         ;Error reading file
                movea.l memstrt,a0      ;Begin Samplebuffer
                clr.w   crn_4+2         ;Start byte = 0
                move.l  a0,crn_1+2      ;Sample read ptr
                move.l  a0,crn_6+2      ;Loop/Reset ptr
                move.l  a0,norm_int_1+2
                move.l  a0,norm_int_3+2
                adda.l  d0,a0           ;Start + length -> end of Sample file
                move.l  a0,crn_2+2
                move.l  a0,norm_int_2+2
                move.w  handle,-(sp)
                move.w  #$3e,-(sp)
                trap    #1              ;Fclose
                addq.l  #4,sp
                move.w  sam_rate,d0
                lea     freq,a0
                move.b  0(a0,d0.w),cur_freq ;Initialiseer Sample frequentie
                pea     initsc          ;Initialiseer Soundchip
                move.w  #$26,-(sp)
                trap    #14             ;Supexec
                addq.l  #6,sp
                pea     timer
                move.w  #$26,-(sp)
                trap    #14             ;Supexec
                addq.l  #6,sp

conin2:         move.w  #2,-(sp)        ;Console
                move.w  #2,-(sp)
                trap    #13             ;Bconin
                addq.l  #4,sp
                swap    d0              ;Give me the scancode
                cmpi.b  #1,d0           ;ESC key ?
                beq.s   q_loop
                cmpi.b  #$50,d0         ;Downkey
                bne.s   conin2_1
                addi.b  #1,cur_freq
                bra.s   conin2_3
conin2_1:       cmpi.b  #$48,d0         ;Upkey
                bne.s   conin2_2
                subi.b  #1,cur_freq
                bra.s   conin2_3
conin2_2:       cmpi.b  #$02,d0         ;1
                bmi.s   conin2          ;Key not used
                cmpi.b  #$09,d0
                bpl.s   conin2
                subq.w  #2,d0
                andi.w  #$ff,d0         ;High byte could be undefined ?
                lea     freq,a0
                move.b  0(a0,d0.w),cur_freq
conin2_3:       pea     update_freq
                move.w  #$26,-(sp)
                trap    #14             ;Supexec
                addq.l  #6,sp
                bra.s   conin2
q_loop:         pea     de_timer
                move.w  #$26,-(sp)
                trap    #14             ;Supexec
                addq.l  #6,sp
desktop:        move.l  memstrt,-(sp)
                move.w  #$49,-(sp)
                trap    #1              ;Mfree
                addq.l  #6,sp
                rts                     ;Back to the main menu

update_freq:    move.b  cur_freq,d0
                cmp.b   $fffffa1f.w,d0
                beq.s   update_freq_1
                cmpi.b  #30,d0
                bcs.s   update_freq_1
                clr.b   $fffffa19.w
                move.b  d0,$fffa1f
                move.b  #1,$fffffa19.w
update_freq_1:  rts

initsc:         move    sr,-(sp)
                andi    #%1111100011111111,sr ;Disable all interrupts
                lea     initsc_table(pc),a0
initsc_1:       move.w  (a0)+,d0
                bmi.s   initsc_2
                move.b  d0,$ffff8800.w  ;Register
                move.w  (a0)+,d0
                move.b  d0,$ffff8802.w  ;Value
                bra.s   initsc_1
initsc_2:       move    (sp)+,sr
                rts

initsc_table:   DC.W 0,$ff,1,$ff ;Gen A
                DC.W 2,$ff,3,$ff ;Gen B
                DC.W 4,$ff,5,$ff ;Gen C
                DC.W 6,0
                DC.W 7,$ff      ;Both ports are output
                DC.W 8,0,9,0,10,0 ;Volume control on all
                DC.W -1         ;End of table

de_timer:       move.b  old07,$fffa07
                move.b  old09,$fffa09
                move.b  old0b,$fffa0b
                move.b  old0f,$fffa0f
                move.b  old13,$fffa13
                move.b  old19,$fffa19
                move.b  old1f,$fffa1f
                move.l  newkey2+2(pc),$0118.w
                move.l  old134,$0134.w
                move    oldsr,sr
                rts

timer:          move.b  $fffa07,old07
                move.b  $fffa09,old09
                move.b  $fffa0b,old0b
                move.b  $fffa0f,old0f
                move.b  $fffa13,old13
                move.b  $fffa19,old19
                move.b  $fffa1f,old1f
                move    sr,oldsr
                andi    #%1111100011111111,sr
                ori     #$0500,sr
                move.l  $0118.w,newkey2+2
                move.l  #new_key,$0118.w ;New keyboard interrupt
                move.l  $0134.w,old134  ;In case of use
                move.l  #crn_int,$0134.w ;New Timer A interrupt
                tst.w   norm_crn        ;Packed file
                bne.s   timer_2
                move.l  #norm_int,$0134.w ;Normal file
timer_2:        clr.b   $fffffa19.w     ;Hold timer A
                move.b  cur_freq,$fffa1f ;Data Reg timer A
                move.b  #%100000,$fffffa07.w ;Enable TimerA
                move.b  #%1000000,$fffffa09.w ;Enable Keyboard interrupt
                ori.b   #%100000,$fffffa13.w ;Unmask TimerA
                ori.b   #%1000000,$fffffa15.w ;Unmask Keyboard interrupt
                move.b  #1,$fffa19      ;Start Timer A
                rts

new_key:        move    #$2500,sr       ;Reset interruptmask
newkey2:        jmp     $00

norm_int:       movem.l d0/a0,-(sp)
                lea     norm_int(pc),a0
                bclr    #5,$fffffa0f.w  ;Clear interrupt
                clr.w   d0
norm_int_1:     move.b  $99999999,d0    ;Get new sample
                addq.l  #1,norm_int_1+2-norm_int(a0) ;Increase sample ptr
norm_int_2:     cmpi.l  #$99999999,norm_int_1+2-norm_int(a0) ;End of samplefile?
                bne.s   norm_int_4
norm_int_3:     move.l  #$99999999,norm_int_1+2-norm_int(a0) ;Reset sample ptr
norm_int_4:     lsl.w   #4,d0           ;For right table entry
                lea     table(pc),a0    ;table(pc) > 8 bits
                adda.w  d0,a0           ;so single D0 add
                move.l  (a0)+,$ffff8800.w ;Channel A
                move.l  (a0)+,$ffff8800.w ;Channel B
                move.l  (a0)+,$ffff8800.w ;Channel C
                movem.l (sp)+,d0/a0
                rte

crn_int:        movem.l d0/a0,-(sp)
                lea     crn_int_3(pc),a0 ;Tool for fast access
                move.l  a0,$0134.w      ;Nxt Tmr A -> crn_int_3
                bclr    #5,$fffffa0f.w  ;Clr int
                clr.w   d0
crn_1:          move.b  $99999999,d0    ;Next sample
                move.w  d0,crn_3+2-crn_int_3(a0) ;Lower nibble -> next interrupt
                addq.l  #1,crn_1+2-crn_int_3(a0) ;Increase sample ptr
                lsr.b   #4,d0           ;High nibble -> lower nibble
                move.b  decrunchtab(pc,d0.w),d0 ;Convert to sample offset
crn_4:          addi.b  #$99,d0         ;Add to previous sample
crn_int_4:      move.w  d0,crn_5+2-crn_int_3(a0) ;This is the new sample
                lsl.w   #4,d0           ;Make right entry
                lea     table(pc,d0.w),a0 ;ptr to soundtable
                move.l  (a0)+,$ffff8800.w ;Reg A soundchip
                move.l  (a0)+,$ffff8800.w ;Reg B
                move.l  (a0)+,$ffff8800.w ;Reg C
                movem.l (sp)+,d0/a0
                rte
;*************************************
; Decrunch table not in DATA
; because of pc relative (fast)
; access
decrunchtab:    incbin	decrntab.bin
;*************************************
crn_int_2:
crn_6:          move.l  #$99999999,crn_1+2-crn_int(a0) ;Reset sample ptr
                clr.w   crn_4+2-crn_int(a0) ;First sample =  NULL
                bra.s   crn_int_5       ;quick RTS
crn_int_3:      movem.l d0/a0,-(sp)     ;Gebruikte Regs
                lea     crn_int(pc),a0  ;Tool for fast access
                bclr    #5,$fffffa0f.w  ;Clear interrupt
                move.l  a0,$0134.w      ;Nxt Tmr A -> crn_int
crn_3:          move.b  #$99,d0         ;Load sample
                andi.w  #%1111,d0       ;Mask nibble
                move.b  decrunchtab(pc,d0.w),d0 ;Calculate offset
crn_5:          addi.b  #$99,d0         ;Add to last sample
                move.w  d0,crn_4+2-crn_int(a0) ;Save the new sample
crn_2:          cmpi.l  #$99999999,crn_1+2-crn_int(a0) ;Test end of sample file
                beq.s   crn_int_2       ;Yep, reinitialize variables
crn_int_5:      lsl.w   #4,d0           ;Make entry
                lea     table(pc,d0.w),a0 ;ptr to soundtable
                move.l  (a0)+,$ffff8800.w ;Reg A soundchip
                move.l  (a0)+,$ffff8800.w ;Reg B
                move.l  (a0)+,$ffff8800.w ;Reg C
                movem.l (sp)+,d0/a0
                rte

table:   	incbin	table.bin  

                section	DATA
freq:           DC.B 123,82,61,49,41,35,31

                section	BSS
memfree:        DS.L 1
memstrt:        DS.L 1
sam_rate:       DS.W 1
norm_crn:       DS.W 1
handle:         DS.W 1
old134:         DS.L 1
oldsr:          DS.W 1
old07:          DS.B 1
old09:          DS.B 1
old0b:          DS.B 1
old0f:          DS.B 1
old13:          DS.B 1
old19:          DS.B 1
old1f:          DS.B 1
cur_freq:       DS.B 1
                END
