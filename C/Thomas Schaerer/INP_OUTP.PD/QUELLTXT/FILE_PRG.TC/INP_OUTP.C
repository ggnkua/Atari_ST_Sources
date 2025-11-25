/*  Filename:    INP_OUTP.C   
    -----------------------    
    Dieses Programm erlaubt Fliesskommazahlen-   
    werte mittels Gr”ssenordnungssymbolen zu    
    lesen und wieder auszugeben. Dieses Turbo-   
    C-Programm ist das Žquivalent zum GFA-3.x-   
    BASIC-Programm INP_OUTP.GFA.
    
    Autor:              Thomas Schaerer  Im Lindenhof 6
                                        CH-Effretikon  (Schweiz)
    Datum:              21. August 1992
    Sprache:    TURBO-C
*/   
   
#include <inp_outp.h>   

   
/* Globale modulinterne Funktionen  */ 
/* -------------------------------  */
double eingabe(void);      /* return: 'in'     */   
char *ausgabe(double in);  /* return: 'out'    */   
void get_s(char eingabe[]);             
void catchkey(void);  /* Tastaturpuffer leeren */   

/* ------------------------------------------- */   
                     

void  main() /* 'eingabe' und 'ausgabe' testen */ 
{   
  double in;
  char *out;
    
  cls();
  catchkey();
  do    
  {   
    ena_curs();
    in =  eingabe();
    printf(" Eingaberesultat: %le\n",in);
    out = ausgabe(in);      
    printf(" Ausgaberesultat: %s\n",out);
    revrs_curs();
    puts(" Weiter: Taste. / Abbruch: <q> \n");
    norm_curs();
    dis_curs();
  }   
  while((getch())!='q');  /* Programm-Abbruch  */ 
     
  ena_curs();
  cls();
  exit(0);
}   
   

/* --------------------------------------------*/   
   

double eingabe(void)                            /* 'in' = raus */   
{   
  char eingabe[CH_MAX];
  int error, k, exp, symb_pos, len;
  double in;
    
  /* Es wird getestet, ob ein unerlaubtes Gr”s-   
     senordnungssymbol eingegeben wird.    
     Falls ja, error=TRUE.
     Wenn ein erlaubtes Gr”ssenordnungssymbol 
     eingegeben wurde, wird Position im String
     und Typ ermittelt-                          */   
  do    
  {   
    printf(" Eingabe: ");
    get_s(eingabe);  /* Werteingabe als String */   
    error = 0;
    len = (int)strlen(eingabe);
    symb_pos = len+5; /* Nicht 0, groesser len */  
       
    for(k=0; k<len; k++)    
    {   
      switch(eingabe[k])   
      {   
        case 'T': exp =  12; symb_pos = k; break;
        case 'G': exp =   9; symb_pos = k; break;
        case 'M': exp =   6; symb_pos = k; break;
        case 'K':     
        case 'k': exp =   3; symb_pos = k; break;
        case 'm': exp = - 3; symb_pos = k; break;
        case MUE: exp = - 6; symb_pos = k; break;
        case 'n': exp = - 9; symb_pos = k; break;
        case 'p': exp = -12; symb_pos = k; break;
        case 'f': exp = -15; symb_pos = k; break;
        case '.': symb_pos = k;            break;
        case '0':  /* Test der numer. Eingaben */   
        case '1':  case '2':  case '3':
        case '4':  case '5':  case '6':
        case '7':  case '8':  case '9':  break;
        default:  if (k == 0)   
                  { /* Wenn '-'Symbol an 1. Stelle    
                       gilt es nicht als falsch.   */   
                    if(eingabe[k]!='-')      
                    {    
                      error=TRUE;    
                      bell;    
                    }   
                  }   
                  else   
                  {   
                    error=TRUE;
                    bell;
                  }   
                   
      }    /* switch-Ende */   
    }      /* for - Ende  */   
  }   
  while(error==TRUE);
     
  /* Falls an Stelle des Kommas (Punkt) das    
     Symbol eingegeben wurde, wird dieses    
     durch das Komma zwecks Weiterverwertung    
     als Fliesskommazahl ersetzt.              */ 
        if(symb_pos<len)  eingabe[symb_pos] = '.';
   
  /* Convertierung des mit Kommastelle manipu-   
     lierten Eingabestrings in eine Double-   
     Floatingzahl mit Multiplikation auf korrek-   
     ten Wert.                                 */ 
   in = (atof(eingabe))*(pow10(exp));    
  return(in);              /* zur Verarbeitung */ 
}   

   
/* ------------------------------------------- */  
   

char *ausgabe(double in)   
{   
  int i, len, ndig, nk, dec, exp, dummy;
  char *out, s[CH_MAX];   
  char unit, vorz;
  
  exp    =  0;
  nk   =        6;      /* nk Nachkomm., wenn 3 Vorkomm. */
  ndig = nk + 3;
    
  
  if (in < 0)     /* Vorzeichen kehren bei ne- */   
  {               /* gativer Zahl.             */   
    in *= -1;
    vorz = '-';    /* Neg. Vorzeichen merken.  */   
  }   
  else   
  {   
    vorz = ' ';   /* Vorzeichen = Leerstelle   */ 
  }   
     

        if(in<(pow10(-15))-(1/1.8*(pow10(-18-nk))))     
  {
        bell;
        out = "Kleiner als 1 femto !";
  }
        else if(in>=(pow10(15))-(1/1.8*(pow10(12-nk)))) 
        {
                bell;
                out = "Gr”sser als 999.999... Tera !";  
        }
        else
        {
        if(in>=(pow10(12))-(1/1.8*(pow10(9-nk))))
        {   
        in += 1/1.8*(pow10(9-nk)); 
        exp = -12;     
        unit = 'T';
        }   
                else if(in>=(pow10(9))-(1/1.8*(pow10(6-nk))))
        {   
        in += 1/1.8*(pow10(6-nk)); 
        exp = -9;
        unit = 'G';
        }   
                else if(in>=(pow10(6))-(1/1.8*(pow10(3-nk))))
        {   
        in += 1/1.8*(pow10(3-nk)); 
        exp = -6;
        unit = 'M';
        }   
        else if(in>=(pow10(3))-(1/1.8*(pow10(0-nk))))  
        {   
                in += 1/1.8*(pow10(-nk));
        exp = -3;
        unit = 'k';     
        }   
        else if(in>=(pow10(0))-(1/1.8*(pow10(-3-nk))))
        {  
        in += 1/1.8*(pow10(-3-nk)); 
        exp = 0;
        unit = ' ';
        }   
        else if(in>=(pow10(-3))-(1/1.8*(pow10(-6-nk))))
        {   
        in += 1/1.8*(pow10(-6-nk)); 
        exp = 3;
                unit = 'm';
        }   
        else if(in>=(pow10(-6))-(1/1.8*(pow10(-9-nk))))
        { 
        in += 1/1.8*(pow10(-9-nk));  
        exp = 6;
        unit = MUE;
        }   
        else if(in>=(pow10(-9))-(1/1.8*(pow10(-12-nk))))
        {   
      in += 1/1.8*(pow10(-12-nk)); 
        exp = 9;
        unit = 'n';
        }   
        else if(in>=(pow10(-12))-(1/1.8*(pow10(-15-nk))))
        {  
      in += 1/1.8*(pow10(-15-nk)); 
        exp = 12;
        unit = 'p';
        }   
        else if(in>=(pow10(-15))-(1/1.8*(pow10(-18-nk))))   
        {   
        in += 1/1.8*(pow10(-18-nk)); 
        exp = 15;
        unit = 'f';
        }   

        in *= pow10(exp);   
        out = ecvt(in, ndig, &dec, &dummy);
              /* Double --> String - Convertierung */   
        len = (int)strlen(out);
        strcpy(s,out); 
 
        /* Nachkommastellen um eine Stelle 
        verschieben:                                                                                                                     */   
        for(i=dec; i<=len; i++) { s[i+1] = out[i]; }   
        s[dec] = '.';  /* Komma in neue Leerstelle */   
        s[len+1] = ' '; /*  Leerstelle vor Symbol  */   
        s[len+2] = unit; /* Gr”ssenordnungs-Symbol */ 
        s[len+3] = STREND;           /* Stringende */   
        len = (int)strlen(s); 
 
        /* String wegen Vorzeichen verschieben:    */ 
        strcpy(out,s);
        for(i=0; i<=len; i++)   { out[i+1] = s[i]; }   
        out[0] = vorz;
        }
  return(out);        /* Wert im Ausgabestring */   
}   
   

/* ------------------------------------------- */   
   

void get_s(char eingabe[])   
{   
  int key, i=0, j, ascii;
   
  do     
  {    
    catchkey();
    key = evnt_keybd();  /* Low-Byte  = ASCII 
                        High-Byte = Scan-Code  */   
    ascii = key & 0xff;/* ASCII-Code ermitteln */   
    if((key>>8) == F1)  ascii = MUE;
   
    if(ascii==ESC||ascii==BACKSP||ascii == CR|| 
      (ascii>31 && ascii<256))   
    {       
      if(i<CH_MAX && ascii!=BACKSP)   
      {   
        printf("%c",ascii);
        eingabe[i] = ascii;
        i++;
        if(i==CH_MAX) { blank; }/* Zeichen weg */   
      }   
      else if(i>0 && i<=CH_MAX && ascii==BACKSP) 
      {     
        eingabe[i]=0;
        if(i==CH_MAX)    i--;
        i--;     
        blank;    
      }   
           
      if(ascii==ESC)     
      {   
        Cconout(0); /* 'Esc' neutralisieren */   
        j = i;
        if(i<CH_MAX)  i--;
        while(i>1)       { backspace; i--; }   
        if(j>1 && j<CH_MAX)    { backspace; } 
        cl_eol;
        i = 0;    
        bell;
      }   
    }     
  }     
  while(ascii!=CR);
     
  eingabe[i-1] = STREND;    /* Null-Stringende */   
  puts("");                 /* Return                            */   
}   

/* ------------------------------------------- */   
 
   
void catchkey(void)   /* Tastaturpuffer leeren */   
{   
  int k;
   
  do   
  {   
    k = (int)Cconis();     
    if(k==TRUE)  Crawcin();     
  }   
  while(k==TRUE);
}   
   
   
/*  ############### E N D E ################# */ 
   
