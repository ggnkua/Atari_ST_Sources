/* DRV_INF - gibt schnelle Drive-Info aus
   written 12/90 by FF, zun„chst in GFA, dann in TC bertragen
   neue Version 2.0 written 05/91 by FF
   hinzugekommen ist :
   Integration der Wochentagsausgabe (DATETEST.ACC)
   Ermittlung des freien Rechnerspeichers auch fr TT 
   nur bei Disketten:
   Ermittlung des Diskettenformates (dafr Erweiterung von TOS.H)
   Prfung des Disketten-Bootsektors auf Ausfhrbarkeit
   Stackgr”že >>> 2176 <<< Bytes
   Last Update : 31.05.91
*/

#include <aes.h>
#include "tos.h"
#include <string.h>
#include <stdlib.h>
#include <ext.h>
#include <ctype.h>

#define ETV_CRITIC  0x404L
#define conterm		((char *)0x484)
#define TRUE		1
#define FALSE		0

extern  int _app;
int     msg_buf[8];
int     ap_id, menu_id;
char    drv[17];
int     drv_anz;
struct  date datum;
char 	info_alert[170];

extern	void *Mxalloc(long amount, int mode);

void drv_array(void);
int  drive_info(void);
int  mem_info(void);
char *wochentag(void);
void info(void);
void hauptprogramm(void);
void main(void);

void drv_array(void)
{
    long _drvbits;
    int i;
    
    drv_anz = 0;
    _drvbits = Drvmap();
    for (i=0; i<=15; i++)
    {
        if ((_drvbits >> i) & 1)
            drv[drv_anz++] = i+65;
    }
    drv_anz--;
}

int drive_info(void)
{
    static int i;
    int wahl, weiter;
    long total, platz, belegt;
    DISKINFO diskinfo;
    char alert1[] = "[2][ |  Welches Laufwerk ?  ][ << |A|>>]";
    char alert2[] = "[1][  Info ber Laufwerk A :|            "
    				"Bytes Kapazit„t  |            Bytes belegt|"
    				"            Bytes frei|  Diskformat  x  x    ]"
    				"[Beenden|Nochmal|Memory]";
    char alert3[] = "[1][ | Daten von Laufwerk A: konnten|"
    				" nicht ermittelt werden !][Beenden|Nochmal|Memory]";
    char alles[10];
    char voll[10];
    char frei[10];
    
    char sides[2];
    char tracks[3];
    char sectors[3];
    BPB *bpb;
    int *boot_puffer, lauf;
    long erg, boot_erg, boot_summe;
    
    int rts=0x4e75; /* RTS-Opcode                       */
    long *temp,     /* tempor„rer Zeiger auf alten CEH  */
        save_ssp,   /* tempor„rer Zeiger auf alten SSP  */
        critic_value;   /* alter Wert des CEH           */
    char conterm_value; /* alter Wert von >conterm<		*/
    
    do
    {
        alert1[35] = drv[i];
        wahl = form_alert(2,alert1);
        if (wahl == 1)
        {
            if (i == 0)
                i = drv_anz;
            else
                i--;
        }
        else if (wahl == 3)
        {
            if (i == drv_anz)
                i = 0;
            else
                i++;
        }                       
    } while (wahl != 2);
    
    /* Critical-Error Handler auf RTS umh„ngen */
    save_ssp=(long)Super(0L);
    temp=(long*)ETV_CRITIC;
    critic_value=*temp;
    *temp=(long)&rts;
    Super((char*)save_ssp);
    
    erg = Dfree(&diskinfo, drv[i]-64);
	if (erg == 0)
	{
		weiter = TRUE;
		if (i <= 1)		/* bei Disketten BPB ermitteln */
		{				/* und Bootsektor einlesen	   */	
		    bpb = Getbpb(drv[i] - 65);
		    if (bpb > 0)
		    {
		    	weiter = TRUE;
		    	/* Platz fr Bootsektor-Puffer reservieren */
		    	boot_puffer = (int *) calloc(bpb->recsiz/2, sizeof(int));
		    	boot_erg = Rwabs(0, boot_puffer, 1, 0, i);
		    	if (boot_erg == 0)
		    		weiter = TRUE;
		    	else
		    		weiter = FALSE;	
		    }
		    else
		    	weiter = FALSE;		
		}
	}
	else
		weiter = FALSE;    
    
    /* Critical-Error Handler auf alten Wert setzen */
    save_ssp=(long)Super(0L);
    temp=(long*)ETV_CRITIC;
    *temp=critic_value;
    Super((char*)save_ssp);
    
    if (weiter == TRUE)
    {
        total = diskinfo.b_total*diskinfo.b_secsiz*diskinfo.b_clsiz;
        platz = diskinfo.b_free*diskinfo.b_secsiz*diskinfo.b_clsiz;
        belegt = total-platz;
        ltoa(total, alles, 10);
        ltoa(belegt, voll, 10);
        ltoa(platz, frei, 10);
        alert2[25] = drv[i];
        memcpy(&(alert2[40-strlen(alles)]),alles,strlen(alles));
        memcpy(&(alert2[70-strlen(voll)]),voll,strlen(voll));
        memcpy(&(alert2[95-strlen(frei)]),frei,strlen(frei));
		if (i <= 1)
		{	
	        itoa(bpb->dnsides, sides, 10);
    	    itoa(bpb->dntracks, tracks, 10);
	        itoa(bpb->dnspt, sectors, 10);
	        memcpy(&(alert2[120]), sides, 1);        
	        memcpy(&(alert2[124-strlen(tracks)]), tracks, strlen(tracks));
	        memcpy(&(alert2[125]), sectors, strlen(sectors));
			boot_summe = 0;
			for (lauf = 0; lauf < bpb->recsiz/2; lauf++)
				boot_summe += *(boot_puffer+lauf);
			boot_summe &= 0xFFFF;
			if (boot_summe == 0x1234)
			{
				memcpy(&(alert2[126+strlen(sectors)]), "\b", 1);
    			save_ssp=(long)Super(0L);
			    conterm_value = *conterm;	/* alten Wert von conterm merken */
			    *conterm |= 4;				/* Glocke einschalten */
			    Super((char*)save_ssp);
      			putch(7);
				delay(150);
				putch(7);
				delay(150);
				putch(7);
    			save_ssp=(long)Super(0L);
    			*conterm = conterm_value;	/* alten Wert zurck */
			    Super((char*)save_ssp);
			}
        }
		else
			memcpy(&(alert2[109]), "                ", 16);
			
        return (form_alert(1,alert2));
    }
    else
    {
        alert3[26] = drv[i];
        return (form_alert(1,alert3));
    }   
}       

int mem_info(void)
{
    int  st_counter = 0;
    int  tt_counter = 0;
    long st_speicher = 0;
    long tt_speicher = 0;
    char st_block[9], st_alles[9], st_anz[4];
    char tt_block[9], tt_alles[9], tt_anz[4];
    char bloecke[9],  allesse[9],  anze[4];
    long *zeiger, *adressen[300];
    char st_alert[]= "[1][  L„nge des gr”žten freien|  Blocks   :"
    			  "          Bytes|  Ges. frei:          Bytes|"
    			  "  (000 freie Speicherbl”cke)  ][Beenden|Drive|TT-Ram?]";

    char tt_alert[]= "[1][  L„nge des gr”žten freien|  Blocks   :"
    			  "          Bytes|  Ges. frei:          Bytes|"
    			  "  (000 freie Speicherbl”cke)  ][Beenden|Drive|Insges.]";
    			  
    char insges[]  = "[1][  L„nge der gr”žten freien|  Bl”cke   :"
    			  "          Bytes|  Ges. frei:          Bytes|"
    			  "  (000 freie Speicherbl”cke)  ][Beenden|Drive]";
    			  
    char kein_tt[] = "[1][ |  Sie haben wohl gar  |"
    				 "  keinen TT ?!][Beenden|Drive]";
    
    int st_back, tt_back;
    
    zeiger = Malloc(-1L);
    ltoa((long) zeiger, st_block, 10);
    
    while ((long) Malloc(-1L) > 0)
    {
        zeiger = Malloc (-1L);
        adressen[st_counter++] = Malloc((long) zeiger);
        st_speicher += (long) zeiger;
    }
    ltoa(st_speicher, st_alles, 10);
    itoa(st_counter, st_anz, 10);
    
    while (st_counter)
        Mfree(adressen[--st_counter]); 

    memcpy(&(st_alert[52-strlen(st_block)]),st_block,strlen(st_block));
    memcpy(&(st_alert[80-strlen(st_alles)]),st_alles,strlen(st_alles));
    memcpy(&(st_alert[93-strlen(st_anz)]),st_anz,strlen(st_anz));
        
    st_back = form_alert(1,st_alert);
    
    if (st_back == 3)
    {
	    zeiger = Mxalloc(-1L, 1);
		if ((long) zeiger == -32)
		{
			return (form_alert(1, kein_tt));
		}
		else
	    {
		    ltoa((long) zeiger, tt_block, 10);
		    
		    while ((long) Mxalloc(-1L, 1) > 0)
		    {
		        zeiger = Mxalloc (-1L, 1);
		        adressen[tt_counter++] = Mxalloc((long) zeiger, 1);
		        tt_speicher += (long) zeiger;
		    }
		    ltoa(tt_speicher, tt_alles, 10);
		    itoa(tt_counter, tt_anz, 10);
		    
		    while (tt_counter)
		        Mfree(adressen[--tt_counter]); 
		
		    memcpy(&(tt_alert[52-strlen(tt_block)]),tt_block,strlen(tt_block));
		    memcpy(&(tt_alert[80-strlen(tt_alles)]),tt_alles,strlen(tt_alles));
 		    memcpy(&(tt_alert[93-strlen(tt_anz)]),tt_anz,strlen(tt_anz));
		        
		    tt_back = form_alert(1,tt_alert);
		    if (tt_back == 3)
		    {
    			ltoa((atol(st_block)+atol(tt_block)), bloecke, 10);
    			ltoa((st_speicher+tt_speicher), allesse, 10);
    			ltoa((atol(st_anz)+atol(tt_anz)), anze, 10);
			    memcpy(&(insges[52-strlen(bloecke)]),bloecke,strlen(bloecke));
			    memcpy(&(insges[80-strlen(allesse)]),allesse,strlen(allesse));
			    memcpy(&(insges[93-strlen(anze)]),anze,strlen(anze));
			    
			    return (form_alert(1, insges));
		    }
		    else
		    	return (tt_back);    
	    }
    }
    else
    	return (st_back);
}

char *wochentag(void)
{
    char *wt[]   = { "Montag", "Dienstag", "Mittwoch", "Donnerstag",
                     "Freitag", "Samstag", "Sonntag" };
    int  mt[12]  = { 31,28,31,30,31,30,31,31,30,31,30,31 };
    
    int t, m, j, tage, z;             
    
    t = datum.da_day;
    m = datum.da_mon;
    j = datum.da_year;
    
    tage = t;
    
    if ((m > 2) && ((j % 4) == 0))
    	tage++;
    
    for (z=0; z < (m-1); z++)
    	tage += mt[z];	
    	
    for (z=1992; z <= j; z++)
    {
    	tage += 365;
    	if ((z % 4) == 0)
    		tage++;
    }
    
	return (wt[tage % 7]);
}

void info(void)
{
	char tag[3];
	char monat[3];
	char jahr[5];

	strcpy(info_alert,"[1][ DRV_MEM 2.0 - Acc oder Prg,  |"
		   			  "    written 03/91 by FF,|"
		   			  "    using TURBO C 2.03.|");
	getdate(&datum);
	itoa(datum.da_year, jahr, 10);
	if (datum.da_year >= 1991)
	{
		itoa(toascii(datum.da_day), tag, 10);
		itoa(toascii(datum.da_mon), monat, 10);
		strcat(info_alert," Heute ist der ");
		if (strlen(tag) == 1)
			strcat(info_alert, "0");
		strcat(info_alert, tag);
		strcat(info_alert, ".");
		if (strlen(monat) == 1)
			strcat(info_alert, "0");
		strcat(info_alert, monat);
		strcat(info_alert, ".");
		strcat(info_alert, jahr);
		strcat(info_alert, ",| das ist ein >> ");
		strcat(info_alert, wochentag());
		strcat(info_alert, " <<.][Jaja|Abbruch]");
	}
	else
		strcat(info_alert, "  Sie haben ein falsches|"
						   "  Jahr eingegeben !][Ach|Abbruch]");
}

void hauptprogramm(void)
{
    int back, drv_back, mem_back, inf_back;
    char alert[] = "[2][ | Wo soll freier Speicherplatz |"
    			   " ermittelt werden ?][Drive| Memory |Info]";
    			   
    drv_array();
   	info();
    drv_back = mem_back = inf_back = 0;
    do
    {
        back = form_alert(0,alert);
        if (back == 3)
            inf_back = form_alert(1,info_alert);
    } while ((back == 3) && (inf_back == 1));        
    if (inf_back <= 1)
	    {
	    do
	    {
	        if ((back == 1) || (mem_back == 2))
	        {
	            do
	            {
	                drv_back = drive_info();
	            } while (drv_back == 2);
	        }
	        if ((back == 2) || (drv_back == 3))
	            mem_back = mem_info();
	        back = 0;   
	    } while ((drv_back != 1) && (mem_back != 1));       
    }
}

void main(void)
{
    ap_id = appl_init();
    if (ap_id != -1)
    {
        if (!_app)
        {
            menu_id = menu_register(ap_id, "  Drive&Mem-Info");
            while (1)
            {
                evnt_mesag(msg_buf);
                if (msg_buf[0] == AC_OPEN)
                {
                	wind_update(BEG_UPDATE);
                	wind_update(BEG_MCTRL);
                	hauptprogramm();
                	wind_update(END_MCTRL);
                	wind_update(END_UPDATE);
                }	
            }
        }   
        else
        { 
        	wind_update(BEG_UPDATE);
        	wind_update(BEG_MCTRL);
        	hauptprogramm();
        	wind_update(END_MCTRL);
        	wind_update(END_UPDATE);
            appl_exit();
        }
    }    
}
