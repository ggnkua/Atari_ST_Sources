* GDOS.S
* This program outputs a rounded rectangle to a printer.

*HEADER
       move.l  a7,a5
       move.l  #ustk,a7
       move.l  4(a5),a5
       move.l  12(a5),d0
       add.l   20(a5),d0
       add.l   28(a5),d0
       add.l   #$100,d0
       move.l  d0,-(sp)
       move.l  a5,-(sp)
       clr.w   -(sp)
       move    #$4a,-(sp)
       trap    #1
       add.l   #12,sp

* appl_intit()
       move.l  #appl_init,aespb
       jsr     aes            ; call AES 

* get current screen resolution
       move.w  #4,-(sp)
       trap    #14
       addq.l  #2,sp
       move.w  d0,res

* is gdos present
       moveq   #-2,d0
       trap    #2
       addq    #2,d0
       beq     quit
       move    res,d0
       add     #2,d0
       move    d0,intin
* if no GDOS should not continue
       
* graf_handle
       move    #77,contrl
       move    #0,contrl+2
       move    #5,contrl+4
       move    #0,contrl+6
       move    #0,contrl+8
       jsr     aes
       move    intout,gr_handle

* v_opnvwk
* start by opening a virtual  workstation
       move    #100,contrl
       move    #0,contrl+2
       move    #11,contrl+6
       move    gr_handle,contrl+12
       move    #1,intin+2      
       move    #1,intin+4      
       move    #1,intin+6      
       move    #1,intin+8
       move    #1,intin+10     
       move    #1,intin+12     
       move    #1,intin+14     
       move    #1,intin+16     
       move    #1,intin+18     
       move    #2,intin+20     
       jsr     vdi
       move.w  contrl+12,ws_handle

* v_opnwk
* open printer
       move    #1,contrl
       move    #0,contrl+2
       move    #11,contrl+6    
       move    ws_handle,contrl+12   
       move    #21,intin               ; fx80 driver
       move    #1,intin+2      
       move    #1,intin+4      
       move    #1,intin+6
       move    #1,intout+8     
       move    #1,intin+10     
       move    #1,intin+12     
       move    #1,intin+14     
       move    #1,intin+16     
       move    #1,intin+18     
       move    #2,intin+20     
       jsr     vdi
       move.w  contrl+12,p_handle      ; printer handle

*to see if there is there a driver, test d0, if zero no driver

* output rounded rectangle
       move    #11,contrl
       move    #2,contrl+2
       move    #0,contrl+6     
       move    p_handle,contrl+12
       move    #8,contrl+10    ; function 8
       move    #100,ptsin      ; x coord printer
       move    #50,ptsin+2     ; y coord printer
       move    #100+60,ptsin+4 ; x coord right edge
       move    #50+40,ptsin+6  ; y coord bottom edge
       jsr     vdi     


* update workstation- actually print
* v_updwk
       move    #4,contrl
       move.w  #0,contrl+2
       move.w  #0,contrl+6
       move.w  p_handle,contrl+12      
       jsr     vdi

* v_clswk
*  close the workstation (printer)
       move    #2,contrl
       clr.w   contrl+2
       clr.w   contrl+6
       move.w  p_handle,contrl+12              
       jsr     vdi

* v_clsvwk
*  close the virtual workstation
       move    #101,contrl
       clr.w   contrl+2
       clr.w   contrl+6
       move.w  ws_handle,contrl+12             
       jsr     vdi

quit:

* appl_exit()
       move.l    #appl_exit,aespb
       bsr       aes            ; call AES 

       move    #1,-(sp)
       move    #$4c,-(sp)
       trap    #1

aes:
       movem.l d0-d7/a0-a6,-(sp)
       move.l  #aespb,d1
       move.w  #$c8,d0
       trap    #2
       movem.l (sp)+,d0-d7/a0-a6
       rts
vdi:
       movem.l d0-d7/a0-a6,-(sp)
       move.l  #vdipb,d1
       moveq.l #$73,d0
       trap    #2
       movem.l (sp)+,d0-d7/a0-a6
       rts
       
       ds.l    100
ustk:  ds.l    1

contrl: ds.w    128
intin:  ds.w    128
intout: ds.w    128
global: ds.w    128
addrin: ds.w    128
addrout:        ds.w    128
ptsin:  ds.w    128
ptsout: ds.w    128

aespb: dc.l    contrl,global,intin,intout,addrin,addrout
vdipb: dc.l    contrl,intin,ptsin,intout,ptsout
p_handle:      ds.w    1
gr_handle:     ds.w    1
ws_handle:     ds.w    1
res:           ds.w    1
appl_init:     dc.w     10,0,1,0,0
appl_exit:     dc.w     19,0,1,0,0

