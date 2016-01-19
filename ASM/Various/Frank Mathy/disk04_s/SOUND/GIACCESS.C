#define giaccess(data,register) sxbios(28,data,register)

int i,w;

main()
     {
     giaccess(188,128);       /* Register 0 auf 188 */
     giaccess(3,128+1);       /* Register 1 auf 3 */
     giaccess(15,128+8);      /* Register 8 auf 15 */
     w=giaccess(0,7);         /* Register 7 lesen */

     w|=63;                   /* Alle Kan„le aus */
     w&=254;                  /* Bit 0 l”schen */
     giaccess(w,128+7);       /* Register setzen */

     pause(600);              /* 3 Sekunden Pause */

     w=giaccess(0,7);         /* Register lesen */
     w|=1;                    /* Bit 0 setzen */
     giaccess(w,128+7);       /* Register setzen */
     }

