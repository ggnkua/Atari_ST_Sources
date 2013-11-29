#include "extern.h"

static INDICATOR stype_i[] = {{STE_SND, &snd_type},
												 			{ST_SND, &snd_type},
												 			{PCK_SND, &snd_type}};

static ACTIVATOR stype_a[] = {{TYP_OK, okay_but},
														 	{TYP_CNC, cancel_but}};

static DIALOG stype_dia = {ASKTYPE, "Soundtyp ?", 3, 2, stype_i, stype_a, 1, 0, -1, ""};

/* ---------------------------------
	 | Analyse sample (ST/STE-Sound) |
	 --------------------------------- */
long analyse_sample(char **data, long total, int flg)
{
long a, ctotal;
char *o_bytes = *data + sizeof(SOUND);

if (total > 100000L)
	ctotal = 100000L;
else
	ctotal = total;
	
if (flg || snd_type == -1)
	a = check_sam(o_bytes, ctotal);
	
if (a > ctotal / 150 || !flg)
	if (flg || snd_type == -1)
		if (ask_sndtype(o_bytes) == 1)
			switch(snd_type)
				{
				case 1:
					st_convert(o_bytes, total);
					break;

				case 2:
					*data = unkompakt(&total, *data);
					break;
				}
		else
			total = 0L;

return total;
}

/* ---------------------
	 | Select sound type |
	 --------------------- */
int ask_sndtype(char *o_bytes)
{
if (o_bytes[1] == 0 || o_bytes[1] == 1)
	snd_type = 2;
else
	snd_type = 1;

return exclusiv_dialog(&stype_dia);
}
