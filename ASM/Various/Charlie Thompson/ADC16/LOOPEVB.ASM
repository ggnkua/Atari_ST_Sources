
;************************************************************
; file:loopevb.asm                                          *
;                                                           *
; Simple read ADC write DAC loop...                         *
; reads DSP56ADC16 data and writes to PCM-56                  *
;                                                           *
;************************************************************
; Written by Charlie Thompson 10/19/88 -- Rev 1.0 11/1/88
        
        opt     nomd,nocex,nocm,nomex   

        page 132

; Program start address

     org     p:$40

; Set up ADS board in case of force break instead of force reset

                movep #0,x:$FFFE        ;set bcr to zero
                movec #0,sp             ;init stack pointer
                movec #0,sr             ;clear loop flag

; Set up the SSI for operation with the DSP56ADC16EVB
; The following code sets port C to function as SCI/SSI

                move #$0,a0             ;zero PCC to cycle it
                movep a0,x:$FFE1
                
                move #$0001ff,a0
                movep a0,x:$FFE1        ;write PCC
                
; The following code sets the SSI CRA and CRB control registers for external
; continuous clock, synchronous, normal mode.

                move #$004000,a0        ;CRA pattern for word length=16 bits
                movep a0,x:$FFEC

                move #$003200,a0    ;CRB pattern for continous ck,sych,normal mode
                movep a0,x:$FFED    ;word long frame sync: FSL=0;ext ck/fs 



;************************************************************************
; Actual read A/D and write D/A -- insert application code as indicated *
;************************************************************************

; The following code polls the RDF flag in the SSI-SR and waits for RDF=1
; and then reads the RX register to retrieve the data from the A/D converter.
; Sample rate is controlled by DSP56ADC16 board.   




poll            jclr #7,x:$FFEE,poll    ;loop until RDF bit = 1
                movep x:$FFEF,a         ;get A/D converter data

 
; Write DSP56ADC16 A/D converter data to the PCM-56

                move a,x:$FFEF          ;write the PCM-56 D/A via SSI xmt reg.
                jmp poll                        ;loop indefinitely

                end
