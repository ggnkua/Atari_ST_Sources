#include "extern.h"

/* ----------------- */
/* | Datei l”schen | */
/* ----------------- */
int file_del(void)
{
DTA dta;
char kill_buf[80], alert[128];
register int s;
register char ext[4];

do
	{
	if (rindex(del_file, '.') > rindex(del_file, '\\') && rindex(del_file, '.') )
		strcpy(ext, rindex(del_file, '.') );
	else
		strcpy(ext, ".*");

	*(rindex(del_file, '\\') + 1) = 0;

	if (!fsel(del_file, ext))
		{
		strcat(del_file, "*");
		strcat(del_file, ext);
		return(FALSE);
		}

	Fsetdta(&dta);

	s = Fsfirst(del_file, 0x10);
	while(s >= 0)
		{
		if (!(dta.d_attrib & 0x10) && dta.d_fname[0] != '.')
			{
			strcpy(kill_buf, del_file);
			strcpy(rindex(kill_buf, '\\') + 1, dta.d_fname);

			strcpy(alert, DELASK_1);
			strcpy(alert + 5, dta.d_fname);
			strcat(alert, DELASK_2);
			alert[29] = 0;
			strcat(alert, DELASK_3);
			
			switch(form_alert(2, alert))
				{
				case 1:
					Fdelete(kill_buf);
					break;

				case 3:
					s = -1;
					break;
				}

			if (s == -1)
				break;
			}

		s = Fsnext();		
		}
	}while(TRUE);
}

/* -------------- */
/* | Diskformat | */
/* -------------- */
void d_format(void)
{
register int eo;
static int drv = 0, trks = 80, sect = 9, sid = 1;
register char *alert;

if (form_alert(2, DFMT_ATT) == 2)
	return;

rsrc_gaddr(ROOT, DISK_FMT, &form_adr);

make_rasc((long)trks, 10L, form_adr[TRK].ob_spec.free_string);
make_rasc((long)sect, 10L, form_adr[SEKTOR].ob_spec.free_string);

calc_bytes(trks, sect, sid);

form_draw();

do
	{
	eo = form_do(form_adr, 0) & 0x7FFF;

	switch(eo)
		{
		case ONE_SIDE:
			sid = 1;
			while(!calc_bytes(trks, sect, sid))
				trks++;

			make_rasc((long)trks, 10L, form_adr[TRK].ob_spec.free_string);
			objc_draw(form_adr, TRK, MAX_DEPTH, fx, fy, fw, fh);
			break;

		case TWO_SIDE:
			sid = 2;
			calc_bytes(trks, sect, sid);
			break;

		case NORM_FMT:
			form_adr[EXT_BKG].ob_flags |= HIDETREE;
			objc_draw(form_adr, RED_NORM, MAX_DEPTH, fx, fy, fw, fh);
			break;

		case EXT_FORM:
			form_adr[EXT_BKG].ob_flags &= ~HIDETREE;
			objc_draw(form_adr, EXT_BKG, MAX_DEPTH, fx, fy, fw, fh);
			break;

		case TRK_DWN:
			if ((trks - 1) * sect * sid - 18 > 6)
				trks--;

			make_rasc((long)trks, 10L, form_adr[TRK].ob_spec.free_string);
			objc_draw(form_adr, TRK, MAX_DEPTH, fx, fy, fw, fh);

			calc_bytes(trks, sect, sid);
			break;

		case TRK_UP:
			if (trks < 85)
				trks++;

			make_rasc((long)trks, 10L, form_adr[TRK].ob_spec.free_string);
			objc_draw(form_adr, TRK, MAX_DEPTH, fx, fy, fw, fh);

			calc_bytes(trks, sect, sid);
			break;

		case SEK_UP:
			if (sect < 10)
				sect++;

			make_rasc((long)sect, 10L, form_adr[SEKTOR].ob_spec.free_string);
			objc_draw(form_adr, SEKTOR, MAX_DEPTH, fx, fy, fw, fh);

			calc_bytes(trks, sect, sid);
			break;

		case SEK_DWN:
			if (trks * (sect - 1) * sid - 18 > 6)
				sect--;

			make_rasc((long)sect, 10L, form_adr[SEKTOR].ob_spec.free_string);
			objc_draw(form_adr, SEKTOR, MAX_DEPTH, fx, fy, fw, fh);

			calc_bytes(trks, sect, sid);
			break;

		case DO_FORMT:
			form_adr[DO_FORMT].ob_state &= ~SELECTED;

			if (form_adr[DRIVE_A].ob_state & SELECTED)
				drv = 0;
			else
				drv = 1;

			alert = DFMT_INS;
			alert[DFMT_DRV] = 'A' + drv;
			if (form_alert(2, alert) == 2)
				break;

			if (form_adr[NORM_FMT].ob_state & SELECTED)
				do_dformat(drv, 80, 9, sid);
			else
				do_dformat(drv, trks, sect, sid);

			rsrc_gaddr(ROOT, DISK_FMT, &form_adr);
			form_draw();
			break;
		}

	}while(eo != FMT_CANC);

form_adr[eo].ob_state &= ~SELECTED;
form_end();
}

/* ------------------- */
/* | Bytes berechnen | */
/* ------------------- */
int calc_bytes(int t, int s, int sd)
{
register long bytes;

bytes = (t * s * sd) - 18;
bytes >>= 1;
bytes <<= 10;

if (bytes < 0)
	return(FALSE);

make_rasc(bytes, 100000L, (form_adr[FMT_BYTE].ob_spec.tedinfo)->te_ptext);
if (form_adr[EXT_FORM].ob_state & SELECTED)
	objc_draw(form_adr, FMT_BYTE, MAX_DEPTH, fx, fy, fw, fh);

return(TRUE);
}

/* ---------------------- */
/* | Execute Diskformat | */
/* ---------------------- */
void do_dformat(int drv, int trks, int sect, int sid)
{
register int tc, sd;
register char *buf;
int sc, fat_ind, cluster;
char fat[5 * 512], chk_sec[512];
DISKINFO diskinfo;

for(tc = 0; tc < 5 * 512; fat[tc++] = 0);
fat[0] = 0xF9;
fat[1] = 0xFF;
fat[2] = 0xFF;

rsrc_gaddr(ROOT, DFMTINFO, &form_adr);

form_adr[DFMT_SLD].ob_width = 0;
form_adr[DFMT_ST].ob_spec.tedinfo->te_ptext = "Status:\0";

form_draw();

buf = (char *)Malloc(10000L);

for (tc = trks - 1; tc >= 0; tc--)
	{
	for (sd = sid - 1; sd >= 0; sd--)
		if (Flopfmt(buf, 0L, drv, sect, tc, sd, 1, 0x87654321L, 0xE5E5)<0)
			{
			form_adr[DFMT_ST].ob_spec.tedinfo->te_ptext = "Status: Fehler";
			objc_draw(form_adr, DFMT_ST, MAX_DEPTH, fx, fy, fw, fh);

			for (sc = 1; sc <= sect; sc++)
				if (Floprd(chk_sec, 0L, drv, sc, tc, sd, 1) < 0)
					{
					cluster = ((tc * sect * sid + sect * sd + sc - 18) >> 2) + 2;
					fat_ind = (cluster * 3) >> 1;
					if (cluster & 1)
						{
						fat[fat_ind] |= 0xF;
						fat[fat_ind + 1] |= 0xFF;
						}
					else
						{
						fat[fat_ind] = 0xFF;
						fat[fat_ind + 1] |= 0xF0;
						}
					}
			}
		else
			{
			form_adr[DFMT_ST].ob_spec.tedinfo->te_ptext = "Status: OK    ";
			objc_draw(form_adr, DFMT_ST, MAX_DEPTH, fx, fy, fw, fh);
			}

	form_adr[DFMT_SLD].ob_width = (trks - tc) * form_adr[DFMT_SB].ob_width / trks;
	objc_draw(form_adr, DFMT_SLD, MAX_DEPTH, fx, fy, fw, fh);
	}

Protobt(chk_sec, 0x10000000L, 1 + sid, 0);
strcpy(chk_sec + 2, "M_TEXT");

sc = trks * sect * sid + 4;
chk_sec[19] = sc;
chk_sec[20] = sc >> 8;
chk_sec[24] = sect;
Flopwr(chk_sec, 0L, drv, 1, 0, 0, 1);

Getbpb(drv);
Rwabs(1, fat, 5, 1, drv);
Rwabs(1, fat, 5, 6, drv); 

for (sc = 0; sc < 512; chk_sec[sc++] = 0);
for (sc = 11; sc < 18; sc++)
	Rwabs(1, chk_sec, 1, sc, drv); 

Mfree(buf);

Getbpb(drv);
Dfree(&diskinfo, drv + 1);

buf = DFREE;
make_rasc(diskinfo.b_free * diskinfo.b_secsiz * diskinfo.b_clsiz, 1000000L, buf + DFREE_BY);
form_alert(1, buf);

form_end();
}
