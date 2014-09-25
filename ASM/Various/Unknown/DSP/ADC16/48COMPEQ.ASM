;; 48 KHz sin(x)/x compensation coefficients.  This is a lowpass
;; equiripple FIR filter with a 5 dB stopband. (The stopband is
;; essentially irrelevant).  Passband cutoff is 22.0 KHz and Stopband 
;; cutoff is 23.999 KHz and Passband Ripple is .01 dB.

;; Created by Charlie Thompson using FDAS 9/21/88 Rev 0.0 -

        opt     nocex,nocm

filtcoeff macro

       dc    $0015A4        ;b(   0)=  .00066042
       dc    $FFE75C        ;b(   1)= -.00075197
       dc    $002631        ;b(   2)=  .00116551
       dc    $FFC7CD        ;b(   3)= -.00171506
       dc    $004F99        ;b(   4)=  .00242913
       dc    $FF9292        ;b(   5)= -.00333953
       dc    $0092C7        ;b(   6)=  .00447929
       dc    $FF3F0A        ;b(   7)= -.00588870
       dc    $00F95E        ;b(   8)=  .00761008
       dc    $FEC252        ;b(   9)= -.00969481
       dc    $018FCB        ;b(  10)=  .01220071
       dc    $FE0DFE        ;b(  11)= -.01519799
       dc    $02672A        ;b(  12)=  .01877332
       dc    $FD0D1D        ;b(  13)= -.02303731
       dc    $039A07        ;b(  14)=  .02813804
       dc    $FB9CB9        ;b(  15)= -.03427970
       dc    $05585B        ;b(  16)=  .04175889
       dc    $F97801        ;b(  17)= -.05102527
       dc    $0809DD        ;b(  18)=  .06280100
       dc    $F5F986        ;b(  19)= -.07832265
       dc    $0CC944        ;b(  20)=  .09989214
       dc    $EF107F        ;b(  21)= -.13230908
       dc    $17FC48        ;b(  22)=  .18738651
       dc    $D92FD2        ;b(  23)= -.30322814
       dc    $5882E9        ;b(  24)=  .69149506
       dc    $5882E9        ;b(  25)=  .69149506
       dc    $D92FD2        ;b(  26)= -.30322814
       dc    $17FC48        ;b(  27)=  .18738651
       dc    $EF107F        ;b(  28)= -.13230908
       dc    $0CC944        ;b(  29)=  .09989214
       dc    $F5F986        ;b(  30)= -.07832265
       dc    $0809DD        ;b(  31)=  .06280100
       dc    $F97801        ;b(  32)= -.05102527
       dc    $05585B        ;b(  33)=  .04175889
       dc    $FB9CB9        ;b(  34)= -.03427970
       dc    $039A07        ;b(  35)=  .02813804
       dc    $FD0D1D        ;b(  36)= -.02303731
       dc    $02672A        ;b(  37)=  .01877332
       dc    $FE0DFE        ;b(  38)= -.01519799
       dc    $018FCB        ;b(  39)=  .01220071
       dc    $FEC252        ;b(  40)= -.00969481
       dc    $00F95E        ;b(  41)=  .00761008
       dc    $FF3F0A        ;b(  42)= -.00588870
       dc    $0092C7        ;b(  43)=  .00447929
       dc    $FF9292        ;b(  44)= -.00333953
       dc    $004F99        ;b(  45)=  .00242913
       dc    $FFC7CD        ;b(  46)= -.00171506
       dc    $002631        ;b(  47)=  .00116551
       dc    $FFE75C        ;b(  48)= -.00075197
       dc    $0015A4        ;b(  49)=  .00066042

        endm
