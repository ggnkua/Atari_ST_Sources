  jsr    init 

main 
* interrupts off 
   move.w   sr,-(a7)         backup status register 
   or.w   #$0700,sr         disable interrupts 
   movem.l   d0-d7/a0-a6,-(a7)   backup registers 

* pause for a bit (nearly 15,000 clock cycles!) 
   move.w   #1064,d0 
pause: 
   nop 
   dbra   d0,pause 

* into 60 Hz 
   eor.b   #2,$ffff820a.w 
   rept   8 
   nop 
   endr 
* back into 50 Hz 
   eor.b   #2,$ffff820a.w 

* setup for border busting, 44 cycles total 
   move.w   #$8209,a3         8, low video  address pointer 
   lea   $ff8260,a1            12, resolution 
   moveq   #0,d0            4, clear d0 
   moveq   #16,d1            4, sync value 
   moveq   #%10,d3            4, high resolution / 60 hz 
   moveq   #%00,d4            4, low resolution / 50 hz 
   move.w   #$820a,a0         8, sync modus 
* end setup for border busting, 44 cycles total 

* sync processor 
.sync_wait 
   move.b   (a3),d0            see if updated 
   beq.s   .sync_wait         if not, loop 
   sub.w   d0,d1            sync value 
   lsl.w   d1,d0            now in sync 
* end sync 

   dcb.w   89,$4e71         368, wait for line to end 
   move.w   #$707,$ff8240 

   move.l   #227-1,d7         12, bust 227 left and right borders 
.main_bust    
* left border 
   move.b   d3,(a1)            8, into monochrome 
   move.b   d4,(a1)            8, into low resolution 
* end left border 
   dcb.w   90,$4e71         360, wait right border 
* right border 
   move.b   d4,(a0)            8, into 60 Hz 
   move.b   d3,(a0)            8, into 50 Hz 
   dcb.w   13,$4e71         52, wait for extra bust 
   move.b   d3,(a1)            8, into monochrome 
   move.b   d4,(a1)            8, into low resolution 
* end right border 
   dcb.w   10,$4e71         40, wait for end of line 
   dbf   d7,.main_bust         12, loop to bust more borders 

* final line, slightly different timings than in the loop 
* left border 
   move.b   d3,(a1)            8, into monochrome 
   move.b   d4,(a1)            8, into low resolution 
* end left border 
   dcb.w   89,$4e71         356, wait for right border 
* right border 
   move.b   d4,(a0)            8, into 60 Hz 
   move.b   d3,(a0)            8, into 50 Hz 
   dcb.w   13,$4e71         52, wait for extra bust 
   move.b   d3,(a1)            8, into monochrome 
   move.b   d4,(a1)            8, into low resolution 
* end right border 

   dcb.w   6,$4e71            24, wait for next line to begin 
* bottom border 
   move.b   d4,(a0)            8, into 60 Hz 
   move.b   d3,(a0)            8, into 50 Hz 
* end bottom border 


* bottom border left/right 

   move.l   #40-1,d7         12, bust 40 left and right borders, may vary slightly 
.bottom_bust 
* left border 
   move.b   d3,(a1)            8, into monochrome 
   move.b   d4,(a1)            8, into low resolution 
* end left border 
   dcb.w   90,$4e71         360, wait right border 
* right border 
   move.b   d4,(a0)            8, into 60 Hz 
   move.b   d3,(a0)            8, into 50 Hz 
   dcb.w   13,$4e71         52, wait for extra bust 
   move.b   d3,(a1)            8, into monochrome 
   move.b   d4,(a1)            8, into low resolution 
* end right border 
   dcb.w   10,$4e71         40, wait for next line to begin 
   dbf   d7,.bottom_bust         12, loop to bust more borders 

   move.w   #$777,$ff8240    

   movem.l   (a7)+,d0-7/a0-6 
   move.w   (a7)+,sr 
   rte 

init 
   jsr   initialise 
   move.b   $fffa15,mask_b      backup mask b 
   bclr   #5,$fffa15         disable timer c 

   move.l   #screen,d0         load screen memory 
   add.l   #256,d0 
   clr.b   d0               for boundary reasons 
   move.l   d0,a0            for junk filling below 
    
   clr.b   $ffff820d         clear STe extra bit 
   lsr.l   #8,d0 
   move.b   d0,$ffff8203      put in mid screen address byte 
   lsr.w   #8,d0 
   move.b   d0,$ffff8201      put in high screen address byte 
    
   move.l   #62000/4,d0         fill entire screen with junk 
fill 
   move.l   #$88888888,(a0)+   put in junk 
   dbf   d0,fill 

   move.l   $70,-(a7)         backup $70 
   move.l   #main,$70         start main routine 

   move.w   #7,-(a7) 
   trap   #1 
   addq.l   #2,a7            wait keypress 

   move.l   (a7)+,$70         restore $70 
   move.b   mask_b,$fffa15      restore mask b 
   jsr   restore 

   clr.w   -(a7) 
   trap   #1               exit 


   include   initlib.s 

   section data 
mask_b   dc.b   0            mask b backup 

   section   bss 
screen   ds.l   62020/4         yep, a biiiig screen

