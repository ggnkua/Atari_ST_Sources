;
; Musique-interruption avec Dosound (XBIOS, Nr. 32)
; Assembleur         	SOUND4.S
;

gemdos         = 1
xbios          = 14
dosound        = 32


               SECTION TEXT 

               pea        data
               move.w     #dosound,-(sp)
               trap       #xbios
               addq.l     #6,sp

               clr.w      -(sp)
               trap       #gemdos


               SECTION DATA 

data:          DC.b 0,0,1,0,2,0,3,0,4,0,5,0
               DC.b 8,16,9,16,10,0
               DC.b 13,1,11,64,12,31
               DC.b 7,252

               DC.b 0,222,1,1,255,16
               DC.b 0,170,13,1,255,16
               DC.b 0,123,2,222,3,1,13,1,255,32
               DC.b 13,1,255,46
               DC.b 0,102,2,170,13,1,255,16
               DC.b 0,28,2,123,13,1,255,24
               DC.b 0,63,13,1,255,8
               DC.b 13,1,255,32
               DC.b 0,123,2,222,13,1,255,16
               DC.b 0,63,2,123,13,1,255,16
               DC.b 2,170,13,1,255,24
               DC.b 0,102,13,1,255,8
               DC.b 13,1,255,32
               DC.b 0,63,2,250,13,1,255,16
               DC.b 0,102,2,0,3,0,13,1,255,16
               DC.b 0,123,2,222,3,1,13,1,255,64

               DC.b 0,0,1,0,2,0,3,0,4,0,5,0,7,255,8,15,9,15,10,15
               DC.b 255,0

               END 
