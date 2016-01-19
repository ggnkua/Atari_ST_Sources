int i,j;

main()
     {
     fsound(0,200,15,1);      /* Kanal 0 auf 200 Hz */
     fsound(1,201,15,1);      /* Kanal 1 auf 201 Hz */
     fsound(2,199,15,1);      /* Kanal 2 auf 199 Hz */

     pause(600);             /* 3 Sekunden Pause */

     setcfreq(7813);          /* Hllperiode 1 Sekunde */          
     setloud(0,16);           /* Hllkurve aktivieren */
     setloud(1,16);
     setloud(2,16);

     for(i=50;i<400;i+=10)
          {
          setfreq(0,i);
          setfreq(1,i+1);
          setfreq(2,i-1);
          setcurve(0);        /* Hllkurve starten */
          pause(100);         /* Warten */
          }

     setvoice(0,2);           /* Rauschen ein */
     sound(1,0,0,0);          /* Kanal 1 aus */
     sound(2,0,0,0);          /* Kanal 2 aus */
     setcfreq(15625);         /* Hllperiode 2 Sekunden */
     setcurve(14);            /* Dreieck */
     
     for(j=0;j<3;j++)
          {
          for(i=0;i<32;i++)
               {
               setnoise(i);
               pause(20);
               }
          for(i=31;i>0;i--)
               {
               setnoise(i);
               pause(20);
               }
          }

     for(i=0;i<32;i++)
          {
          setnoise(i);
          setcurve(0);
          pause(120);
          }

     sound(0,0,0,0);          /* Ausschalten */
     sound(1,0,0,0);
     sound(2,0,0,0);
     }

