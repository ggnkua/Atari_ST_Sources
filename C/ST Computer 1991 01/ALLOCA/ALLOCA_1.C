

/* alloca() reserviert Platz auf dem Stack    */
/* Die aufrufende Funktion darf keine Regist- */
/* ervariablen verwenden !                    */  

char *alloca(size)
  unsigned int size;
  
{ asm{  unlk    A6         /* link r�ckg�ngig */    
        move.l  (A7)+,A0   /* R�cksprungadr.  */

        move.w  (A7),D0
        suba.w  D0,A7      /* Platz machen    */
        
        move.l  A7,D0
        addq.l  #2,D0      /* Zeiger zur�ck   */
        
        jmp     (A0)       /* R�cksprung      */
     }
}


