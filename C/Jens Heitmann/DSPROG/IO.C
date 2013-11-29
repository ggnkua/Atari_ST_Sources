#include "extern.h"

#define SMP_WKIND MOVER|NAME|CLOSER|INFO|SIZER|FULLER

int ug_ask = 0;
extern long spd_table[5];

/* -----------------
	 | Select sample |
	 ----------------- */
int select_sample(char *fname, char *title, char *ext)
{
int stat, but;
int tos_v;
void *old_ss;

old_ss = (void *)Super(0L);
tos_v = (*(int **)0x4f2)[1];
Super(old_ss);

if (strchr(path, '\\'))
	{
	strcpy(strrchr(path, '\\') + 1, "*.");
	strcat(path, ext);
	}

if (strchr(file, '.'))
	strcpy(strchr(file, '.') + 1, ext);
else
	if (file[0])
		{
		strcat(file, ".");
		strcat(file, ext);
		}
			
if (tos_v >= 0x104)
	stat = fsel_exinput(path, file, &but, title);
else
	stat = fsel_input(path, file, &but);
if (stat && but)
	{
	strcpy(fname, path);
	strcpy(strrchr(fname, '\\') + 1, file);
	return 1;
	}
return 0;
}

/* ------------------------
	 | Einladen des Samples |
	 ------------------------ */
void load_sample()
{
char fname[MAXPATH];

if (!select_sample(fname, "Sample laden...", smp_extension))
	return;
	
ug_ask = 1;
load_in_sample(fname);
ug_ask = 0;
}

/* ----------------------
   | Open sample window |
   ---------------------- */
void open_sample(int idx, long total)
{
int w_x, w_y, w_w, w_h;
int a_x, a_y, a_w, a_h;
int w_handle;

wind_get(0, WF_WORKXYWH, &a_x, &a_y, &a_w, &a_h);

wind_calc(WC_WORK, SMP_WKIND, a_x, a_y, a_w, a_h, &w_x, &w_y, &w_w, &w_h);
wind_calc(WC_BORDER, SMP_WKIND, w_x, w_y, (int)((total < w_w) ? total : w_w), 128, &w_x, &w_y, &w_w, &w_h);
			
w_handle = wind_create(SMP_WKIND, a_x, a_y, a_w, a_h);
if (!w_handle)
	{
	form_alert(1, "[3][Kein Fenster mehr |verfgbar.][ schade ]");
	return;
	}
	
wind_set(w_handle, WF_NAME, samples[idx]->smp_name);
wind_set(w_handle, WF_INFO, samples[idx]->smp_info);
wind_open(w_handle, w_x, w_y, w_w, w_h); 
samples[idx]->w_handle = w_handle;
}

/* -------------------------
   | Get free sample entry |
   ------------------------- */
int getfree_entry(char *o_bytes, char *fname, long total)
{
int i;
SOUND **new;

for (i = 0; i < max_samples; i++)
	if (!samples[i])
		break;
		
if (i == max_samples)
	if (max_samples)
		{
		new = realloc(samples, sizeof(SOUND *) * (max_samples + 20));
		if (!new)
			return -1;
	
		samples = new;
		for (i = max_samples; i < max_samples + 20; i++)
			samples[i] = NULL;

		i = max_samples;
		max_samples += 20;
		}
	else
		{
		samples = malloc(sizeof(SOUND) * 20);
		if (!samples)
			return -1;

		for (i = 0; i < 20; i++)
			samples[i] = NULL;
		
		i = 0;
		max_samples = 20;
		}

samples[i] = (SOUND *)o_bytes;
samples[i]->data = o_bytes + sizeof(SOUND);
samples[i]->len = total;
strcpy(samples[i]->smp_name, fname);
strcpy(samples[i]->smp_info, " L„nge: ");
ltoa(total, samples[i]->smp_info + 8, 10);

open_sample(i, total);
if (samples[i]->w_handle)
	return i;
else
	return -1;
}

/* --------------------
   | Load sample file |
   -------------------- */
void load_in_sample(char *fname)
{
long fd;
long i;
char *o_bytes;
int idx;
long total;
AVR_FILE header;

if ((fd = Fopen(fname, 0)) < 0)
	{
	error("Datei fehlt!", "\0", 0xA);
	total = 0L;
	}
else
	{
	total = Fseek(0, (int)fd, 2);
	Fseek(0, (int)fd, 0);
	Fread((int)fd, sizeof(AVR_FILE), &header);
	if (header.magic == '2BIT')
		{
		spd_table[4] = header.frequenz;
		total -= sizeof(AVR_FILE);
		}
	else
		Fseek(0, (int)fd, 0);

	if (total)
		{
		if ((o_bytes = (char *)malloc(total + 6L + sizeof(SOUND))) == NULL)
			error("Speicher voll!", "\0", 0xA);

		if (o_bytes)
			{
			graf_mouse(HOURGLASS, 0L);

			i = Fread((int)fd, total, o_bytes + sizeof(SOUND));
			graf_mouse(ARROW, 0L);
		
			if (i < total)
				error("Datei defekt!!!", "\0", 0xA);
	
			total = analyse_sample(&o_bytes, total, ug_ask);

			if (total > 0L)
				idx = getfree_entry(o_bytes, fname, total);
			else
				idx = -1;
				
			if (idx == -1)
				{
				free(o_bytes);
				Fclose((int)fd);
				return;
				}

			akt_samples++;
			}
		}

	Fclose((int)fd);
	}
}

/* ---------------------------
	 | Abspeichern des Samples |
	 --------------------------- */
void save_sample()
{
char fname[MAXPATH];
int i;

i = search_topsw();
if (i == -1)
	return;

if (!select_sample(fname, "Sample speichern", smp_extension))
	return;
save_out_sample(fname, samples[i]->data, samples[i]->len);
}

/* --------------------
   | Save sample file |
   -------------------- */
void save_out_sample(char *fname, char *o_bytes, long total)
{
long fd;
long i;

if ((fd = Fcreate(fname, 0)) < 0)
	error("Datei nicht anlegbar!", "\0", 0xA);
else
	{
	graf_mouse(HOURGLASS, 0L);

	i = Fwrite((int)fd, total, o_bytes);
	graf_mouse(ARROW, 0L);
		
	if (i < total)
		error("Schreibfehler!!!", "\0", 0xA);

	Fclose((int)fd);
	}
}

/* ----------------------------
	 | Abspeichern als AVR-File |
	 ---------------------------- */
void save_avr(void)
{
char fname[MAXPATH];
int i;

i = search_topsw();
if (i == -1)
	return;

if (!select_sample(fname, "*.AVR speichern", avr_extension))
	return;
save_smp_avr(fname, samples[i]->data, samples[i]->len);
}

/* --------------------
   | Save sample file |
   -------------------- */
void save_smp_avr(char *fname, char *o_bytes, long total)
{
long fd;
long i;
AVR_FILE header;

if ((fd = Fcreate(fname, 0)) < 0)
	error("Datei nicht anlegbar!", "\0", 0xA);
else
	{
	graf_mouse(HOURGLASS, 0L);

	memset(&header, 0, sizeof(header));
	header.magic = '2BIT';
	strncpy(header.sample_name, file, 8);
	header.sample_name[7] = 0;
	if (strchr(header.sample_name, '.'))
		*strchr(header.sample_name, '.') = 0;
	header.modus = 0;
	header.resolution = 8;
	header.sgned = 1;
	header.loop = 1;
	header.midi = -1;
	header.frequenz = 10000L;
	header.laenge = total;
	strcpy(header.ext, file);

	if (Fwrite((int)fd, sizeof(header), &header) != sizeof(header))
		total = 999999999L;
	else		
		i = Fwrite((int)fd, total, o_bytes);

	graf_mouse(ARROW, 0L);
	if (i != total)
		error("Schreibfehler!!!", "\0", 0xA);

	Fclose((int)fd);
	}
}
