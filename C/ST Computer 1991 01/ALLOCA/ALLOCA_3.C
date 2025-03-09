
/* stackavail() liefert den jetzt freien Platz*/
/* auf dem Stack                              */

long stackavail()

{ long stack;
  extern long *_base;
  
  /* jetzigen SP in Variable 'stack' bringen  */
  asm{ move.l A7,stack(A6) }
  
  return( ( 
      stack+12    /* akt. Stack mit Korrektur */   
    ) - (        /* unteres Ende des Stacks : */
      (long)_base+            /* Basepageadr. */
      _base[3]+               /* Text size    */
      _base[5]+               /* Data size    */
      _base[7]+               /* Bss size     */
      256L                    /* Basepagesize */
    )
  );
}


