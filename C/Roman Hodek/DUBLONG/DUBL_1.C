/* Implementierung der essentiellen Funktionen*/
/* fÅr 'double longs', d.h. vorzeichenbehaf-  */
/* tete 64-Bit-Zahlen                         */

/* (c) 1991 MAXON Computer                    */
/* by Roman Hodek                             */

/* FunktionsÅbersicht :                       */
/* dl_todl()   : erweitert long zu dublong    */
/* dl_tolong() : verwandelt dublong in long;  */
/*               wenn der Zahlenbereich von   */
/*               long Åberschritten ist, ist  */
/*               das Ergebnis ohne Aussage    */
/* dl_neg()    : negiert eine dublong         */
/* dl_add()    : addiert : dl = dl+dl         */
/* dl_sub()    : subtrahiert : dl = dl-dl     */
/* dl_mul()    : multipliziert : dl = l*l     */
/* dl_mul2()   : multipliziert : dl = dl * dl */
/* dl_div()    : dividiert : l = dl/l und     */
/*                           l = dl%l         */
/* atodl()     : liest ein dublong aus einem  */
/*               String                       */

/* Alle Funktionen, die ihr dublong-Ergebnis  */
/* Åber einen Zeiger ablegen, liefern diesen  */
/* Zeiger auch als RÅckgabewert.              */ 

/* die dublong-Struktur :                     */
typedef struct {
  long high,low;
} dublong;

/* Grenzwerte des Typs dublong :              */
#define DLONG_BIT  64
#define DLONG_MIN  -9.223372037e18        
#define DLONG_MAX  9.223372037e18

#ifndef abs
#define abs(x) ( ((x)<0) ? -(x) : (x) ) 
#endif


/* erweitert l auf 64 Bit und weist es dl zu  */

dublong *dl_todl( l, dl )    
  dublong *dl;
  long    l;

{ dl->low = l;
  dl->high = ( l >=0 ) ? 0 : -1;
  return( dl );
}

/* wandelt dublong 'dl' in long */ 

long dl_tolong( dl )   
  dublong dl;
  
{ return( dl.low ); }

/* negativiert 'op' ( = monadisches Minus )   */ 

dublong *dl_neg( op )     
  dublong *op;
  
{ dublong *dl_add();

  /* beide HÑlften negieren */
  op->low = ~op->low; op->high = ~op->high; 
  /* + 1 wegen Zweierkomplement */
  dl_add( 0L, 1L, op->high, op->low, op );  
  return( op );
}

/* addiert die dublongs 'op1' und 'op2', Er-  */
/* gebnis nach 'erg'                          */
/*                    *erg = op1 + op2        */

dublong *dl_add( op1, op2, erg )   
  dublong op1, op2, *erg;    
  
{ asm { move.l   erg(A6),A0    

        move.l   op1+4(A6),D0 ; Low's addieren
        add.l    op2+4(A6),D0
        move.l   D0,4(A0)
        
        move.l   op1(A6),D0   ; High's mit öber-
        move.l   op2(A6),D1   ; trag addieren
        addx.l   D1,D0
        move.l   D0,(A0)
  }
  return( erg );
}

/* Subtrahiert dublong 'op2' von dublong 'op2'*/
/* Ergebnis nach 'erg'                        */
/*                      *erg = op1 - op2      */

dublong *dl_sub( op1, op2, erg )   
  dublong op1, op2, *erg;
  
{ asm { move.l   erg(A6),A0
 
        move.l   op1+4(A6),D0 ; Low's subtra-
        sub.l    op2+4(A6),D0 ; hieren
        move.l   D0,4(A0)
        
        move.l   op1(A6),D0   ; High's mit öber-
        move.l   op2(A6),D1   ; trag subtrahie-
        subx.l   D1,D0        ; ren
        move.l   D0,(A0)
  }
  return( erg );
}

/* Multipliziert zwei longs zu einem dublong  */
/*             *erg = op1 * op2               */

dublong *dl_mul( op1, op2, erg )
  long    op1, op2;
  dublong *erg;

{ register int negflag;
  
  /* negflag zeigt an, ob das Ergebnis        */
  /* negativ ist                              */
  negflag = ( (op1>0) ^ (op2>0) );
  
  /* beide Faktoren positiv machen            */ 
  op1 = abs(op1); op2 = abs(op2);
  
  /* Registerbelegung :                       */
  /* d1 : hîchstwertigstes Wort des Ergebnis- */
  /*      ses                                 */
  /* d2 : immer 0, zum addieren des öbertrags */
  
  asm { move.l    erg(A6),A0
        clr.w     D2

        move.w    op1+2(A6),D0 ; Low 1 *
        mulu      op2+2(A6),D0 ; Low 2 
        move.l    D0,4(A0)

        move.w    op1(A6),D0   ; High 1 *
        mulu      op2(A6),D0   ; High 2
        move.l    D0,(A0)
        
        move.w    (A0),D1      ; hîchstes Wort
        
        move.w    op1+2(A6),D0 ; Low 1 *
        mulu      op2(A6),D0   ; High 2
        add.l     D0,2(A0)     ; addieren
        addx.w    D2,D1        ; öbertag add.
        
        move.w    op1(A6),D0   ; High 1 *
        mulu      op2+2(A6),D0 ; Low 2
        add.l     D0,2(A0)     ; addieren
        addx.w    D2,D1        ; öbertrag add.
        
        move.w    D1,(A0)      ; hîchstes Wort
  }                            /* zurÅckschreiben */
  
  /* Vorzeichen des Ergebnisses berichtigen   */
  if (negflag) dl_neg( erg );
  
  return( erg );
}     
           
/* Multipliziert 2 dublong's zu einem dublong */
/* öberschreitet das Ergebnis den Zahlenbe-   */
/* reich, ist das Ergebnis ohne Aussage !     */
/*             *erg = op1 * op2               */

dublong *dl_mul2( op1, op2, erg )
  dublong op1, op2, *erg;
  
{ register long work1, work2, counter;
  /* 3 Registervariablen reservieren (d5-d7)  */
  register int negflag = 0;
           
  /* negflag zeigt an, ob das Ergebnis nega-  */
  /* ti ist; beide Operatoren  werden posi-   */
  /* tiv gemacht                              */
  if ( op1.high<0 ) { dl_neg( &op1 ); negflag ^= 1; }
  if ( op2.high<0 ) { dl_neg( &op2 ); negflag ^= 1; }
  
  /* Registerbelegung :                       */
  /* d0/d1 : Multiplikand                     */
  /* d1/d2 : Multiplikator (wird geschoben)   */
  /* d5    : BitzÑhler                        */
  /* d6/d7 : Ergebnis                         */
  
  asm{  move.l op1(A6),D0   ; Register laden
        move.l op1+4(A6),D1
        move.l op2(A6),D2
        move.l op2+4(A6),D3
        clr.l  D6  ; Ergebnis auf 0 initialis. 
        clr.l  D7
  
        moveq  #63,D5  ; 64 Bits mal
        
loop:   lsl.l  #1,D3   ; Multiplikator schieben
        roxl.l #1,D2
        bcc    no_add  
                       ; wenn herausgeschobenes
        add.l  D1,D7   ; Bit = 1, Multiplikand
        addx.l D0,D6   ; zum Eregbnis addieren
        
no_add: lsl.l  #1,D7   ; Ergebnis schieben ->
        roxl.l #1,D6   ; erg *= 2
        
        dbf    D5,loop
  
        movea.l erg(A6),A0 ; Ergebnis ablegen
        move.l  D6,(A0)
        move.l  D7,4(A0)
  }
  /* Vorzeichen des Ergebnisses berichtigen   */
  if (negflag) dl_neg( erg );
  
  return( erg );
}     

/* dividiert dublong 'op1' durch long 'op2'   */
/* Quotient in long 'erg', Rest in 'rest'     */

long dl_div( op1, op2, rest )   
  long    op2, *rest;     
  dublong op1;               
  
{ register long divisor, save_ccr; 
  /* 2 Registervar. reservieren (d6 und d7) */
  register int  negflag;
  
  /* Divison durch 0 -> Exception auslîsen */       
  if (op2==0) asm{ divu #0,D0 }  
  
  /* negflag zeigt an, ob das Eregbnis nega-  */
  /* tiv wird                                 */
  negflag = ((op1.high>=0) ^ (op2>0));
  
  /* beide Operanden positiv machen           */  
  op2 = abs(op2);
  if ( op1.high<0 ) dl_neg( &op1 );

  /* Registerbelegung :               */
  /* d0/d1 : Dividend                 */
  /* d2    : BitzÑhler                */
  /* d3    : Ergebnis                 */
  /* d6    : Zwischenspeicher fÅr CCR */
  /* d7    : Divisor                  */  
  
  asm{  move.l    op1(A6),D0    ; Register laden
        move.l    op1+4(A6),D1  
        move.l    op2(A6),divisor    
        moveq     #31,D2        
        
        sub.l     divisor,D0   ; Subtrk. vorab
        move      SR,save_ccr
        bchg      #4,save_ccr
loop:     
        move      save_ccr,CCR ; X-Flag ins Erg.
        roxl.l    #1,D3        ; schieben   
        lsl.l     #1,D1        ; Dividend rot-
        roxl.l    #1,D0        ; tieren
        
        btst      #4,save_ccr  
        beq       _add
        sub.l     divisor,D0   ; wenn X = 1
        move      SR,save_ccr  ; Dvsr von Dvnd
        bchg      #4,save_ccr  ; subtrahieren
        bra       _loop
_add:   add.l     divisor,D0   ; wenn X = 0
        move      SR,save_ccr  ; addieren
_loop:  dbf       D2,loop
        
        btst      #4,save_ccr  ; wenn X = 0
        bne       no_add       ; den Rest posi-
        add.l     divisor,D0   ; tiv machen
        bclr      #4,save_ccr
no_add:        
        move      save_ccr,CCR ; letztes Bit ins
        roxl.l    #1,D3        ; Erg. schieben

        move.l    D3,divisor  ; 'divisor' ist 
                              ; jetzt das Ergeb.
        move.l    rest(A6),A0 
        move.l    D0,(A0)
  }
  
  /* Ergebnis mit richtigem Vorzeichen zu-    */ 
  /* rÅckgeben                                */
  return( negflag ? -divisor : divisor );
}  

dublong *atodl( str, erg )
  register char    *str;
  register dublong *erg; 

{ register int negflag;

  /* Vorzeichen '-' da ? */
  if (*str=='-') { ++str; negflag = 1; }
  /* Ergebnis auf 0 initialisieren */
  dl_assign( 0L, erg );
  
  while( *str>='0' && *str<='9' ) { 
    dl_add( *dl_mul2( erg->high, erg->low,
                      0L, 10L, erg ),
            0L, (long)(*str-'0'), erg ); 
    ++str;
  };
  
  if (negflag) dl_neg( erg ); 
  return( erg );
}
    

