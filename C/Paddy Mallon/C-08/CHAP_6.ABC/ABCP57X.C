/*  ABC p 57                         */
/*  tested and working 28/11/86      */
/*  now prints the day and number    */


int ticks = 300;

main()
     {    int day,month,year,k;
          
          char day0[]= "sunday";
          char day1[]= "monday";
          char day2[]= "tuesday";
          char day3[]= "wednesday";
          char day4[]= "thursday";
          char day5[]= "friday";
          char day6[]= "saturday";
          
             printf(" gimme a date:...");
             scanf("%2d %2d %4d",&day,&month,&year);
             printf(" %d\n",zeller(day,month,year));
             k = zeller(day,month,year);
             switch(k)
               {
                    case 0: printf("%s\n",day0);break;
                    case 1: printf("%s\n",day1);break;
                    case 2: printf("%s\n",day2);break;
                    case 3: printf("%s\n",day3);break;
                    case 4: printf("%s\n",day4);break;
                    case 5: printf("%s\n",day5);break;
                    case 6: printf("%s\n",day6);break;
                }

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
