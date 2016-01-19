int i,w;

main()
     {
     bpoke(0xff8800,0);       /* Register 0 anw„hlen */
     bpoke(0xff8802,188);     /* Auf 188 setzen */
     bpoke(0xff8800,1);       /* Register 1 */
     bpoke(0xff8802,3);       /* Auf 3 setzen */

     bpoke(0xff8800,8);       /* Lautst„rkeregister */
     bpoke(0xff8802,15);      /* Auf 15 setzen */

     bpoke(0xff8800,7);       /* Modusregister */
     w=bpeek(0xff8800);       /* Modusregister lesen */
     w|=63;                   /* Alle Kan„le aus */
     w&=254;                  /* Bit 0 l”schen */
     bpoke(0xff8802,w);       /* Register setzen */

     pause(600);              /* 3 Sekunden Pause */

     bpoke(0xff8800,7);       /* Modusregister */
     w=bpeek(0xff8800);       /* Modusregister lesen */
     w|=1;                    /* Bit 0 setzen */
     bpoke(0xff8802,w);       /* Register setzen */
     }

