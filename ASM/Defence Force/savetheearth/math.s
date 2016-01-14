

enable_sqrt	equ 0

 SECTION TEXT
 
 even 
 
; ****************************************************************** *
; **** Tiny square-root-table generator ****** (c) gREY in 1997 **** *
; ****** For the first official #amycoders coding competition ****** *
; *** Developed in 5 minutes while watching ST:TNG "Half a life" *** *
; ****************************************************************** *

 ifne enable_sqrt
ComputeSqrtTable
 lea     table_sqrt,a0   ; load adress of table
 moveq   #0,d0           ; clear d0 (start vlaue = 0)
.outer
 move.w  d0,d1           ; save d0
 add.w   d1,d1           ; Multiply d1 with 2
                         ; dbra below saves us from adding 1!
.inner
 move.b  d0,(a0)+        ; fill sqrttab
 dbra    d1,.inner       ; as many times as needed

 addq.b  #1,d0           ; increase d0 by 1
 bcc.s   .outer          ; as long as d0 =<255! 
 rts  
 endc
    

; RND(n), 32 bit Galois version. make n=0 for 19th next number in
; sequence or n<>0 to get 19th next number in sequence after seed n.	
; This version of the PRNG uses the Galois method and a sample of
; 65536 bytes produced gives the following values.
;
; Entropy = 7.997442 bits per byte
; Optimum compression would reduce these 65536 bytes by 0 percent
;
; Chi square distribution for 65536 samples is 232.01, and
; randomly would exceed this value 75.00 percent of the time
;
; Arithmetic mean value of data bytes is 127.6724, 127.5 = random
; Monte Carlo value for Pi is 3.122871269, error 0.60 percent
; Serial correlation coefficient is -0.000370, uncorrelated = 0.0
;
; Uses d0/d1/d2
NextPRN
 moveq #$AF-$100,d1		; set EOR value
 moveq #18,d2			; do this 19 times
 move.l Prng32,d0		; get current 
.ninc0
 add.l d0,d0			; shift left 1 bit
 bcc.s .ninc1			; branch if bit 32 not set

 eor.b d1,d0			; do galois LFSR feedback
.ninc1
 dbra d2,.ninc0			; loop

 move.l	d0,Prng32		; save back to seed word
 RTS

Prng32
 dc.l $12345678			; random number store
  
 
     
 even 

 SECTION DATA
 
 even
 
sine_255				; 16 bits, unsigned between 00 and 127
 incbin "sine_255.bin"
 incbin "sine_255.bin"

table_sine_16			; 16 bits, signed between -32767 and +32767
 incbin "sine_16b.bin"
 incbin "sine_16b.bin"
 incbin "sine_16b.bin"
 
 even


 SECTION BSS
 
 even
  
 ifne enable_sqrt
table_sqrt					ds.b 65536			; 65536 values (255^2)
 endc
  
 even
