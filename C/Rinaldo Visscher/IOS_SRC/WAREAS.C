/*********************************************************************

					IOS - areas reader
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	This part contains,
	
	Read AREAS.BIN and parse it.
	
*********************************************************************/


#include		<stdio.h>
#include		<stdlib.h>

#if !defined LATTICE
#include		<ext.h>
#include		<tos.h>
#else
#include		<dos.h>
#include		<sys/stat.h>
#endif
#include		<string.h>

#include		"portab.h"

#include		"defs.h"
#include		"ioslib.h"
#include		"modules.h"

#include		"inmail.h"
#include		"strutil.h"
#include		"lang.h"

#include		"vars.h"

/*
**	Give every binairy areas.bbs an version number. Versie 0.85
*/

#define	BINVERSION	0x0059U

MLOCAL BYTE *get_frombin(VOID);
MLOCAL CONST BYTE *MAILarea = "MAIL";
MLOCAL CONST BYTE *TRASHarea= "TRASHAREA";
MLOCAL CONST BYTE *PVTarea  = "PRIVATEMAIL";
MLOCAL CONST BYTE *DUPEarea = "DUPE_AREA";

VOID uncompile() {
	UWORD 	i, j, z,
			zone, net, node, point;
	
	BYTE Odomain[12];
	
	if ((FDUMMY = fopen("AREAS.UNC", "w")) == NULL) {
		log_line(6, Logmessage[M__CANT_MAKE_UNCOM]);
		return;
	}

	fprintf(FDUMMY, "%s\n", Mainorg);
	
	for (i = 0; i < msgareas; i++) {
		if (Dareas[i]) break;
		
		if (Areaday[i])
			fprintf(FDUMMY, "-Days %d\n", Areaday[i]);
		
		if (Ausername[i]) 
			fprintf(FDUMMY, "-Name %s\n", Ausername[i]);
		
		if (Areamin[i]) 
			fprintf(FDUMMY, "-Msgs %d\n", Areamin[i]);

		if (Areakeep[i] == KEEPMSGS)
			fprintf(FDUMMY, "-Keep\n");

		if (Areagroup[i])
			fprintf(FDUMMY, "-Group %c\n", Areagroup[i]);
		
		if (strcmp(Areaorg[i], Mainorg))
			fprintf(FDUMMY, "-Origin %s\n", Areaorg[i]);
		
		if (Randorgfile[i])
			fprintf(FDUMMY, "-File %s\n", Randorgfile[i]);
			
		if (Read_only[i] == READ_ONLY) 
			fprintf(FDUMMY, "-Local\n");
		else if (Read_only[i] == REMOTE_ONLY)
			fprintf(FDUMMY, "-Remote %s\n", ROnode[i]);
		
		fprintf(FDUMMY, "%s ", Areapath[i]);
		fprintf(FDUMMY, "%s ", Areaname[i]);
		
		zone = Tozone[i][0];
		net  = Tonet[i][0];
		node = Tonode[i][0];
		point= Topoint[i][0];
		
		if (zone == (UWORD) -1) {
			fprintf(FDUMMY, "\n");
			continue;
		}
		
		fprintf(FDUMMY, "%u:%u/%u.%u", zone, net, node, point);
		
		if (strlen (Todomain[i])) {
			fprintf (FDUMMY, "@%s", Todomain[i]);
		}
		
		for (j=1; Tozone[i][j] != (UWORD) -1; j++) {
			if (zone == Tozone[i][j] &&
				net  == Tonet[i][j] &&
				node == Tonode[i][j]) {
				
				fprintf(FDUMMY," .%u", Topoint[i][j]);
				continue;
			}
			
			zone = Tozone[i][j];
			net  = Tonet[i][j];
			node = Tonode[i][j];
			point= Topoint[i][j];
	
			fprintf(FDUMMY, " %u:%u/%u.%u", zone, net, node, point);
		}
		fprintf(FDUMMY, "\n");
	}

	if (strlen(mailarea)) 
	{
		fprintf(FDUMMY, "-Days %d\n", maildays);
		fprintf(FDUMMY, "-Msgs %d\n", mailmin);
		if (mailkeep == KEEPMSGS)
			fprintf(FDUMMY, "-Keep\n");
		
		fprintf(FDUMMY, "%s MAIL\n", mailarea);
	}
	
	if (strlen(privatebox))
	{
		fprintf(FDUMMY, "-Days %d\n", pvtboxdays);
		fprintf(FDUMMY, "-Msgs %d\n", pvtboxmin);
		if (pvtkeep == KEEPMSGS)
			fprintf(FDUMMY, "-Keep\n");
			
		fprintf(FDUMMY, "%s PRIVATEBOXAREA\n", privatebox);
	}

	if (strlen(trasharea))
	{
		fprintf(FDUMMY, "-Days %d\n", trashdays);
		fprintf(FDUMMY, "-Msgs %d\n", trashmin);
		if (trashkeep == KEEPMSGS)
			fprintf(FDUMMY, "-Keep\n");
			
		fprintf(FDUMMY, "%s TRASHAREA\n", trasharea);
	}

	if (strlen(dupearea))
	{
		fprintf(FDUMMY, "-Days %d\n", dupedays);
		fprintf(FDUMMY, "-Msgs %d\n", dupemin);
		if (dupekeep == KEEPMSGS)
			fprintf(FDUMMY, "-Keep\n");
			
		fprintf(FDUMMY, "%s DUPE_AREA\n", dupearea);
	}
		
	fclose(FDUMMY);

	if (i >= msgareas) return;
	
	if ((FDUMMY = fopen("DAREAS.UNC", "w")) == NULL) {
		log_line(6, Logmessage[M__CANT_CREATE_PASSTR]);
		return;
	}
	
	for (z = i; z < msgareas; z++) {
		if (Areagroup[z])
			fprintf (FDUMMY, "-Group %c\n", Areagroup[z]);

		fprintf(FDUMMY, "%s ", Areaname[z]);
		
		zone = Tozone[z][0];
		net  = Tonet[z][0];
		node = Tonode[z][0];
		point= Topoint[z][0];
		
		if (zone == (UWORD) -1) {
			fprintf(FDUMMY, "\n");
			continue;
		}
		
		fprintf(FDUMMY, "%u:%u/%u.%u", zone, net, node, point);
		
		if (strlen (Todomain [z]))
			fprintf (FDUMMY, "@%s", Todomain[z]);
		
		for (j=1; Tozone[z][j] != (UWORD) -1; j++) {
			if (zone == Tozone[z][j] &&
				net  == Tonet[z][j] &&
				node == Tonode[z][j]) {
				
				fprintf(FDUMMY," .%u", Topoint[z][j]);
				continue;
			}
			
			zone = Tozone[z][j];
			net  = Tonet[z][j];
			node = Tonode[z][j];
			point= Topoint[z][j];
	
			fprintf(FDUMMY, " %u:%u/%u.%u", zone, net, node, point);
		}
		fprintf(FDUMMY, "\n");
	}
	fclose(FDUMMY);
}
	
VOID write_bin_areas() {
	UWORD i, j;
	BYTE buf1[128], buf2[128], *q;
	struct ffblk blok;
	
	if (!findfirst(BIN_AREAS, &blok, 0)) {
		strcpy (buf1, BIN_AREAS);
		strcpy (buf2, BIN_AREAS);
		if ((q = strrchr(buf2, '.')) != NULL) {
			strcpy (++q, "DUP");
			if (!findfirst (buf2, &blok, 0)) {
				unlink (buf2);
			}
			if (rename (buf1, buf2) != 0) {
				log_line(6, Logmessage[M__CANT_CREATE_BINAIR], BIN_AREAS);
				return;
			}
		}
	}
	
	if ((FDUMMY = fopen (BIN_AREAS, "wb")) == NULL) {
		log_line(6, Logmessage[M__CANT_CREATE_BINAIR], BIN_AREAS);
		return;
	}

	j = BINVERSION;
	
	fwrite(&j, sizeof(UWORD), 1, FDUMMY);
	
	giveTIMEslice();

	fprintf(FDUMMY, Mainorg);
	putc(0, FDUMMY);
	
	for (i=0; i< msgareas; i++) {
		fprintf(FDUMMY, "%s", Areaname[i]);
		putc(0,FDUMMY);

		if (strlen(Todomain [i]))
			fprintf (FDUMMY, "%s", Todomain [i]);
		
		putc (0, FDUMMY);
		
		fwrite (&Areagroup[i], sizeof(BYTE), 1, FDUMMY);

		fwrite (&Dareas[i], sizeof(WORD), 1, FDUMMY);

		if (Dareas[i]) goto write_nodes;
		
		fprintf(FDUMMY, "%s", Areapath[i]);
		putc(0, FDUMMY);

		if (strcmp(Areaorg[i], Mainorg)) 
			fprintf(FDUMMY, "%s", Areaorg[i]);
		putc(0, FDUMMY);
		
		if (Ausername[i])
			fprintf(FDUMMY, Ausername[i]);
		putc(0, FDUMMY);
		
		if (Randorgfile[i])
			fprintf(FDUMMY, Randorgfile[i]);
		putc(0, FDUMMY);
		
		giveTIMEslice();
		
		fwrite (&Areaday[i], sizeof(WORD), 1, FDUMMY);
		fwrite (&Areamin[i], sizeof(WORD), 1, FDUMMY);
		
		fwrite (&Areakeep[i], sizeof(BYTE), 1, FDUMMY);

		fwrite (&Read_only[i], sizeof(BOOLEAN), 1, FDUMMY);

		giveTIMEslice();
		
		if (Read_only[i] == REMOTE_ONLY) {
			fprintf(FDUMMY, "%s", ROnode[i]);
			putc(0, FDUMMY);
		}
		
		write_nodes:
		
		for (j=0; Tozone[i][j] != (UWORD) -1; j++) {
			fwrite(&Tozone[i][j], sizeof(UWORD), 1, FDUMMY);
			fwrite(&Tonet[i][j], sizeof(UWORD), 1, FDUMMY);
			fwrite(&Tonode[i][j], sizeof(UWORD), 1, FDUMMY);
			fwrite(&Topoint[i][j], sizeof(UWORD), 1, FDUMMY);
			giveTIMEslice();
		}
		j = (UWORD) -1;
		fwrite(&j, sizeof(UWORD), 1, FDUMMY);
	}

	giveTIMEslice();
	
	j = 0;
	
	if (strlen(mailarea)) {
		fprintf(FDUMMY, MAILarea);
		putc(0, FDUMMY);
		putc(0, FDUMMY);
		putc(0, FDUMMY);
		fwrite(&j, sizeof(WORD), 1, FDUMMY);
		fprintf(FDUMMY, mailarea);
		putc(0, FDUMMY);
		fwrite(&maildays, sizeof(WORD), 1, FDUMMY);
		fwrite(&mailmin, sizeof(WORD), 1, FDUMMY);
		fwrite(&mailkeep, sizeof(BYTE), 1, FDUMMY);
	}
	
	if (strlen(trasharea)) {
		fprintf(FDUMMY, TRASHarea);
		putc(0, FDUMMY);
		putc(0, FDUMMY);
		putc(0, FDUMMY);
		fwrite(&j, sizeof(WORD), 1, FDUMMY);
		fprintf(FDUMMY, trasharea);
		putc(0, FDUMMY);
		fwrite(&trashdays, sizeof(WORD), 1, FDUMMY);
		fwrite(&trashmin, sizeof(WORD), 1,FDUMMY);
		fwrite(&trashkeep, sizeof(BYTE), 1, FDUMMY);
	}
	
	if (strlen(privatebox)) {
		fprintf(FDUMMY, PVTarea);
		putc(0, FDUMMY);
		putc(0, FDUMMY);
		putc(0, FDUMMY);
		fwrite(&j, sizeof(WORD), 1, FDUMMY);
		fprintf(FDUMMY, privatebox);
		putc(0, FDUMMY);
		fwrite(&pvtboxdays, sizeof(WORD), 1, FDUMMY);
		fwrite(&pvtboxmin, sizeof(WORD), 1, FDUMMY);
		fwrite(&pvtkeep, sizeof(BYTE), 1, FDUMMY);
	}

	if (strlen(dupearea)) {
		fprintf(FDUMMY, DUPEarea);
		putc(0, FDUMMY);
		putc(0, FDUMMY);
		putc(0, FDUMMY);
		fwrite(&j, sizeof(WORD), 1, FDUMMY);
		fprintf(FDUMMY, dupearea);
		putc(0, FDUMMY);
		fwrite(&dupedays, sizeof(WORD), 1, FDUMMY);
		fwrite(&dupemin, sizeof(WORD), 1, FDUMMY);
		fwrite(&dupekeep, sizeof(BYTE), 1, FDUMMY);
	}

	fclose(FDUMMY);
	
}

MLOCAL BYTE *get_frombin() {
	MLOCAL BYTE buffer[1024];
	BYTE		*p;
	WORD		j;
	
	p = buffer;
	
	while(1) {
		j = getc(FDUMMY);
		if(feof(FDUMMY)) return (NULL);
		
		if (!j)
		break;
		
		*p++ = (BYTE)j;
	}
	
	*p = EOS;
	
	return (buffer);
}

BOOLEAN read_bin_areas() {
	UWORD i, j;
	BYTE *buffer;
	
	if ((FDUMMY = fopen (BIN_AREAS, "rb")) == NULL) {
		if (!read_areas(AREAFILE, 0)) {
			log_line(6, Logmessage[M__CANT_OPEN], BIN_AREAS);
			exit (10);
		}
		read_areas (DAREAFILE, 1);
		write_bin_areas();
		if ((FDUMMY = fopen (BIN_AREAS, "rb")) == NULL) {
			log_line(6, Logmessage[M__CANT_OPEN], BIN_AREAS);
			return (FALSE);
		}
	}
	
	fread(&j, sizeof(UWORD), 1, FDUMMY);
	
	if (j != BINVERSION) {
		log_line(6, Logmessage[M__RECOMPILE_AREAS], j, BINVERSION);
		fclose (FDUMMY);
		return (FALSE);
	}
	
	buffer = get_frombin();
	Mainorg = ctl_string(buffer);
	
	while(!feof(FDUMMY)) {

		giveTIMEslice();
		
		buffer = get_frombin();
		if (!buffer) break;
		
		Areaname[msgareas] = ctl_string(buffer);

		giveTIMEslice();

		buffer = get_frombin();
		if (!buffer) break;
		strcpy (Todomain[msgareas], buffer);
		
		fread(&Areagroup[msgareas], sizeof(BYTE), 1, FDUMMY);

		fread(&Dareas[msgareas], sizeof(WORD),  1, FDUMMY);
		
		Read_only[msgareas] = PUBLIC;
		
		if (Dareas[msgareas]) goto read_nodes;
		
		buffer = get_frombin();
		if (!buffer) break;
		
		Areapath[msgareas] = ctl_string(buffer);

		giveTIMEslice();
		
		if (!strcmp(Areaname[msgareas], MAILarea)) {
			free(Areaname[msgareas]);
			free(Areapath[msgareas]);
			mailarea = ctl_string(buffer);
			fread(&maildays, sizeof(WORD), 1, FDUMMY);
			fread(&mailmin, sizeof(WORD), 1, FDUMMY);
			fread(&mailkeep, sizeof(BYTE), 1, FDUMMY);
			continue;
		}
		
		if (!strcmp(Areaname[msgareas], TRASHarea)) {
			free(Areaname[msgareas]);
			free(Areapath[msgareas]);
			trasharea = ctl_string(buffer);
			fread(&trashdays, sizeof(WORD), 1, FDUMMY);
			fread(&trashmin, sizeof(WORD), 1, FDUMMY);
			fread(&trashkeep, sizeof(BYTE), 1, FDUMMY);
			continue;
		}

		if (!strcmp(Areaname[msgareas], PVTarea)) {
			free(Areaname[msgareas]);
			free(Areapath[msgareas]);
			privatebox = ctl_string(buffer);
			fread(&pvtboxdays, sizeof(WORD), 1, FDUMMY);
			fread(&pvtboxmin, sizeof(WORD), 1, FDUMMY);
			fread(&pvtkeep, sizeof(BYTE), 1, FDUMMY);
			continue;
		}

		if (!strcmp(Areaname[msgareas], DUPEarea)) {
			free(Areaname[msgareas]);
			free(Areapath[msgareas]);
			dupearea = ctl_string(buffer);
			fread(&dupedays, sizeof(WORD), 1, FDUMMY);
			fread(&dupemin, sizeof(WORD), 1, FDUMMY);
			fread(&dupekeep, sizeof(BYTE), 1, FDUMMY);
			continue;
		}

		buffer = get_frombin();
		if (!buffer) break;
		
		if (!strlen(buffer)) {
			Areaorg[msgareas] = ctl_string(Mainorg);
		} else {
			Areaorg[msgareas] = ctl_string(buffer);
		}
		
		giveTIMEslice();

		buffer = get_frombin();
		if (!buffer) break;
		
		if (!strlen(buffer)) {
			Ausername[msgareas] = NULL;
		} else {
			Ausername[msgareas] = ctl_string(buffer);
		}
		
		giveTIMEslice();
		
		buffer = get_frombin();
		if (!strlen(buffer)) {
			Randorgfile[msgareas] = NULL;
		} else {
			Randorgfile[msgareas] = ctl_file(buffer);
		}
		
		fread(&Areaday[msgareas], sizeof(WORD), 1, FDUMMY);
		fread(&Areamin[msgareas], sizeof(WORD), 1, FDUMMY);
		
		fread(&Areakeep[msgareas], sizeof(BYTE), 1, FDUMMY);
		
		fread(&Read_only[msgareas], sizeof(BOOLEAN), 1, FDUMMY);
		
		giveTIMEslice();
		
		if (Read_only[msgareas] == REMOTE_ONLY) {
			buffer = get_frombin();
			ROnode[msgareas] = ctl_string(buffer);
		}
		
		read_nodes:
		
		i = j = 0;
		
		while (j != (UWORD) -1) {
			fread(&j, sizeof(UWORD), 1, FDUMMY);
			if (j == (UWORD) -1) break;
			Tz[i] = j;
			fread(&j, sizeof(UWORD), 1, FDUMMY);
			if (j == (UWORD) -1) break;
			Tnt[i] = j;
			fread(&j, sizeof(UWORD), 1, FDUMMY);
			if (j == (UWORD) -1) break;
			Tne[i] = j;
			fread(&j, sizeof(UWORD), 1, FDUMMY);
			if (j == (UWORD) -1) break;
			Tp[i++] = j;
			giveTIMEslice();
			if(feof(FDUMMY)) break;
		}
		
		Tz[i] = Tnt[i] = Tne[i] = Tp[i] = -1;

		Tozone[msgareas] = (UWORD *) myalloc((i+1) * sizeof(UWORD));
		Tonet[msgareas] = (UWORD *) myalloc((i+1) * sizeof(UWORD));
		Tonode[msgareas] = (UWORD *) myalloc((i+1) * sizeof(UWORD));
		Topoint[msgareas] = (UWORD *) myalloc((i+1) * sizeof(UWORD));
		
		memset(Tozone[msgareas], -1,(i+1) * sizeof(WORD));
		memset(Tonet[msgareas], -1, (i+1) * sizeof(WORD));
		memset(Tonode[msgareas], -1, (i+1)* sizeof(WORD));
		memset(Topoint[msgareas], -1, (i+1)* sizeof(WORD));

		memmove(Tozone[msgareas], Tz, sizeof(WORD) * i);
		memmove(Tonet[msgareas], Tnt, sizeof(WORD) * i);
		memmove(Tonode[msgareas], Tne, sizeof(WORD) * i);
		memmove(Topoint[msgareas], Tp, sizeof(WORD) * i);

		msgareas++;
	}
	fclose (FDUMMY);
	return (TRUE);
}

BOOLEAN area_attrib() {
	WORD attrib;
	BYTE buffer[128];
	BOOLEAN retcode = FALSE;
	
	sprintf(buffer, "%s%s",Envpath, AREAFILE);

	giveTIMEslice();
		
	attrib = Fattrib(buffer, 0 , -1);
	
	if (attrib != -33 && attrib != -34 && attrib & FA_ARCHIVE)
	{
		retcode = TRUE;
	}
	
	sprintf(buffer, "%s%s",Envpath, DAREAFILE);
	
	giveTIMEslice();
	
	attrib = Fattrib(buffer, 0 , -1);
	
	if (attrib != -33 && attrib != -34 && attrib & FA_ARCHIVE)
	{
		retcode = TRUE;
	}
	
	return (retcode);
}
