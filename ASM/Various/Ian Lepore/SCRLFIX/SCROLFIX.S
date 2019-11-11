;**************************************************************************
;* SCROLFIX.S - A DA that fixes the double-scroll bug in TOS 1.04 and up.
;*
;*  This is similar to Charles Johnson's BUTTONFIX accessory, except that
;*  a timer event is used to recycle the evnt_multi() loop 3 seconds 
;*  after an AC_CLOSE message comes in.  This apparently fixes the glitch
;*  on TT machines where you'd have to open the BUTTONFIX accessory 
;*  before it would fix the double-scroll within each application.
;*
;*  This code is written for the MadMac assembler, use the -p option.
;**************************************************************************

          .text
          
          lea       localstk,sp         ; load local stack pointer
          
          move.l    #aespb,d3           ; registerize things we use a lot...
          lea       control,a3
          lea       intin,a4
          lea       adrin,a5
          lea       msgbuf,a6
          
          move.l    #$0a000100,d0       ; func $0a (appl_init)
          bsr.s     aescall             ; do it.
          
          move.w    4(a5),(a4)          ; move ap_id from intout to intin
          move.l    #menustr,(a5)       ; store menu string ptr in adrin
          move.l    #$23010101,d0       ; func $23 (menu_register)
          bsr.s     aescall             ; do it.
          
restart:
          move.l    a6,(a5)             ; store msgbuf ptr in adrin.
          move.w    #$32,(a4)           ; mflags=MU_MESAG|MU_TIMER|MU_BUTTON
mainloop:
          move.l    #$19100701,d0       ; func $19 (evnt_multi).
          bsr.s     aescall             ; do it.
          and.w     #$FFDF,(a4)         ; turn off MU_TIMER bit in flags.
          btst.b    #4,5(a5)            ; is MU_MESAG bit set in mwhich?
          beq.s     mainloop            ; nope, go wait some more.

          cmp.w     #41,(a6)            ; msg = AC_CLOSE?
          beq.s     restart             ; yep, go set MU_TIMER back on.
          cmp.w     #40,(a6)            ; msg = AC_OPEN?
          bne.s     mainloop            ; nope, just ignore it and loop.
          
          move.w    #1,(a4)             ; set intin to 1 (default button)
          move.l    #hellostr,(a5)      ; set pointer to alert string
          move.l    #$34010101,d0       ; func $34 (form_alert)
          bsr.s     aescall             ; do it.
          bra       restart             ; and restart main loop.

aescall:
          movep.l   d0,1(a3)            ; propogate d0 into control array
          move.l    d3,d1               ; move aespb pointer to parm reg
          move.w    #200,d0             ; load aes function code in parm reg
          trap      #2                  ; call aes
          rts                           ; return

          .bss
          
global:   .ds.w     15
control:  .ds.w     5
msgbuf:   .ds.w     8
adrin:    .ds.l     1
intout:   .ds.w     8                   ; intout must be at adrin+4!

          .ds.w     128                 ; little bitty 256-byte stack, just
localstk  =         *                   ; enough for AES to save a few regs.

          .data
          
intin:    .dc.w     0                   ; mflags
          .dc.w     2,1,1               ; mbclicks, mbmask, mbstate
          .dc.w     0,0,0,0,0           ; mouse watch 1
          .dc.w     0,0,0,0,0           ; mouse watch 2
          .dc.w     3000,0              ; timer low, high
          
aespb:    .dc.l     control, global, intin, intout, adrin, 0   

menustr:  .dc.b     "  Scroll Fixer",0

hellostr: .dc.b     "[0]["
          .dc.b     " Double-scroll fixer   |"
          .dc.b     " |"
          .dc.b     " Public Domain 03/92   |"
          .dc.b     "    By Ian Lepore |"
          .dc.b     " ][ Continue ]"
          .dc.b     0
          
          .end
