/*****************************************************************************
 *                           B a l l e r b u r g          Modul 1            *
 * Dies ist der Hauptteil von Ballerburg. Die Routinen dieses Teils dienen   *
 * im groûen und ganzen der Steuerung des Programmes, dem Aufruf der Objekt- *
 * bÑume, sowie der AusfÅhrung elementarer Grafikoperationen.                *
 *                                       29.4.87      Eckhard Kruse          *
 *                                                    Reichenbergweg 7       *
 *                                                    D-3302 Weddel          *
 * öberarbeitet: 22.10.89                                                    *
 *****************************************************************************/
#include <osbind.h>     /* operating system Makros */
#include <baller.h>     /* Namen der Objekte der RSC-Datei */

#define Min(a,b)  ((a)<(b)?(a):(b))
#define Max(a,b)  ((a)>(b)?(a):(b))
#define maus()    graf_mkstate(&mx,&my,&bt,&dum)
#define menu(a)   wind_update(3-a)
#define hide()    graf_mouse(256,0)
#define show()    graf_mouse(257,0)
#define sav_scr() hide();movmem(scr,buf,32000);show()
#define lod_scr() hide();movmem(buf,scr,32000);show()
#define PI        3.1416
#define P57       57.296
#define G         0.02
#define bing()    printf("\007");
#define fn()      f=1-2*(n&1);

/* Externe Routinen: Funktionen aus MUSIK.C und Winkelfunktionen */
extern void m_musik(),m_laden(),m_wloop();
extern double sin(),cos(),tan(),atan2();

int _mneed=20000; /* wichtig bei Lattice C, damit sich das Programm nicht */
 /* gleich den ganzen Speicherplatz schnappt, sondern nur 20K. */

double vvx,vvy;
short handle, mx,my,bt,dum,m_buf[8], xy[100], 
      bur[2],bx[2],by[2], ge[2],pu[2],ku[2],vo[2],st[2],kn[2],
      wx[2],wy[2],ws,wc,
      *bg, zug,n,oldn, p[6],  t_gew[6][10], max_rund,
      fx,fy,fw,fh,
      ftx,fty,ftw,fth,
      f_h, *burgen[20],b_anz;
int   buf, scr, bur_ad, l_nam,r_nam,  a_opt, a_ein,
      a_men,a_inf,a_sch,a_brg,a_nam,a_dra,a_sta,a_sie,a_com,a_re1,a_re2,a_re3;
char  f, mod, wnd, end, txt[4], an_erl, mxin, au_kap,
      cw[2]={2,2}, cx[2]={1,1}, cn[7][8]={ "Tîlpel","Dummel","Brubbel",
      "Wusel","Brîsel","Toffel","RÅpel" },
      t_na[6][8]={ "Tîlpel","Dummel","Brubbel","Wusel","Brîsel","Toffel" },
      nsp1[22]="Hugo",nsp2[22]="Emil";

struct { short x,y,w,p; } ka[2][10];
struct { short x,y; } ft[2][5];
/*****************************************************************************/
main()
{
   short i;

   if( Getrez()<2 ) exit( form_alert(1,"[1]['Ballerburg' lÑuft nur|in der hohen Auflîsung][Abbruch]") );

   gem_init();
   scr=Logbase();

   m_laden("BALLER.MUS"); /* Laden der Musikdatei mit Funktion aus MUSIK.C */

   if( !rsrc_load( "BALLER.RSC" ) ) exit( form_alert(1,"[1][BALLER.RSC lÑût sich nicht|laden.][Abbruch]") );
   rsrc_gaddr( 0,MENUE,&a_men  );  rsrc_gaddr( 0,INFOTREE,&a_inf );
   rsrc_gaddr( 0,SCHUSS,&a_sch );  rsrc_gaddr( 0,BURG,&a_brg );
   rsrc_gaddr( 0,NAMEN,&a_nam  );  rsrc_gaddr( 0,DRAN,&a_dra );
   rsrc_gaddr( 0,STATUS,&a_sta );  rsrc_gaddr( 0,SIEGER,&a_sie );
   rsrc_gaddr( 0,COMPUTER,&a_com); rsrc_gaddr( 0,REGEL1,&a_re1 );
   rsrc_gaddr( 0,REGEL2,&a_re2 );  rsrc_gaddr( 0,REGEL3,&a_re3 );
   rsrc_gaddr( 0,OPTION,&a_opt );  rsrc_gaddr( 0,EINTRAG,&a_ein );

   for( i=0;i<6;i++ ) *(short *)(a_men+(ACC1+i)*24+10)=8;
   *(short *)(a_com+CN1*24+58)=1;  *(short *)(a_com+CN2*24+58)=1;
   *(short *)(a_com+CTS1*24+34)=1; *(short *)(a_com+CTS2*24+34)=1;

   buf=Malloc(42000); /* Speicher fÅr Burgdaten und zweiten Schirm holen */
   bur_ad=buf+32000;
   if( buf<1 ) exit( form_alert(1,"[1][Zu wenig Speicher!][Abbruch]") );
   an_erl=1; mxin=3; max_rund=32767; au_kap=1; t_load(); burgen_laden();

   menu_bar(a_men,1); menu(0);

   v_show_c( handle,0 ); graf_mouse( 0,0 );

   l_nam=(int)nsp1; r_nam=(int)nsp2; mod=0; neues();
   while( ein_zug() );

   t_save();
   menu_bar(a_men,0); menu(1); v_clsvwk( handle ); appl_exit();
}
/* Verwaltung von Ereignissen: Messages, Maus oder Timer */ 
event()
{
   short wh;

   wh=evnt_multi( 50, 1,1,1, 0,0,0,0,0, 0,0,0,0,0, m_buf, 300,0,
               &mx,&my,&bt,&dum,&dum,&dum );
   if( wh&16 && m_buf[0]==10 )
   {
      menu(0);
      if( m_buf[4]==INFO ) obj_do( a_inf );
      else if( m_buf[4]==SPI1 )     /* Neues Spiel */
      {
         if( bur_obj() ) { neues(); werdran(1); }
      }
      else if( m_buf[4]==SPI2 )     /* Namen eingeben */
      {
         movmem( nsp1, **(int **)(a_nam+NSP1*24+12), 20 );
         movmem( nsp2, **(int **)(a_nam+NSP2*24+12), 20 );
         if( obj_do( a_nam )==NOK )
         {
            movmem( **(int **)(a_nam+NSP1*24+12), nsp1, 20 );
            movmem( **(int **)(a_nam+NSP2*24+12), nsp2, 20 );
            if( !end ) werdran(1);
         }
      }
      else if( m_buf[4]==SPI4 ) /* Optionen */
      {
         *(short*)(a_opt+A_ERL*24+10)=an_erl;
         *(short*)(a_opt+A_VER*24+10)=!an_erl;
         *(short*)(a_opt+MAX_1*24+10)=!mxin;
         *(short*)(a_opt+MAX_2*24+10)=(mxin==1);
         *(short*)(a_opt+MAX_XX*24+10)=(mxin==2);
         *(short*)(a_opt+MAX_NE*24+10)=(mxin==3);
         *(short*)(a_opt+A_KAP*24+10)=au_kap;
         if( obj_do(a_opt)==OP_OK )
         {
            char *h;
            au_kap=*(short*)(a_opt+A_KAP*24+10);
            an_erl=*(short*)(a_opt+A_ERL*24+10);
            mxin=*(short*)(a_opt+MAX_2*24+10)+
                 2**(short*)(a_opt+MAX_XX*24+10)+
                 3**(short*)(a_opt+MAX_NE*24+10);
            h=(char *)(**(int **)(a_opt+MAX_XX*24+12));
            max_rund=h[0]-48;
            if(h[1])
               { max_rund=max_rund*10+h[1]-48; if(h[2])
                 max_rund=max_rund*10+h[2]-48; }
            if(!mxin) max_rund=20; if(mxin==1) max_rund=50;
            if(mxin==3) max_rund=32767;
         }
      }
      else if( m_buf[4]==SPI3 ) return( 1 );
      else if( m_buf[4]>=MOD1 && m_buf[4]<=MOD4 )
      {                          /* Spielmodus ( wer gegen wen ) */
         menu_icheck( a_men,MOD1+mod,0 );
         mod=m_buf[4]-MOD1;
         menu_icheck( a_men,m_buf[4],1 );
      }
      else if( m_buf[4]==MOD5 )
      {                       /* Computer auswÑhlen */
         obj_do( a_com );
         for( cw[0]=0; cw[0]<7; cw[0]++ )
            if( *(short *)(a_com+24*(CN1+cw[0])+10) ) break;
         for( cw[1]=0; cw[1]<7; cw[1]++ )
            if( *(short *)(a_com+24*(CN2+cw[1])+10) ) break;
         for( cx[0]=0; cx[0]<4; cx[0]++ )
            if( *(short *)(a_com+24*(CTS1+cx[0])+10) ) break;
         for( cx[1]=0; cx[1]<4; cx[1]++ )
            if( *(short *)(a_com+24*(CTS2+cx[1])+10) ) break;
      }
      else if( m_buf[4]==REG )     /* Spielregeln */
      {
         short a=0,b;
         int c;

         form_center( a_re1,&fx,&fy,&fw,&fh );
         form_center( a_re2,&fx,&fy,&fw,&fh );
         form_center( a_re3,&fx,&fy,&fw,&fh );
         sav_scr();
         form_dial( 1,190,20,30,20,fx,fy,fw,fh );
         do
         {
            objc_draw( c=a? (a<2? a_re2:a_re3):a_re1, 0,5,0,0,640,400 );
            b=form_do( c,0 ); *(short *)(c+24*b+10)=0;
            if( a==1 && b==R21 || a==2 && b==R31 ) { b=-1; a=0; }
            if( a==0 && b==R12 || a==2 && b==R32 ) { b=-1; a=1; }
            if( a==0 && b==R13 || a==1 && b==R23 ) { b=-1; a=2; }
         } while( b<0 );
         lod_scr();
         form_dial( 2,190,20,30,20,fx,fy,fw,fh );
      }
      else if( m_buf[4]==ERG1 )
      {
         movmem(t_na[0],**(int **)(a_ein+EI_N1*24+12),8);
         movmem(t_na[1],**(int **)(a_ein+EI_N2*24+12),8);
         movmem(t_na[2],**(int **)(a_ein+EI_N3*24+12),8);
         movmem(t_na[3],**(int **)(a_ein+EI_N4*24+12),8);
         movmem(t_na[4],**(int **)(a_ein+EI_N5*24+12),8);
         movmem(t_na[5],**(int **)(a_ein+EI_N6*24+12),8);
         *(short*)(a_ein+24*ER_LOE+10)=0; *(short*)(a_ein+24*ER_BLE+10)=1;
         if( obj_do( a_ein )==ER_OK )
         {
            short i,j;
            movmem(**(int **)(a_ein+EI_N1*24+12),t_na[0],8);
            movmem(**(int **)(a_ein+EI_N2*24+12),t_na[1],8);
            movmem(**(int **)(a_ein+EI_N3*24+12),t_na[2],8);
            movmem(**(int **)(a_ein+EI_N4*24+12),t_na[3],8);
            movmem(**(int **)(a_ein+EI_N5*24+12),t_na[4],8);
            movmem(**(int **)(a_ein+EI_N6*24+12),t_na[5],8);
            if(*(short*)(a_ein+24*ER_LOE+10))
               for(i=0;i<6;i++) for(j=0;j<10;j++) t_gew[i][j]=0;
         }
      }
      else if( m_buf[4]==ERG2 )
      {
         if( t_load() )
            form_alert(1,"[1][Kann BALLER.TAB nicht laden!][Abbruch]" );
      }
      else if( m_buf[4]==ERG3 ) t_save();
      else if( m_buf[4]==ERG4 )
      {
         sav_scr();
         form_dial( 1,260,20,30,20,48,52,548,308 );
         tabelle(); bt=0; while( !bt ) maus();
         lod_scr();
         form_dial( 2,260,20,30,20,48,52,548,308 );
      }
      if( m_buf[4]>=MOD1 && m_buf[4]<=MOD5 )
      {
         if( mod<2 ) l_nam=(int)nsp1; else l_nam=(int)cn[cw[0]];
         if( mod&1 ) r_nam=(int)cn[cw[1]]; else r_nam=(int)nsp2;
         if( !end ) werdran(1);
      }
      menu_tnormal( a_men,m_buf[3],1 );
      menu(1);
   }
   return( 0 );
}
/**************************** Tabelle ****************************************/
tabelle()
{
   short i,j;
   hide(); vsf_interior(handle,0);
   box(53,56,587,343,1); box(55,58,585,341,1); box(56,59,584,340,1);
   line(144,59,144,340); for(i=152;i<584;i+=72) line(i,59,i,340);
   line(56,84,584,84); for(i=92;i<240;i+=24) line(56,i,584,i);
   for(i=244;i<340;i+=24) line(56,i,584,i);
   for(i=0;i<6;i++) v_gtext(handle,160+i*72,78,t_na[i]);
   for(i=0;i<6;i++) v_gtext(handle,80,110+i*24,t_na[i]);
   vsf_interior(handle,2); vsf_style(handle,2);
   for(i=0;i<6;i++) for(j=0;j<10;j++)
   {
      z_txt(t_gew[i][j]);
      if(j==9 && !t_gew[i][6] ) { txt[0]=32; txt[1]='-'; txt[2]=0; }
      v_gtext(handle,176+i*72,110+j*24+8*(j>5),txt);
      if(i==j) box(152+i*72,92+j*24,224+i*72,116+j*24);
   }
   v_gtext(handle,64,262,"\344  Spiele"); v_gtext(handle,64,286,"\344gewonnen");
   v_gtext(handle,64,310,"\344verloren"); v_gtext(handle,64,334,"Siege in%");
   line(56,59,144,84); vst_height(handle,4,&i,&i,&i,&i);
   v_gtext(handle,60,81,"VERLOREN"); v_gtext(handle,92,66,"GEWONNEN");
   vst_height(handle,13,&i,&i,&i,&i); show();
}
z_txt(a)
short a;
{
   txt[0]=a/100+48; txt[1]=a%100/10+48; txt[2]=a%10+48;
   if(a<100) { txt[0]=32; if(a<10) txt[1]=32; }
   for(a=0;a<3;a++) txt[a]=txt[a]==48? 79: txt[a]==49? 108: txt[a];
}
/******************** Initialisierung vor neuem Spiel ************************/
neues()
{
   static short pr[6]={ 200,500,400,150,50,50 };   /* Preise zu Beginn */
   short j;

   wnd=Random()%60-30;
   st[0]=st[1]=20; kn[0]=kn[1]=0;
   for( j=0;j<6;j++ )
      p[j]=pr[j]*(95+Random()%11)/100;
   bild();
   for( n=0;n<2;n++ )
   {
      bg=burgen[bur[n]]; wx[n]=n? 639-bg[23]:bg[23]; wy[n]=by[n]-bg[24];
      for( f=0;f<5; ) ft[n][f++].x=-1;
   }
   zug=n=end=0; f=1;
}
/************************* DurchfÅhren eines Zuges ***************************/
ein_zug()
{
   short i,fl,a;

   n=zug&1; fn(); kn[n]&=~16;
   wnd=wnd*9/10+Random()%12-6;

   werdran(1);

   do
   {
      fl=0;
      menu(1);
      do
      {
         if( event() ) return(0);
         for( a=i=0;i<60; ) a|=*(char *)(scr+80+i++);
      } while( !bt && !(mod&(2-n)) || a );
      menu(0);
      bg=burgen[bur[n]];

      if( mod&(2-n) ) { hide(); i=comp(); show(); fl=1+(i<0); }
      else if( mx>ftx && mx<ftx+ftw && my>fty && my<fty+fth ) fl=2;
      else
      {
         for( i=0;i<10;i++ )
            if( ka[n][i].x<=mx && ka[n][i].x+20>=mx && ka[n][i].x!=-1 &&
                ka[n][i].y>=my && ka[n][i].y-14<=my ) break;
         if( i>9 )
         {
            if( drin( bg[25],bg[26],bg[31],bg[32],0,mx,my ) ||
                drin( bg[27],bg[28],bg[33],bg[34],0,mx,my ) ||
                drin( bg[29],bg[30],bg[35],bg[36],0,mx,my ) ) markt();
            else if( drin( bg[21],bg[22],30,25,0,mx,my ) ) koenig();
            else bing();
         }
         else if( pu[n]<5 )
          { bing(); form_alert(0,"[0][Dein Pulver reicht nicht!][Abbruch]");}
         else if( !ku[n] )
          { bing(); form_alert(0,"[0][Du hast keine Kugeln mehr!][Abbruch]");}
         else fl=sch_obj(i);
      }
   } while( !fl );

   werdran(0);
   if( fl<2 ) schuss(i);

   if( ~kn[n]&16 ) kn[n]&=~15;
   rechnen(); zug++;

   for( i=0;i<10;i++ ) if( ka[n][i].x>-1 ) break;
   n=zug&1; bg=burgen[bur[n]];
   for( a=0;a<10;a++ ) if( ka[n][a].x>-1 ) break;
      if( a==10 && i<10 && bg[40]>vo[n] && ge[n]<p[2]/3 && au_kap && 
          ft[n][0].x+ft[n][1].x+ft[n][2].x+ft[n][3].x+ft[n][4].x==-5 )
           end=n+33;

   if( !end && zug/2>=max_rund )
   {
      static h[2];
      for(n=0;n<2;n++)
      {
         h[n]=ge[n]+pu[n]*p[4]/30+ku[n]*p[5]/2+(wx[n]>-1)*p[3]+vo[n]*4;
         for(i=0;i<5;i++) if( ft[n][i].x>-1 ) h[n]+=p[1];
         for(i=0;i<10;i++) if( ka[n][i].x>-1 ) h[n]+=p[2];
      }
      end=65+(h[1]<h[0]);
   }
   if( end )
   {
      ende();
      menu(1);
      do
         if( event() ) return(0);
      while( !bt || end );
      menu(0);
   }
   return(1);
}
/********** Berechnen von Bevîlkerungszuwachs usw. nach jedem Zug ************/
rechnen()
{
   short j;
   static short pmi[6]={ 98,347,302,102,30,29 },   /* Preisgrenzen */
                pma[6]={ 302,707,498,200,89,91 },
                psp[6]={ 10,50,50,20,10,10 };     /* max. Preisschwankung */

   j=st[n];
   ge[n]+=vo[n]*(j>65? 130-j:j)/(150-Random()%50);
   vo[n]=vo[n]*(95+Random()%11)/100+(21-j+Random()%9)*(8+Random()%5)/20;
   if( vo[n]<0 ) { vo[n]=0; end=n+49; }

   for( j=0;j<5;j++ ) ge[n]+=(40+Random()%31)*(ft[n][j].x>-1);
   for( j=0;j<6;j++ )
   {
      p[j]+=psp[j]*(Random()%99)/98-psp[j]/2;
      p[j]=Max(p[j],pmi[j]); p[j]=Min(p[j],pma[j]);
   }
   drw_gpk(0);
}
/******************************* Spielende ***********************************/
ende()
{
   char s1[80],s2[80],s3[80],a,b,c;
   int sav_ssp;

   form_center( a_sie,&fx,&fy,&fw,&fh ); *(short *)(a_sie+18)=30;
   *(char **)(a_sie+24*SG1+12)=s1;
   *(char **)(a_sie+24*SG2+12)=s2;
   *(char **)(a_sie+24*SG3+12)=s3;
   strcpy( s1,"!! "); strcat( s1, end&2? l_nam:r_nam );
   strcat( s1," hat gewonnen !!" ); s2[0]=0;
   if(~end&64) strcpy(s2,"( ");   strcat( s2, end&2? r_nam:l_nam );
   if( (end&240)<48 )
     { a=s2[strlen(s2)-1]; strcat( s2, a=='s' || a=='S'? "' ":"s " ); }
   switch( end&240 )
   {
      case 16: strcat( s2,"Kînig wurde getroffen," );
               strcpy( s3,"  daraufhin ergab sich dessen Volk. )" ); break;
      case 32: strcat( s2,"Kînig hat aufgrund der" );
               strcpy( s3,"  aussichtslosen Lage kapituliert. )" ); break;
      case 48: strcat( s2," hat kein Volk mehr. )" ); s3[0]=0; break;
      case 64: strcpy( s3,s2 );
               strcpy( s2,"( Die maximale Rundenzahl ist erreicht.");
               strcat( s3," befindet sich in der schlechteren Lage. )" );
   }
   objc_draw( a_sie,0,7,0,0,640,400 );

   for(a=0;a<6 && strncmp(t_na[a],l_nam,7);a++);
   for(b=0;b<6 && strncmp(t_na[b],r_nam,7);b++);
   if(a<6 && b<6 && a!=b)
   {
      if(~end&2) { c=a; a=b; b=c; }
      t_gew[a][b]++; t_gew[b][8]++;
      t_gew[a][9]=100*++t_gew[a][7]/++t_gew[a][6];
      t_gew[b][9]=100*t_gew[b][7]/++t_gew[b][6];
   }
   hide(); sav_ssp=Super(0); m_musik(); Super(sav_ssp); show();  /* Musik... */
   Giaccess( 0,138 ); Giaccess( 0,139 ); Giaccess( 0,140 );
}
/* Die Routine m_wait() wird von m_musik() nach jedem 1/96 Takt aufgerufen.  */
/* In diesem Fall macht sie nichts anderes als die eigentliche Warteschleife */
/* aufzurufen. In eigenen Programmen kînnten Sie hier wÑhrend der Musik zu-  */
/* sÑtzliche Aktionen ablaufen lassen. */
m_wait()
{
   m_wloop();
}
/** Anzeige des Spielers, der am Zug ist, sowie Darstellung der Windfahnen ***/
werdran(c)
char c;
{
   short *a,i,x,y,w,h,c1,s1,c2,s2;
   char *ad;
   double wk,wl;

   z_txt(zug/2+1); v_gtext(handle,332,395,txt);

   a=(short *)(a_dra+16);
   if( c )
   {
      a[0]=5+(629-a[2])*n; a[1]=25;
      *(int *)(a_dra+DNAM*24+12)=n? r_nam:l_nam;
      ad=*(char **)(a_dra+DWIN*24+12);
      ad[0]=ad[5]=4+28*!wnd-(wnd>0);
      i=wnd<0? -wnd:wnd;
      ad[2]=48+i/10; ad[3]=48+i%10;
      if( wx[n]<0 ) { ad[0]=ad[5]=32; ad[2]=ad[3]='?'; }
      objc_offset( a_dra,DOK,&ftx,&fty );
      ftw=*(short *)(a_dra+DOK*24+20); fth=*(short *)(a_dra+DOK*24+22);
      objc_offset( a_dra,DWBX,&x,&y );
      w=*(short *)(a_dra+DWBX*24+20);  h=*(short *)(a_dra+DWBX*24+22);

      objc_draw( a_dra,0,4,0,0,640,400 );

      c=wnd>0? 1:-1;  wk=c*wnd/15.0; wl=wk*.82;
      if( wk>1.57 ) wk=1.57;  if( wl>1.57 ) wl=1.57;
      s1=c*20*sin(wk); c1=20*cos(wk); s2=c*20*sin(wl); c2=20*cos(wl);
      ws=s1/2.0; ws+=!ws; wc=c1/2.0;

      hide();
      if( wx[n]>-1 )
      {
         color(1); x+=w/2; line( x,y+h,x,y+5 ); line( x+1,y+h,x+1,y+5 );
         xy[0]=xy[2]=x+1; xy[1]=y+5; xy[3]=y+11;
         if( wk<.2 ) { xy[0]=x-1; xy[1]=xy[3]=y+5; xy[2]=x+2; }
         xy[4]=xy[2]+s1; xy[5]=xy[3]+c1;
         xy[8]=xy[0]+s1; xy[9]=xy[1]+c1;
         xy[10]=xy[0];   xy[11]=xy[1];
         xy[6]=(xy[4]+xy[8]>>1)+s2; xy[7]=(xy[5]+xy[9]>>1)+c2;
         v_pline( handle,6,xy );
      }
      fahne();
      show();
   }
   else
   {
      hide();
      clr( a[0],a[1],a[2],a[3] );
      show();
   }
}
/******************* Darstellung der beiden Windfahnen ***********************/
fahne()
{
   char m=-1;

   while( ++m<2 ) if( wx[m]>-1 )
   {
      clr( wx[m]-10,wy[m]-15,20,15 );
      color(1);
      line( wx[m],wy[m],wx[m],wy[m]-15 );
      if( m==n )
      {
         line( wx[m],wy[m]-15,wx[m]+ws,wy[m]-13+wc );
         line( wx[m],wy[m]-11,wx[m]+ws,wy[m]-13+wc );
      }
   }
}
/********************** BALLER.TAB laden/speichern ***************************/
t_load()
{
   if( (f_h=Fopen( "BALLER.TAB",0 ))<0 ) return(1);
   Fread(f_h,1,&an_erl); Fread(f_h,1,&au_kap); Fread(f_h,1,&mxin);
   Fread(f_h,3,**(int **)(a_opt+MAX_XX*24+12) ); Fread(f_h,2,&max_rund);
   Fread(f_h,48,t_na); Fread(f_h,120,t_gew);
   Fclose(f_h); return(0);
}
t_save()
{
   if( (f_h=Fcreate( "BALLER.TAB",0 ))<0 ) return(1);
   Fwrite(f_h,1,&an_erl); Fwrite(f_h,1,&au_kap); Fwrite(f_h,1,&mxin);
   Fwrite(f_h,3,**(int **)(a_opt+MAX_XX*24+12) ); Fwrite(f_h,2,&max_rund);
   Fwrite(f_h,48,t_na); Fwrite(f_h,120,t_gew);
   Fclose(f_h); return(0);
}
/************************* BALLER.DAT laden **********************************/
burgen_laden()
{
   short *a,j;

   a=(short *)bur_ad;
   if( (f_h=Fopen( "BALLER.DAT",0 ))<0 )
      exit( form_alert(1,"[1][Kann BALLER.DAT nicht finden.][Abbruch]") );
   b_anz=0;
   while( (j=rdzahl())!=-999 )
   {
      burgen[b_anz++]=a;
      *a++=j;
      for( j=0;j<40;j++ ) *a++=rdzahl();
      while( (*a++=rdzahl())!=-1 );
   }
   Fclose( f_h );
}
char zeichen()  /* liest ein char von der Datei */
{
   char a;
   Fread( f_h,1,&a );
   return(a);
}
rdzahl() /* liest eine Dezimalzahl von der Datei, Remarks werden Åberlesen */
{
   char a,sign=1,rem=0;    /* wird durch * getoggled, und zeigt damit an, */
                           /* ob man sich in einer Bemerkung befindet */
   int val=0;

   do
      if( (a=zeichen())=='*' ) rem=!rem;
   while( a!='-' && a<'0' || a>'9' || rem );

   if( a=='-' ) { sign=-1; a=zeichen(); }
   while( a>='0' && a<='9' )
   {
      val*=10; val+=a-'0';
      a=zeichen();
   }
   return( sign*val );
}
/************* Kanonenobjektbaum, Wahl von Winkel und Pulver *****************/
sch_obj(k)
short k;
{
   static short fig[]={ 0,0,15,20,30,20,20,15,10,0,10,-30,18,-18,20,-5,24,-6,
     20,-25,10,-40,0,-45, -10,-40,-20,-25,-24,-6,-20,-5,-18,-18,-10,-30,-10,0,
     -20,15,-30,20,-15,20, -1,-1 }; /* Daten fÅr das MÑnnchen */
   short i, wi,pv, xw,yw,xp,yp,xk,yk;
   double s,c;
   char *aw,*ap, fl=1;

   aw=*(char **)(a_sch+24*WINK+12);
   ap=*(char **)(a_sch+24*PULV+12);  *(ap+2)=0;

   sav_scr();

   form_center( a_sch,&fx,&fy,&fw,&fh );
   objc_offset( a_sch,WINK,&xw,&yw );
   objc_offset( a_sch,PULV,&xp,&yp );
   objc_offset( a_sch,KAST,&xk,&yk );  xk+=105+f*36; yk+=102;
   form_dial(1, ka[n][k].x+10*f,ka[n][k].y-10,20,14,fx,fy,fw,fh );
   wi=ka[n][k].w; pv=ka[n][k].p;

   vsf_interior( handle,1 );

   do
   {
      if( pv>pu[n] ) pv=pu[n];
      *aw=48+wi/100; *(aw+1)=48+wi%100/10; *(aw+2)=48+wi%10;
      if(wi<100) { *aw=*(aw+1); *(aw+1)=*(aw+2); *(aw+2)=0; }
      *ap=48+pv/10; *(ap+1)=48+pv%10;
      if(pv<10)  { *ap=*(ap+1); *(ap+1)=0; }

      if( fl )
      {
         objc_draw( a_sch,0,4,0,0,640,400 );
         hide();
         color(1);
         v_circle( handle,xk-88*f,yk-60,15 );
         i=0;
         while( fig[i]!=-1 )
            { xy[i]=xk-88*f+fig[i]; i++; xy[i]=yk-5+fig[i]; i++; }
         xy[i++]=xy[0]; xy[i++]=xy[1];
         v_fillarea( handle,i/2-1,xy );
         show();
      }
      objc_draw( a_sch,0,4,xw,yw,42,18 );
      objc_draw( a_sch,0,4,xp,yp,42,18 );

      if( i!=PL2 && i!=PR2 && i!=PL1 && i!=PR1 || fl )
      {
         hide();
         clr( xk-55,yk-76,110,90 );
         color( 1 );
         v_circle( handle,xk,yk,15 );

         s=sin(wi/P57); c=cos(wi/P57);
         fl=-f; if( wi>90 ) { fl=-fl; c=-c; }
         xy[0]=xk+fl*(c*14+s*14);  xy[1]=yk+s*14-c*14;
         xy[2]=xk+fl*(c*14+s*40);  xy[3]=yk+s*14-c*40;
         xy[4]=xk-fl*(c*55-s*40);  xy[5]=yk-s*55-c*40;
         xy[6]=xk-fl*(c*55-s*14);  xy[7]=yk-s*55-c*14;
         xy[8]=xy[0]; xy[9]=xy[1];
         v_fillarea( handle,4,xy );
         show();
         fl=0;
      }

      i=form_do( a_sch,0 ); if( i>=0 ) *(short *)(a_sch+24*i+10)=0;
      wi-=10*(i==WL2)-10*(i==WR2)+(i==WL1)-(i==WR1);
      if( wi<0 ) wi=0;  if( wi>180 ) wi=180;
      pv-= 3*(i==PL2)- 3*(i==PR2)+(i==PL1)-(i==PR1);
      if( pv<5 ) pv=5;  if( pv>20 ) pv=20;
   } while( i!=SOK && i!=SAB );

   lod_scr();

   form_dial(2, ka[n][k].x+10*f,ka[n][k].y-10,20,14,fx,fy,fw,fh );
   ka[n][k].w=wi; ka[n][k].p=pv;
   return( i==SOK );
}
/********************* Neues Spiel: Auswahl der Burgen ***********************/
bur_obj()
{
   short i,ob0,ob1,oy0,oy1, x,y,w,h, ol[8];

   oy0=by[0]; oy1=by[1]; ob0=bur[0]; ob1=bur[1];

   *(int *)(a_brg+24*BSP1+12)=l_nam;
   *(int *)(a_brg+24*BSP2+12)=r_nam;

   form_center( a_brg,&fx,&fy,&fw,&fh );

   w=*(short *)(a_brg+24*BK1+20);     h=*(short *)(a_brg+24*BK1+22);
   objc_offset( a_brg,BK1,&x,&y ); bx[0]=x;   by[0]=y+h;
   objc_offset( a_brg,BK2,&x,&y ); bx[1]=x+w; by[1]=y+h;

   sav_scr();
   form_dial( 1,70,20,30,20,fx,fy,fw,fh );
   objc_draw( a_brg,0,5,0,0,640,400 );
   ol[0]=ge[0]; ol[1]=ge[1];   ol[2]=pu[0]; ol[3]=pu[1]; /* Sichern der alten*/
   ol[4]=ku[0]; ol[5]=ku[1];   ol[6]=vo[0]; ol[7]=vo[1]; /* Werte */
   burg(2); burg(3);

   do
   {
      ge[0]=ge[1]=pu[0]=pu[1]=ku[0]=ku[1]=9999;
      i=form_do( a_brg,0 ); *(short *)(a_brg+24*i+10)=0;
      if( i==BL1 || i==BR1 )
      {
         bur[0]=(bur[0]+1-2*(i==BL1)+b_anz)%b_anz;
         clr( bx[0],y,w,h ); burg(2);
      }
      if( i==BL2 || i==BR2 )
      {
         bur[1]=(bur[1]+1-2*(i==BL2)+b_anz)%b_anz;
         clr( bx[1]-w,y,w,h ); burg(3);
      }
   } while( i!=BOK && i!=BAB );
   ge[0]=ol[0]; ge[1]=ol[1];  pu[0]=ol[2]; pu[1]=ol[3];
   ku[0]=ol[4]; ku[1]=ol[5];  vo[0]=ol[6]; vo[1]=ol[7];

   lod_scr();
   form_dial( 2,70,20,30,20,fx,fy,fw,fh );

   fn(); by[0]=oy0; by[1]=oy1;
   if( i==BAB ) { bur[0]=ob0; bur[1]=ob1; }
   return( i==BOK );
}
/************** Darstellung und Verwaltung eines Objektbaumes ****************/
obj_do(adr)
int adr;
{
   int a; short x=20,fl=0;

   if(adr==a_nam) { fl=NSP1; x=80; }
   if(adr==a_opt) { fl=MAX_XX; x=80; }
   if(adr==a_com) x=150;
   if(adr==a_ein) { fl=EI_N1; x=260; }

   form_center( adr,&fx,&fy,&fw,&fh );
   sav_scr(); form_dial( 1,x,20,30,20,fx,fy,fw,fh );
   objc_draw( adr,0,5,0,0,640,400 ); a=form_do( adr,fl );
   *(short *)(adr+24*a+10)=0;
   lod_scr(); form_dial( 2,x,20,30,20,fx,fy,fw,fh );
   return(a);
}
/*********************** Elementare  Grafikbefehle ***************************/
gem_init() /* ôffnen der Workstation... */
{
   short i, work_in[11], work_out[57];

   appl_init();
   handle=graf_handle( &i, &i, &i, &i );
   for( i=0; i<10; i++ )  work_in[i]=1;
   work_in[10]=2;
   v_opnvwk( work_in, &handle, work_out );
   v_clrwk( handle );
}

color(a)
short a;
{
   vst_color( handle,a );
   vsl_color( handle,a );
   vsf_color( handle,a );
}

loc( x,y )  /* Ermittelt, ob Punkt gesetzt ist */
short x,y;
{
   short a,b;
   v_get_pixel(handle,x,y,&a,&b);
   return((int)a);
}

line( x1,y1,x2,y2 ) /* Zeichnet eine Linie */
short x1,y1,x2,y2;
{
   xy[0]=x1; xy[1]=y1; xy[2]=x2; xy[3]=y2;
   v_pline( handle, 2, xy );
}

box(x,y,x2,y2,c)
short x,y,x2,y2,c;
{
   color(c);
   xy[0]=x; xy[1]=y; xy[2]=x2; xy[3]=y2;
   v_bar( handle,xy );
}
clr( x,y,w,h ) short x,y,w,h; { box(x,y,x+w-1,y+h-1,0); }

cls() /* Lîscht den gesamten Bildschirm auûer der MenÅleiste */
{
   int *a,i;

   a=(int *)(scr+32000);
   for( i=0;i<7600;i++ ) *--a=0;
}
