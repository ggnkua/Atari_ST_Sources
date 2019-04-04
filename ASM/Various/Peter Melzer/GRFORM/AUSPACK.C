/* STAD-picture conversion by Peter Melzer, modified for Megamax C St.Herzer */
/* in buff muss sich das vorher geladene komprimierte Bild befinden */
/* screen ist der Ausgabebildschirm                                 */

decode_stad(buff, screen)
register char *buff, *screen;
{
   asm
   {
        ; von buff nach screen auspacken
        movem.l D1-D7/A2-A6, -(A7)
        movea.l screen, A1
        
        cmpi.l  #0x704D3836L, (buff)    ; pM86
        bne     dchoriz
         ; vertikal auspacken 
        addq.l  #4, buff
        move.b  (buff)+, D4
        clr.w   D6
        move.b  (buff)+, D6
        move.b  (buff)+, D5
        move.l  #32000, D2              ; z„hler
        move.w  #400, D3                ; zeilen
dcvrl0:
        clr.w   D7                      ; kritisch da z„hler
        move.b  (buff)+, D0               
        cmp.b   D4, D0
        bne     dcvr1
        move.b  D6, D1
        move.b  (buff)+, D7
        bra     dcvrloop
dcvr1:
        cmp.b   D5, D0
        beq     dcvr2
        move.b  D0, (A1)
        clr.w   D7
        bra     dcvrall
dcvr2:
        move.b  (buff)+, D1
        bne     dcvr3
        tst.b   (buff)
        beq     dcvrfin                 ; D5 byte mit 2 nullen
dcvr3:
        move.b  (buff)+, D7
dcvrloop:
        move.b  D1, (A1)
dcvrall:
        subq.w  #1, D2
        bmi     dcvrfin
        lea     80(A1), A1
        subq.w  #1, D3
        bne     dcvr0
        move.w  #400, D3
        movea.l screen, A1
        addq.l  #1, A1
        movea.l A1, screen
dcvr0:
        dbf     D7, dcvrloop
        bra     dcvrl0    
        
        ; horizontal auspacken
dchoriz:
        cmpi.l  #0x704D3835L, (buff)    ; pM85
        bne     dcvrerr                 ; kein STAD-Format
        addq.l  #4, buff
        move.b  (buff)+, D4
        clr.w   D6
        move.b  (buff)+, D6
        move.b  (buff)+, D5
        move.l  #32000, D2
dchrl0:
        clr.w   D7                      ; kritisch da z„hler
        move.b  (buff)+, D0               
        cmp.b   D4, D0
        bne     dchr1
        move.b  D6, D1
        move.b  (buff)+, D7
        bra     dchrloop
dchr1:
        cmp.b   D5, D0
        beq     dchr2
        move.b  D0, (A1)+               ; orig. byte
        subq.w  #1, D2
        bmi     dcvrfin
        bra     dchrl0
dchr2:
        move.b  (buff)+, D1
        bne     dchr3
        tst.b   (buff)
        beq     dcvrfin                 ; ende w.o. D5 byte mit 2 nullen
dchr3:
        move.b  (buff)+, D7
dchrloop:
        move.b  D1, (A1)+
        subq.w  #1, D2
        bmi     dcvrfin
        dbf     D7, dchrloop
        bra     dchrl0     
dcvrfin:
        clr.w   D0                      ; ohne fehler 
dcvrerr:
        movem.l (A7)+, D1-D7/A2-A6
   }       
}
