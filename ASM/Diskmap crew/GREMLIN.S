 TEXT 
Begin:
061048  42A7                      CLR.L     -(A7)               
06104A  3F3C0020                  MOVE.W    #$20,-(A7)          
06104E  4E41                      TRAP      #1                  
061050  5C4F                      ADDQ.W    #6,A7               
061052  6108                      BSR.S     8(PC)                L0001
061054  31FC00708240              MOVE.W    #$70,-$7DC0.S       
06105A  60FE                L0000:BRA.S     -2(PC)               L0000
06105C  4BF88604            L0001:LEA       -$79FC.S,A5         
061060  610000DC                  BSR       220(PC)              L000F
061064  7205                      MOVEQ     #5,D1               
061066  610000E6                  BSR       230(PC)              L0011
06106A  7000                      MOVEQ     #0,D0               
06106C  610000A8                  BSR       168(PC)              L000D
061070  6136                      BSR.S     54(PC)               L0004
061072  6100008E                  BSR       142(PC)              L000C
061076  2F00                      MOVE.L    D0,-(A7)            
061078  610000C4                  BSR       196(PC)              L000F
06107C  704F                      MOVEQ     #$4F,D0             
06107E  61000096                  BSR       150(PC)              L000D
061082  6124                      BSR.S     36(PC)               L0004
061084  6100007C                  BSR       124(PC)              L000C
061088  9197                      SUB.L     D0,(A7)             
06108A  610000B2                  BSR       178(PC)              L000F
06108E  0C9F0000003C              CMPI.L    #$3C,(A7)+          
061094  6E0000EA                  BGT       234(PC)              L0013
061098  70FF                L0002:MOVEQ     #-1,D0              
06109A  31FC07008240        L0003:MOVE.W    #$700,-$7DC0.S      
0610A0  4E71                      NOP                           
0610A2  51C8FFF6                  DBF       D0,-10(PC)           L0003
0610A6  60F0                      BRA.S     -16(PC)              L0002
0610A8  6136                L0004:BSR.S     54(PC)               L0006
0610AA  610000C0                  BSR       192(PC)              L0012
0610AE  3B7C00900002              MOVE.W    #$90,2(A5)          
0610B4  3B7C01900002              MOVE.W    #$190,2(A5)         
0610BA  3B7C00900002              MOVE.W    #$90,2(A5)          
0610C0  6138                      BSR.S     56(PC)               L000A
0610C2  3ABC001F                  MOVE.W    #$1F,(A5)           
0610C6  6132                      BSR.S     50(PC)               L000A
0610C8  3B7C00800002              MOVE.W    #$80,2(A5)          
0610CE  612A                      BSR.S     42(PC)               L000A
0610D0  3ABC00E4                  MOVE.W    #$E4,(A5)           
0610D4  6124                      BSR.S     36(PC)               L000A
0610D6  08380005FA01        L0005:BTST      #5,-$5FF.S          
0610DC  66F8                      BNE.S     -8(PC)               L0005
0610DE  4E75                      RTS                           
0610E0  323C1F40            L0006:MOVE.W    #$1F40,D1           
0610E4  51C9FFFE            L0007:DBF       D1,-2(PC)            L0007
0610E8  4E75                      RTS                           
0610EA  3B7C00800002        L0008:MOVE.W    #$80,2(A5)          
0610F0  6108                      BSR.S     8(PC)                L000A
0610F2  3215                      MOVE.W    (A5),D1             
0610F4  6004                      BRA.S     4(PC)                L000A
0610F6  6102                L0009:BSR.S     2(PC)                L000A
0610F8  3A80                      MOVE.W    D0,(A5)             
0610FA  7824                L000A:MOVEQ     #$24,D4             
0610FC  51CCFFFE            L000B:DBF       D4,-2(PC)            L000B
061100  4E75                      RTS                           
061102  7000                L000C:MOVEQ     #0,D0               
061104  102D0005                  MOVE.B    5(A5),D0            
061108  4840                      SWAP      D0                  
06110A  102D0007                  MOVE.B    7(A5),D0            
06110E  E148                      LSL.W     #8,D0               
061110  102D0009                  MOVE.B    9(A5),D0            
061114  4E75                      RTS                           
061116  61C8                L000D:BSR.S     -56(PC)              L0006
061118  3B7C00860002              MOVE.W    #$86,2(A5)          
06111E  61D6                      BSR.S     -42(PC)              L0009
061120  7010                      MOVEQ     #$10,D0             
061122  3B7C00800002              MOVE.W    #$80,2(A5)          
061128  61CC                      BSR.S     -52(PC)              L0009
06112A  263C00060000              MOVE.L    #$60000,D3          
061130  5383                L000E:SUBQ.L    #1,D3               
061132  6700FF64                  BEQ       -156(PC)             L0002
061136  08380005FA01              BTST      #5,-$5FF.S          
06113C  66F2                      BNE.S     -14(PC)              L000E
06113E  303C0064            L000F:MOVE.W    #$64,D0             ;(#"d") 
061142  619C                L0010:BSR.S     -100(PC)             L0006
061144  51C8FFFC                  DBF       D0,-4(PC)            L0010
061148  6100FFA0                  BSR       -96(PC)              L0008
06114C  4E75                      RTS                           
06114E  40E7                L0011:MOVE      SR,-(A7)            
061150  007C0700                  ORI.W     #$700,SR            
061154  11FC000E8800              MOVE.B    #$E,-$7800.S        
06115A  10388800                  MOVE.B    -$7800.S,D0         
06115E  020000F8                  ANDI.B    #-8,D0              
061162  8001                      OR.B      D1,D0               
061164  11C08802                  MOVE.B    D0,-$77FE.S         
061168  46DF                      MOVE      (A7)+,SR            
06116A  4E75                      RTS                           
06116C  1B7C00000009        L0012:MOVE.B    #0,9(A5)            
061172  1B7C00800007              MOVE.B    #-$80,7(A5)         
061178  1B7C00070005              MOVE.B    #7,5(A5)            
06117E  4E75                      RTS                           
061180  7207                L0013:MOVEQ     #7,D1               
061182  6100FFCA                  BSR       -54(PC)              L0011
 END
