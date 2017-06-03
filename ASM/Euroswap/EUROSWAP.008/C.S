 TEXT 
Begin:
02D912  2A4F                      MOVEA.L A7,A5                 
02D914  4FF90002DC04              LEA     $0002DC04,A7           L0009
02D91A  2A6D0004                  MOVEA.L 4(A5),A5              
02D91E  202D000C                  MOVE.L  12(A5),D0             
02D922  D0AD0014                  ADD.L   20(A5),D0             
02D926  D0AD001C                  ADD.L   28(A5),D0             
02D92A  068000000100              ADDI.L  #$100,D0              
02D930  2F00                      MOVE.L  D0,-(A7)              
02D932  2F0D                      MOVE.L  A5,-(A7)              
02D934  3F3C0000                  MOVE.W  #0,-(A7)              
02D938  3F3C004A                  MOVE.W  #$4A,-(A7)            
02D93C  4E41                      TRAP    #1                    
02D93E  4FEF000C                  LEA     12(A7),A7             
02D942  42A7                      CLR.L   -(A7)                 
02D944  3F3C0020                  MOVE.W  #$20,-(A7)            
02D948  4E41                      TRAP    #1                    
02D94A  5C8F                      ADDQ.L  #6,A7                 
02D94C  23C00002DA00              MOVE.L  D0,$0002DA00           L0008
02D952  487900000000              PEA     $00000000.L           
02D958  487900000000              PEA     $00000000.L           
02D95E  48790002DC08              PEA     $0002DC08              L000A
02D964  3F3C0000                  MOVE.W  #0,-(A7)              
02D968  3F3C004B                  MOVE.W  #$4B,-(A7)            
02D96C  4E41                      TRAP    #1                    
02D96E  DFFC0000000E              ADDA.L  #$E,A7                
02D974  B07C0001                  CMP.W   #1,D0                 
02D978  6700000E                  BEQ     14(PC)                 L0001
02D97C  B07C0002                  CMP.W   #2,D0                 
02D980  67000022                  BEQ     34(PC)                 L0002
02D984  42A7                L0000:CLR.L   -(A7)                 
02D986  4E41                      TRAP    #1                    
02D988  6100004C            L0001:BSR     76(PC)                 L0004
02D98C  487900000000              PEA     $00000000.L           
02D992  487900000000              PEA     $00000000.L           
02D998  48790002D9E9              PEA     $0002D9E9              L0006
02D99E  4EF90002D9C0              JMP     $0002D9C0              L0003
02D9A4  61000030            L0002:BSR     48(PC)                 L0004
02D9A8  487900000000              PEA     $00000000.L           
02D9AE  487900000000              PEA     $00000000.L           
02D9B4  48790002D9F6              PEA     $0002D9F6              L0007
02D9BA  4EF90002D9C0              JMP     $0002D9C0              L0003
02D9C0  3F3C0000            L0003:MOVE.W  #0,-(A7)              
02D9C4  3F3C004B                  MOVE.W  #$4B,-(A7)            
02D9C8  4E41                      TRAP    #1                    
02D9CA  DFFC0000000E              ADDA.L  #$E,A7                
02D9D0  4EF90002D984              JMP     $0002D984              L0000
02D9D6  48790002D9E6        L0004:PEA     $0002D9E6              L0005
02D9DC  3F3C0009                  MOVE.W  #9,-(A7)              
02D9E0  4E41                      TRAP    #1                    
02D9E2  5C8F                      ADDQ.L  #6,A7                 
02D9E4  4E75                      RTS                           
02D9E6  1B4500              L0005:DC.B   $1B,'E',$00
02D9E9  6368696361676F342E  L0006:DC.B   'chicago4.'
02D9F2  65636800                  DC.B   'ech',$00
02D9F6  6D656E752E696D67    L0007:DC.B   'menu.img' 
02D9FE                            DS.W    1,0 
02DA00                      L0008:DS.W    258,0 
02DC04                      L0009:DS.W    2,0 
02DC08  746178692E706931    L000A:DC.B   'taxi.pi1' 
02DC10  0090                      DC.B   $00,$90
ZUEND: END
