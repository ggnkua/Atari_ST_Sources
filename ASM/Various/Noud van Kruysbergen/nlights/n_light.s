****************************************************************************
*                                                                          *
* N_LIGHT.S 1.1 06/01/91 (C) Noud van Kruysbergen                          *
*                                                                          *
* This program install a new Rwabs vector and shows non-floppy disk        *
* activity by switching the floppy drive A light on.                       *
*                                                                          *
****************************************************************************
          text

          bra       install             ; goto install

          dc.b      "XBRA"              ; XBRA protocol
          dc.b      "NFL1"              ; XBRA id
oldrwabs: dc.l      0                   ; room for old Rwabs vector
newrwabs: cmpi.w    #2,14(a7)           ; if (device<2)
          bmi       sysrwabs            ;   goto oldvector
          tst.w     $43e                ; if (DMA not active)
          bne       sysrwabs            ;   goto oldvector
          lea       $ff8800,a0
          move.b    #14,(a0)            ; read PSG register
          move.b    (a0),d1
          andi.b    #$fd,d1             ; clear drive A (-> light on)
          move.b    d1,2(a0)            ; write PSG register
          move.l    (a7)+,quit+2        ; return adress to quit
          pea       retrwabs            ; new return adress on stack
sysrwabs: jmp       0.l                 ; goto oldvector
retrwabs: lea       $ff8800,a0
          move.b    #14,(a0)
          move.b    (a0),d1             ; read PSG register
          ori.b     #2,d1               ; set drive A (-> light off)
          move.b    d1,2(a0)            ; write PSG register
quit:     jmp       0.l                 ; goto returnvector

install:  move.l    #alert,addr_in
          move.w    #2,int_in           ; button 2 ('Quit')
          lea       contrl,a0           ; contrl[0]=34
          move.l    #$00340001,(a0)+    ; contrl[1]=contrl[2]=
          move.l    #$00010001,(a0)+    ; contrl[3]=1
          clr.w     (a0)                ; contrl[4]=0

          move.l    #aespb,d1
          move.w    #200,d0
          trap      #2                  ; form_alert(1,alert)
          move.w    int_out,d7          ; if (not GEM)
          beq       do_it               ;   install (started from AUTOfolder)
          cmp.w     #1,d7               ; if (button=2)
          bne       inst_quit           ;   quit

do_it:    pea       newrout             ; install new Rwabs vector
          move.w    #38,-(a7)
          trap      #14                 ; Supexec(newrout)
          addq.w    #6,a7
          tst.w     d7                  ; if started from AUTO folder
          bne       inst_quit           ;   show message

          move.l    #yestext,-(a7)
          move.w    #9,-(a7)
          trap      #1                  ; Cconws(yestext)
          addq.w    #6,a7

inst_quit:clr.w     -(a7)
          move.l    #$15c,-(a7)         ; $100 basepage + $5c code
          move.w    #49,-(a7)
          trap      #1                  ; Ptermres($15c,0)

newrout:  move.l    $476,oldrwabs       ; old rwabs vector in XBRA
          move.l    $476,sysrwabs+2     ; old rwabs return vector
          move.l    #newrwabs,$476      ; install new Rwabs vector
          rts

          data

alert:    dc.b      "[0][  N_LIGHT 1.1 06/01/91| |(C) Noud van Kruysbergen|"
          dc.b      "kruysbergen@psych.kun.nl |][ Install |Quit]",0
yestext:  dc.b      13,10
          dc.b      ' ',27,'p',"   N_LIGHT 1.1 06/01/91   ",27,'q',13,10
          dc.b      ' ',27,'p'," (C) Noud van Kruysbergen ",27,'q',13,10,0
          align
aespb:    dc.l      contrl,global,int_in,int_out,addr_in,addr_out

          bss

contrl:   ds.w      5
global:   ds.w      1
int_in:   ds.w      1
int_out:  ds.w      1
addr_in:  ds.l      1
addr_out: ds.l      1

          end

