#include <stdio.h>
#include <stdlib.h>

#include "portab.h"
#include "vars.h"

void FASTsave (MSGHEADER *Hdr, BYTE *msg, WORD area) {
	BYTE Hfile [128],
		  Mfile [128],
		  buffer[128];
		  
	WORD	i,
			tofile,
			attrib;
	
	struct ffblk blk;
	
	FILE *Mfp, *Hfp;
	
	Hdr->mailer[7] |= SCANNED;
	Hdr->flags &=~(DELETED);

	/*
	**	Bekijk of deze area al geopend is. Als deze area geopend is
	**	dan kan er gewoon doorgegaan worden zonder dat er een nieuwe
	**	area geopend dient te worden.
	*/
	
	for (i=0; i < N_FASTAREAS; i++) {
		if (lastareawritten[i] == area) {
			tofile = i;
			break;
		}
	}
	
	/*
	**	Als er nog geen geopende file bestaat voor deze area,
	**	kijk dan of er nog gesloten kanalen zijn die geopend kunnen
	**	worden.
	*/
	
	if (i >= N_FASTAREAS) {
		for (i=0; i < N_FASTAREAS; i++) {
			if (LHDRfile[i] == FILEclosed &&
				LMSGfile[i] == FILEclosed)
			{
			
			/*
			**	Er bestaat nog een gesloten kanaal waar deze area
			**	gebruik van kan maken.
			*/
			
				tofile = i;

				LHDRfile[i] = FILEopen;
				LMSGfile[i] = FILEopen;
				lastareawritten[i] = area;

				sprintf (Mfile, "%s.MSG", Areapath [area] );
				
				if (findfirst (Mfile, &bkl, 0)) {
					Hdr ->Mstart = 0L;
				} else {
					Hdr->Mstart = blk.ff_fsize;
				}
				
				/*
				**	Alloc geheugen voor deze area.
				*/

				h_Mstart[i] = Hdr->Mstart;
/*				h_Mstart[i] += (ULONG)Hdr->size; */
				if (!h_one_item)
					h_one_item = ((coreleft() / N_FASTTOTAL) / 2560 * 2048);


#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Alloc h_headerbuf[%d]",i);
			log_line(6,">Alloc h_msgbuf[%d]",i);
			log_line(6,">Memory %ld", coreleft());
		}
#endif
				h_headerbuf[i] = (BYTE *)myalloc(h_one_item);
				h_msgbuf[i] = (BYTE *)myalloc(h_one_item);
				h_headeritems[i] = 0L;
				h_msgitems[i] = 0L;
				h_maxheader[i] = h_one_item;
				h_maxmsg[i] = h_one_item;
				break;
			}
		}

	/*
	**	Als er geen gesloten kanalen meer te vinden zijn,
	**	sluit dan een kanaal. Eerst dient dit kanaal weggeschreven
	**	te worden naar de area op disk waar deze zich bevind.
	*/
	
		if ( i >= N_FASTAREAS) {
			sprintf(Hfile, "%s.HDR", Areapath[ lastwrittenarea[0] ] );
			sprintf(Mfile, "%s.MSG", Areapath[ lastwrittenarea[0] ] );
	
		/*
		**	Open het kanaal voor deze area.
		*/
	
			if ((Hfp = fopen (Hfile, "r+b")) == NULL) {
				if ((Hfp = fopen (Hfile, "wb")) == NULL) {
					log_line(5,Logmessage[M__CANT_OPEN_HEADER], Mfile);
					terminate (10);
				}
			} else {
				fseek (Hfp, 0L, SEEK_END);
			}
			
			if ((Mfp = fopen (Mfile, "R+b")) == NULL) {
				if ((Mfp = fopen (Mfile, "wb")) == NULL) {
					log_line(5,Logmessage[M__CANT_OPEN_HEADER], Mfile);
					terminate (10);
				}
			} else {
				fseek (Mfp, 0L, SEEK_END)
			}
	
		/*
		**	Schrijf de inhoud van het geheugengebied welke door deze
		**	area is gebruikt op disk.
		*/
				
			Fwrite(fileno (Hfp), h_headeritems[0], h_headerbuf[0]);
			Fwrite(fileno (Mfp), h_msgitems[0], h_msgbuf[0]);
			h_headeritems[0] = 0L;
			h_msgitems[0] = 0L;
	
			fclose (Mfp);
			fclose (Hfp);
	
		/*
		**	Zet de attributen voor deze area, zodat deze niet opnieuw
		**	gescand zal worden door IOSmail.
		*/
		
			attr = Fattrib(Hfile, 0, -1);
	
			if (attr != -33 && attr != -34 && attr & FA_ARCHIVE)
			{
				if (intel (Sversion()) >= 0x0015U)
					Fattrib (fbuf, 1, 0);
				else
					Fattrib (Hfile, 1, FA_ARCHIVE);
			}
	
		/*
		**	Zet het areanummer op 0.
		*/
					
			tofile = 0;
			lastareawritten[0] = area;
	
		/*
		**	Reset de waarden zodat er opnieuw begonnen kan worden.
		*/
	
			h_Mstart[0] = Hdr->Mstart;
			h_Mstart[0] += (ULONG)Hdr->size;
	
		}
	}

	Hdr->Mstart = h_Mstart [tofile];
	h_Mstart += Hdr->size;

	addhdrbuf(Hdr, (UWORD)sizeof(MSGHEADER), tofile);
	addmsgbuf(msg, (UWORD)strlen(msg), tofile);
}
