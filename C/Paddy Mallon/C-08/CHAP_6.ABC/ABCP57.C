/*  ABC p 57  eg 6.1                */
/*  zellers congruence              */
/*  returns a number(0-6) representing the day of the week for 
     a given date (ddmmyyyy). 0 = sunday                         */
/*   tested and working /11/86      */


int ticks = 300;

main()
     {    int day,month,year;

          printf(" gimme a date:...");
          scanf("%2d %2d %4d",&day,&month,&year);
          printf(" %d\n",zeller(day,month,year));
     delay(ticks);
     }
zeller(day,month,year)
     int day,month,year;
     {
          int temp,yr1,yr2;
     
     if (month<3){ month+=10;year-=1;}
     else month-=2;

     yr1=year/100; yr2=year%100;

     temp = (26*month-1)/10;

     return((day+temp+yr2+yr2/4+yr1/4-2*yr1+49)%7);
     }
