/* (c) 1991 MAXON Computer */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <vdi.h>
#include <string.h>

#define  MIN(a,b)   ((a)<(b)?(a):(b))
#define  BIT(x,z)   (((s[x]>>l)&1)<<z)
#define  POUT(x)    Cprnout(x)
#define  BTST(x,b)  (((x)>>(b))&1)

#define  SCALE      1
#define  MODE       2
#define  LINESTYLE  3
#define  TEXTSTYLE  4
#define  LINE       5
#define  TEXT       6
#define  BOX        7

void veccopy(int x_vir,int y_vir,int x_out,
             int y_out,int x_res,int y_res);
void driver_09n(int x_res,int y_res,int x_prn_b,
                int y_prn_z,char *map_adr);
void driver_24n(int x_res,int y_res,int x_prn_b,
                int y_prn_z,char *map_adr);
void driver_hpl(int x_res,int y_res,int x_prn_b,
                int y_prn_z,char *map_adr);
void vectext(int handle,int x_pos,int y_pos,
             int angle,int width,int height,
             int hot,char *text);
void graphic(int handle,int x_offs,int y_offs,
             double x_scale,double y_scale);
void vdi(int handle,int was,int x,int y,
         long w,long h);

int printer;

main()                    /* Ein kleines Demo: */
{
  int dx,dy,xr,yr,clip[]={0,0,639,399};

  do
  {
    Cconws("\x1b\x45");  /* Bildschirm lîschen */
    
    vs_clip(1,1,clip);      /* Clipping setzen */
    graphic(1,400,150,.2,.2); /* Grafik zeigen */
    graphic(1,230,50,.15,.15);
    graphic(1,440,40,.1,.1);    
    vectext(1,20,200,0,320,80,0,"Vectext");
    vectext(1,20,280,0,320,20,0, /* Vectext()- */
            "Ein kleines Demo");  /* Beispiele */
    vectext(1,20,310,0,-8,32,0,
            "oben: konstante Textbreite");
    vectext(1,20,340,0,-8,32,0,
            "hier: konstante Zeichenbreite");
    printf("\n0=raus, 1=9-Nadler, 2=24-Nadler, "
           "3=HP-Laser, 4=Bildschirm: ");
    scanf("%d",&printer); 
    if(printer)
    {
      printf("Breite in mm: "); scanf("%d",&dx);
      printf("Hîhe in mm: ");   scanf("%d",&dy);
      printf("Druckdichte x: ");scanf("%d",&xr);
      printf("Druckdichte y: ");scanf("%d",&yr);
      
      veccopy(1000,1000,dx/.254,dy/.254,xr,yr);
    }                   /* ^ Grafik ausdrucken */
  }
  while(printer);
  
  return 0;
}


/* C-Routine: veccopy()    (w) 1991 by M. Kraus 
   Zweck    : Druckt eine Objektgrafik aus  
   Parameter: x_vir,y_vir: Ausdehnung des 
              virtuellen Koordinatensystems
              x_out,y_out: Grîsse der Grafik
              in 1/100 Zoll (1 Zoll=25.4 mm)
              x_res,y_res: Druckdichte in dpi  */

void veccopy(int x_vir,int y_vir,int x_out,
             int y_out,int x_res,int y_res)
{
  int  dy,x,y,win[11]={1},wout[57],hdl,px[8]={0},
       x_mon,y_mon,     /* Bildschirmauflîsung */
       x_prn,y_prn,       /* Grafik in Punkten */
       x_prn_w,       /* Bitmapbreite in Words */
       y_prn_z,        /* Bitmaphîhe in Zeilen */
       x_offs,y_offs;       /* Die Offsetwerte */
  double x_scal,y_scal; /* Skalierungsfaktoren */
  char *map_adr;          /* Zeiger auf Bitmap */
  MFDB src={NULL,0,0,0,0,0,0,0,0},  /* Zum Ko- */
       dst={NULL,0,0,0,0,1,0,0,0};   /* pieren */

  v_opnvwk(win,&hdl,wout);  /* Workstation auf */
  if(hdl)                    /* Falls geklappt */
  {
    x_mon=wout[0]+1;         /* Bildschirmauf- */
    y_mon=wout[1]+1;        /* lîsung auslesen */
    x_prn=dst.fd_w=x_res*(x_out/100.);
    y_prn=dst.fd_h=y_res*(y_out/100.);
    x_prn_w=dst.fd_wdwidth=((x_prn-1)/16)+1;
    y_prn_z=48*(y_mon/48);

    x_scal=1.*x_prn/x_vir;   /* Berechnung der */
    y_scal=1.*y_prn/y_vir;   /* Skal.-faktoren */

    px[2]=wout[0];px[3]=wout[1];  /* Maximales */
    vs_clip(hdl,1,px);   /* ..Clippingrechteck */
    map_adr=dst.fd_addr=(char*)calloc(x_prn_w*2,
            y_prn_z);  /* Neue Bitmap schaffen */
    px[3]=px[7]=y_prn_z-1; /* Quell- und Ziel- */
                                /* koordinaten */
    for(y=0;y<=y_prn;y+=y_prn_z)
    {                       /* Hîhe durchgehen */
      y_offs=-y;                   /* Y-Offset */
      for(x=0;x<=x_prn;x+=x_mon) 
      {                   /* Breite durchgehen */
        x_offs=-x;                 /* X-Offset */
        v_clrwk(hdl);    /* Bildschirm lîschen */
        
        /* Genau hier muss die Objektgrafik mit
        den Skalierungsfaktoren und den Offset-
        werten aufgerufen werden:              */

        graphic(hdl,x_offs,y_offs,x_scal,y_scal);

        px[4]=x; /* Quell- und Zielkoordinaten */
        px[6]=(px[2]=MIN(x_mon,x_prn-x+1)-1)+x;
        vro_cpyfm(hdl,3,px,&src,&dst); 
      }       /* Bildschirm in Bitmap kopieren */
      dy=MIN(y_prn_z,y_prn-y+1);/* Restl. Hîhe */

      /* Hier muss der gewÅnschte Druckertreiber
      aufgerufen werden. Im Beispiel hÑngt er von
      der globalen Variablen 'printer' ab.     */
       
      if(printer==1)
        driver_09n(x_res,y_res,x_prn_w*2,
                   dy,map_adr);
      else if(printer==2)
        driver_24n(x_res,y_res,x_prn_w*2,
                   dy,map_adr);
      else if(printer==3) 
        driver_hpl(x_res,y_res,x_prn_w*2,
                   dy,map_adr); 
    }
    free(map_adr);       /* Speicher freigeben */
    v_clsvwk(hdl);   /* Workstation schliessen */
  }
}


/* C-Routine: driver_09n()  (w) 1991 by M. Kraus 
   Zweck    : Druckt eine Bitmap auf 9-Nadler  
   Parameter: x_res,yres: Druckdichte in dpi
              x_prn_b: Bitmapbreite in Bytes
              y_prn_z: Bitmaphîhe in Pixel
              map_adr: Adresse der Bitmap      */

void driver_09n(int x_res,int y_res,int x_prn_b,
                int y_prn_z,char *map_adr)
{
  int y1,y2,l,lmax,dk,s[8]={0},p_res;
  long k,k0,k1,kmax=(long)x_prn_b*y_prn_z;
  short f1,f2,f3;

  f1=(y_res==72);f2=(y_res==108);f3=(y_res==216);
  p_res=3*(x_res==240)+(x_res==120)+6*(x_res==90)
        +4*(x_res==80)+5*(x_res==72);
  dk=(3-2*f1)*x_prn_b;
  POUT(27);POUT(51);     /* Horizontale Druck- */
  POUT(1+f2+23*f1);       /* dichte einstellen */
  for(y1=0;y1<y_prn_z;y1+=y_res/9)
  {           /* Bitmap zeilenweise durchgehen */
    for(y2=0;y2<(3-2*f1);y2++)
    {
      POUT(27);POUT(42);POUT(p_res); /* Grafik-*/  
      POUT((x_prn_b<<3)&0xFF); /* daten ankÅn- */
      POUT(((x_prn_b<<3)>>8)&0xFF);   /* digen */

      k0=(long)(y1+y2)*x_prn_b;
      for(k=k0,lmax=0;lmax<8 && k<kmax;
          lmax++,k+=dk);    /* öberschuss aus- */
      for(l=lmax;l<8;s[l++]=0);     /* blenden */
      for(k=k0;k<k0+x_prn_b;k++) /* Druckzeile */
      {                          /* ..auslesen */
        for(k1=k,l=0;l<lmax;k1+=dk,l++)
          s[l]=map_adr[k1]; /* Byteblock holen */

        if (f2)  /* ..und zum Drucker schicken */
          for(l=7;l>=0;l--)
            POUT(BIT(0,7)|BIT(1,5)|BIT(2,3)|
                 BIT(3,1));
        else
          for(l=7;l>=0;l--)
            POUT(BIT(0,7)|BIT(1,6)|BIT(2,5)|
                 BIT(3,4)|BIT(4,3)|BIT(5,2)|
                 BIT(6,1)|BIT(7,0));
      }
      POUT(13);POUT(10);     /* Zeilenvorschub */
    }
    if (!f1)
    {                      
      POUT(27);POUT(74);POUT(18+3*f3);POUT(13);
    }                      /* ^ Zeilenvorschub */
  }
}


/* C-Routine: driver_24n()  (w) 1991 by M. Kraus 
   Zweck    : Druckt eine Bitmap auf 24-Nadler  
   Parameter: siehe driver_09n()               */

void driver_24n(int x_res,int y_res,int x_prn_b,
                int y_prn_z,char *map_adr)
{
  int y1,y2,l,lmax,dk,s[24]={0},p_res;
  long k,k0,k1,kmax=(long)x_prn_b*y_prn_z;
  short f1,f2;
  
  f1=(y_res==360);f2=1+(y_res==90)+2*(y_res==60);
  p_res=32+8*(x_res==360)+7*(x_res==180)+
        (x_res==120)+6*(x_res==90);
  dk=(1+f1)*x_prn_b;
  POUT(27+f1);POUT(51);  /* Horizontale Druck- */
  POUT(1+23*!f1);         /* dichte einstellen */
  for(y1=0;y1<y_prn_z;y1+=12*y_res/90)
  {           /* Bitmap zeilenweise durchgehen */
    for(y2=0;y2<=f1;y2++)
    {
      POUT(27);POUT(42);POUT(p_res); /* Grafik-*/
      POUT((x_prn_b<<3)&0xFF); /* daten ankÅn- */
      POUT(((x_prn_b<<3)>>8)&0xFF);   /* digen */

      k0=(long)(y1+y2)*x_prn_b;
      for(k=k0,lmax=0;lmax<24 && k<kmax;
          lmax+=f2,k+=dk);  /* öberschuss aus- */
      for(l=lmax;l<24;s[l++]=0);    /* blenden */
      for(k=k0;k<k0+x_prn_b;k++) /* Druckzeile */
      {                          /* ..auslesen */
        for(k1=k,l=0;l<lmax;k1+=dk,l+=f2)
          s[l]=map_adr[k1]; /* Byteblock holen */

        for(l=7;l>=0;l--) /* ..und zum Drucker */
        {                        /* ..schicken */
          POUT(BIT(0,7)|BIT(1,6)|BIT(2,5)|
               BIT(3,4)|BIT(4,3)|BIT(5,2)|
               BIT(6,1)|BIT(7,0));
          POUT(BIT(8,7)|BIT(9,6)|BIT(10,5)|
               BIT(11,4)|BIT(12,3)|BIT(13,2)|
               BIT(14,1)|BIT(15,0));
          POUT(BIT(16,7)|BIT(17,6)|BIT(18,5)|
               BIT(19,4)|BIT(20,3)|BIT(21,2)|
               BIT(22,1)|BIT(23,0));
        }
      }
      POUT(13);POUT(10);     /* Zeilenvorschub */
    }
    if (f1)
    {       
      POUT(27);POUT(74);POUT(23);POUT(13);
    }                      /* ^ Zeilenvorschub */
  }
}


/* C-Routine: driver_hpl()  (w) 1991 by M. Kraus 
   Zweck    : Druckt eine Bitmap auf HP-Laserjet  
   Parameter: siehe driver_09n()               */

void driver_hpl(int x_res,int y_res,int x_prn_b,
                int y_prn_z,char *map_adr)
{
  long i;
  char s[10];

  sprintf(s,"\x1b*t%dR",MIN(x_res,y_res));
  Fwrite(3,strlen(s),s);        /* Druckdichte */
  Fwrite(3,5,"\x1b*r0A");       /* Grafikmodus */
  sprintf(s,"\x1b*b%dW",x_prn_b); /* Anzahl d. */
                              /* ..Grafikbytes */
  for(i=0;i<y_prn_z;i++)    /* Hîhe der Bitmap */
  {                            /* ..durchgehen */
    Fwrite(3,strlen(s),s);/* Grafik ankÅndigen */
    Fwrite(3,x_prn_b,map_adr+i*x_prn_b);
  }                  /* ^ Grafik rÅberschicken */
  Fwrite(3,4,"\x1b*rB");   /* Ende Grafikmodus */
}


/* C-Routine: vectext()    (w) 1991 by M. Kraus 
   Zweck    : Generiert Pseudo-Vektorschrift  
   Parameter: handle: VDI-Handle (oder 1)
              x_pos,y_pos: Textposition
              angle: Rotationswinkel (1/10 Grad)
              width: >0: Gesamtbreite des Textes
                     <0: Breite eines Zeichens
              height: Hîhe des Textes
              hot: Bezugspunkt fÅr x_pos/y_pos
              text: Zeiger auf den Text        */

void vectext(int handle,int x_pos,int y_pos,
             int angle,int width,int height,
             int hot,char *text)
{
  int i,j,k,slen,b1,b2,b3,sn,cs,dx,dy,x1,y1,x2,
      y2,px[8]={0,0,639,15,0,16,639,31},attr[15];
  char c,font[2560]={0};
  MFDB src={NULL,0,0,0,0,0,0,0,0}, 
       dst={NULL,640,32,40,0,1,0,0,0}; 

  dst.fd_addr=font;   /* Hintergrund in Buffer */
  vro_cpyfm(handle,3,px,&src,&dst); /* ..moven */
  px[5]=0;px[7]=15;         /* Platzmachen fÅr */
  vro_cpyfm(handle,3,px,&dst,&src);  /* ..Text */
  vqf_attributes(handle,attr);/* Einstellungen */
  vqt_attributes(handle,attr+5);   /* ..merken */
  vswr_mode(handle,MD_TRANS);  /* Schreibmodus */
  vsf_perimeter(handle,0);    /* Umrandung weg */
  vst_point(handle,13,&i,&i,&i,&i);/* Texthîhe */
  v_gtext(handle,0,13,text);  /* Text zeichnen */
  vro_cpyfm(handle,3,px,&src,&dst);/* ..und in */
                      /* ..den Buffer kopieren */
  px[1]=16;px[3]=31;  /* Alten Hintergrund re- */
  vro_cpyfm(handle,3,px,&dst,&src);/* staurier.*/
  vqt_extent(handle,text,px);    /* Ausdehnung */
                   /* ..des Textes feststellen */
  vswr_mode(handle,attr[3]); 
  vst_point(handle,attr[12],&i,&i,&i,&i); 
                       /* ^ Alte Einstellungen */
  slen=(int)strlen(text);    /* Anzahl Zeichen */
  b1=px[2]>>3;          /* Textbreite in Bytes */
  b2=((width>0)-slen*(width<0))*width;
  b3=px[2]*(width>0)-px[2]/slen*(width<0);
  sn=(angle==2700)-(angle==900);      /* Sinus */
  cs=(angle==0)-(angle==1800);      /* Cosinus */
  dx=x_pos-((b2*cs-height*sn)>>1)*(BTST(hot,0)+
     (BTST(hot,1)>>1));    /* x/y-Verschiebung */
  dy=y_pos-((b2*sn+height*cs)>>1)*(BTST(hot,2)+
     (BTST(hot,3)>>1));   /* ..fÅr Bezugspunkt */
               /* ..hot sowie Drehung um angle */
  for(j=0;j<16;j++)     /* Texthîhe durchgehen */
  {
    y1=(j*height)>>4;
    y2=(((j+1)*height)>>4)-1;
    for(i=0;i<=b1;i++) /* Textbreite byteweise */
    {                          /* ..durchgehen */
      c=font[i+j*80];   /* Ein Byte des Textes */
      k=8*!c;        /* Bits durchgehen, falls */
      while(k<8)      /* ..welche gesetzt sind */
      {    /* Bitgruppe suchen und vergrîssern */
        while(BTST(c,7-k)==0 && k<8) k++;
        if(k<8)
        {
          x1=(int)((k+(i<<3))*(long)width/b3);
          while(BTST(c,7-k) && k<8) k++;
          x2=(int)((k+(i<<3))*(long)width/b3-1);
          px[0]=x1*cs-y1*sn+dx;   /* Rechteck- */
          px[1]=x1*sn+y1*cs+dy; /* koordinaten */
          px[2]=x2*cs-y2*sn+dx;    /* ..drehen */
          px[3]=x2*sn+y2*cs+dy;
          v_bar(handle,px);        /* Rechteck */
        }    
      }
    }
  }
  vsf_perimeter(handle,attr[4]);  /* Umrandung */
}


/* C-Routine: graphic()     (w) 1991 by M. Kraus 
   Zweck    : Demo-Objektgrafik, bezogen auf ein
              1000*1000-Punkte-Koord.system
   Parameter: handle: VDI-Handle (oder 1)
              x_offs,y_offs: Ausgabe-Offset
              x_scale,y_scale: Skalier.fakt.   */

void graphic(int handle,int x_offs,int y_offs,
             double x_scale,double y_scale)
{
  int i;

  vdi(handle,SCALE,x_offs,y_offs,
      (long)&x_scale,(long)&y_scale);
  vdi(handle,MODE,1,0,0,0);
  vdi(handle,LINESTYLE,1,1,0,0);
  vdi(handle,BOX,0,0,999,999);
  vdi(handle,LINE,0,0,999,999);
  for(i=0;i<=400;i+=20)
  {
    vdi(handle,LINE,500+i,500,500,100+i);
    vdi(handle,LINE,500-i,500,500,100+i);
    vdi(handle,LINE,500+i,500,500,900-i);
    vdi(handle,LINE,500-i,500,500,900-i);
  }
  vdi(handle,TEXTSTYLE,400,100,0,4);
  vdi(handle,TEXT,780,200,5,(long)"Objekt-");
  vdi(handle,TEXT,780,300,5,(long)"Graphik");
  vdi(handle,TEXTSTYLE,-40,50,900,20);
  vdi(handle,TEXT,180,700,5,(long)"Das ist");
  vdi(handle,TEXT,250,700,5,(long)"Vektor-");
  vdi(handle,TEXT,320,700,5,(long)"text");
  vdi(handle,TEXTSTYLE,1000,64,0,0);
  vdi(handle,TEXT,500,40,5,(long)"DEMO");
  vdi(handle,TEXT,500,960,5,(long)"DEMO");
}


/* C-Routine: vdi()        (w) 1991 by M. Kraus 
   Zweck    : Grafisches Minimalsystem
   Parameter: handle: VDI-Handle (oder 1)
              was: Kennwort, siehe #defines
              x,y,w,h: Universalparameter      */

void vdi(int handle,int was,int x1,int y1,
         long x2,long y2)
{
  static double sx=1,sy=1;
  static int ox,oy,txt_w,txt_h,txt_a;
  int x1s=ox+(int)(x1*sx),x2s=ox+(int)(x2*sx),
      y1s=oy+(int)(y1*sy),y2s=oy+(int)(y2*sy),
      px[10];
 
  switch (was)
  {
    case SCALE:
      sx=*(double*)x2;sy=*(double*)y2;
      ox=x1;oy=y1; /* Skalierung+Offset merken */
      vsl_color(handle,1);   /* Linien-, FÅll- */
      vsf_color(handle,1);    /* und Textfarbe */
      vst_color(handle,1);    /* ..auf schwarz */
      vsf_interior(handle,1);    /* FÅllmuster */
      break;
    case MODE:
      vswr_mode(handle,x1);    /* Schreibmodus */
      break;
    case LINESTYLE:
      vsl_type(handle,x1);       /* Linienstil */
      vsl_width(handle,y1);    /* Linienbreite */
      break;
    case TEXTSTYLE:
      if(x2==0||x2==1800) 
      { txt_w=x1*sx;txt_h=y1*sy; }
      else       /* x1,y1=Textbreite und -hîhe */
      { txt_w=x1*sy;txt_h=y1*sx; }
      txt_a=(int)x2;             /* Textwinkel */
      vst_effects(handle,(int)y2);  /* Effekte */
      break;      
    case LINE:
      px[0]=x1s;px[1]=y1s;px[2]=x2s;px[3]=y2s;
      v_pline(handle,2,px); /* Linie von x1/y1 */
      break;                   /* ..nach x2/y2 */
    case TEXT:
      vectext(handle,x1s,y1s,txt_a,txt_w,txt_h,
              (int)x2,(char*)y2);               
      break; /* x1/y1=Textpos., x2=Bezugspunkt */
    case BOX:
      px[0]=px[6]=px[8]=x1s;px[2]=px[4]=x2s;
      px[1]=px[3]=px[9]=y1s;px[5]=px[7]=y2s;
      v_pline(handle,5,px);    /* Rechteck von */
      break;                /* x1/y1 bis x2/y2 */
  }  
}
