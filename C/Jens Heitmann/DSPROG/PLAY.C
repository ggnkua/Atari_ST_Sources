#include "extern.h"
#include <tos.h>

#define SDMACTL 	0 					 /* DMA-Sound Controlregister */
#define SDMASTAT	1						 /* DMA-Sound Statusregister	*/
#define SSTART	 	3						 /* Frame-Startadresse 			 */
#define SEND			0xf  				 /* Frame-Endadresse				  */
#define SDMAMOD 	0x20L  			 /* DMA-Sound Moderegister		*/

long spd_table[5] = {6250, 12500, 25000L, 50000L, 10072L};

int dma_tab[] = {0,1,2,3};
long dma_spd[] = {6250, 12517, 25033, 50066L};

int codec_tab[] = {CODEC49170, CODEC33880,
									 CODEC24585, CODEC20770,
									 CODEC16940, CODEC12292,
									 CODEC9834, CODEC8195};
long codec_spd[] = {49170L, 33880L, 24585, 20770,
 							      16940, 12292, 9834, 8195};

extern DIALOG playopt_dia;
extern DIALOG mboard_dia;

/* ----------------------
   | Check play options |
   ---------------------- */
void check_play(void)
{
OBJECT *ausg_tree, *ausg_tree2;
int p_ta;

ausg_tree = playopt_dia.tree;
ausg_tree2 = mboard_dia.tree;
switch (play_dev)
	{
	case PSG:
		if (ausg_tree[ONPSG].ob_state & DISABLED)
			if (!(ausg_tree[ONCODEC].ob_state & DISABLED))
				play_dev = CODEC;
			else
				play_dev = DMA;
		else
			break;
	
	case DMA:
		if (ausg_tree[ONDMA].ob_state & DISABLED)
			play_dev = CODEC;
		else
			break;

	case CODEC:
		if (ausg_tree[ONCODEC].ob_state & DISABLED)
			play_dev = PSG;
		else
			break;
	}
	
switch(play_dev)
	{
	case PSG:
		if (cpu_type == 68000L && play_ovsm)
			{
			ausg_tree2[MB25000].ob_state |= DISABLED;
			ausg_tree[PLY25000].ob_state |= DISABLED;
			}
		else
			{
			ausg_tree2[MB25000].ob_state &= ~DISABLED;
			ausg_tree[PLY25000].ob_state &= ~DISABLED;
			}
	
		ausg_tree[PLY50000].ob_state |= DISABLED;
		ausg_tree2[MB50000].ob_state |= DISABLED;
		p_ta = (int)((2457600L/4L) / spd_table[4] / 2);
		if (p_ta < 16)
			spd_table[4] = (2457600L/4L) / 32;
		break;
	
	case DMA:
	case CODEC:
		ausg_tree[PLY25000].ob_state &= ~DISABLED;
		ausg_tree2[MB25000].ob_state &= ~DISABLED;

		if (play_ovsm)	
			{
			ausg_tree[PLY50000].ob_state |= DISABLED;
			ausg_tree2[MB50000].ob_state |= DISABLED;
			}
		else
			{
			ausg_tree[PLY50000].ob_state &= ~DISABLED;
			ausg_tree2[MB50000].ob_state &= ~DISABLED;
			}
		break;	
	}	
}

/* ---------------------------
   | Play on PSG is selected |
   --------------------------- */
int popt_psg(void)
{
if (cpu_type == 68000L && play_ovsm)
	{
	playopt_dia.tree[PLY25000].ob_state |= DISABLED;
	mboard_dia.tree[MB25000].ob_state |= DISABLED;
	if (playopt_dia.w_handle)
		force_oredraw(playopt_dia.w_handle, PLY25000);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, MB25000);
	}
else
	{
	playopt_dia.tree[PLY25000].ob_state &= ~DISABLED;
	mboard_dia.tree[MB25000].ob_state &= ~DISABLED;
	if (playopt_dia.w_handle)
		force_oredraw(playopt_dia.w_handle, -PLY25000);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, -MB25000);
	}
	
playopt_dia.tree[PLY50000].ob_state |= DISABLED;
mboard_dia.tree[MB50000].ob_state |= DISABLED;
if (playopt_dia.w_handle)
	force_oredraw(playopt_dia.w_handle, PLY50000);
if (mboard_dia.w_handle)
	force_oredraw(mboard_dia.w_handle, MB50000);
	
return 0;
}

/* ---------------------------
   | Play on DMA is selected |
   --------------------------- */
int popt_dma(void)
{
playopt_dia.tree[PLY25000].ob_state &= ~DISABLED;
mboard_dia.tree[MB25000].ob_state &= ~DISABLED;
if (playopt_dia.w_handle)
	force_oredraw(playopt_dia.w_handle, -PLY25000);
if (mboard_dia.w_handle)
	force_oredraw(mboard_dia.w_handle, -MB25000);

if (play_ovsm)	
	{
	playopt_dia.tree[PLY50000].ob_state |= DISABLED;
	mboard_dia.tree[MB50000].ob_state |= DISABLED;
	
	if (playopt_dia.w_handle)
		force_oredraw(playopt_dia.w_handle, PLY50000);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, MB50000);
	}
else
	{
	playopt_dia.tree[PLY50000].ob_state &= ~DISABLED;
	mboard_dia.tree[MB50000].ob_state &= ~DISABLED;
	
	if (playopt_dia.w_handle)
		force_oredraw(playopt_dia.w_handle, -PLY50000);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, -MB50000);
	}
	
return 0;
}

/* -----------------------------
   | Play on CODEC is selected |
   ----------------------------- */
int popt_codec(void)
{
return 0;
}

/* -------------------
   | Oversampling on |
   ------------------- */
int popt_ovon(void)
{
int p_ta;

switch(play_dev)
	{
	case PSG:
		playopt_dia.tree[PLY25000].ob_state |= DISABLED;
		mboard_dia.tree[MB25000].ob_state |= DISABLED;
		
		if (playopt_dia.tree[PLY25000].ob_state & SELECTED)
			{
			playopt_dia.tree[PLY25000].ob_state &= ~SELECTED;
			playopt_dia.tree[PLY12500].ob_state |= SELECTED;
			mboard_dia.tree[MB25000].ob_state &= ~SELECTED;
			mboard_dia.tree[MB12500].ob_state |= SELECTED;

			ply_speed = 1;
			if (playopt_dia.w_handle)
				force_oredraw(playopt_dia.w_handle, PLY12500);
			if (mboard_dia.w_handle)
				force_oredraw(mboard_dia.w_handle, MB12500);
			}
		if (playopt_dia.w_handle)
			force_oredraw(playopt_dia.w_handle, PLY25000);
		if (mboard_dia.w_handle)
			force_oredraw(mboard_dia.w_handle, MB25000);
		break;
		
	case DMA:
	case CODEC:
		playopt_dia.tree[PLY50000].ob_state |= DISABLED;
		mboard_dia.tree[MB50000].ob_state |= DISABLED;
		if (playopt_dia.tree[PLY50000].ob_state & SELECTED)
			{
			playopt_dia.tree[PLY50000].ob_state &= ~SELECTED;
			playopt_dia.tree[PLY25000].ob_state |= SELECTED;
			mboard_dia.tree[MB50000].ob_state &= ~SELECTED;
			mboard_dia.tree[MB25000].ob_state |= SELECTED;
			
			ply_speed = 2;
			if (playopt_dia.w_handle)
				force_oredraw(playopt_dia.w_handle, PLY25000);
			if (mboard_dia.w_handle)
				force_oredraw(mboard_dia.w_handle, MB25000);
			}
		if (playopt_dia.w_handle)
			force_oredraw(playopt_dia.w_handle, PLY50000);
		if (mboard_dia.w_handle)
			force_oredraw(mboard_dia.w_handle, MB50000);
		break;
		
/*	case CODEC:
		break;*/
	}

p_ta = (int)((2457600L/4L) / spd_table[4] / 2);
if (p_ta < 16)
	{
	spd_table[4] = (2457600L/4L) / 32;
	ltoa(spd_table[4], playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt, 10);
	strcat(playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt, " KHz");
	
	strcpy(mboard_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt,
				 playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt);
	
	if (playopt_dia.w_handle)
		force_oredraw(playopt_dia.w_handle, MANUSPD);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, MBMANU);
	}

return 0;
}

/* --------------------
   | Oversampling off |
   -------------------- */
int popt_ovoff(void)
{
switch(play_dev)
	{
	case PSG:
		playopt_dia.tree[PLY25000].ob_state &= ~DISABLED;
		mboard_dia.tree[MB25000].ob_state &= ~DISABLED;
		
		if (playopt_dia.w_handle)
			force_oredraw(playopt_dia.w_handle, -PLY25000);
		if (mboard_dia.w_handle)
			force_oredraw(mboard_dia.w_handle, -MB25000);
		break;
		
	case DMA:
	case CODEC:
		playopt_dia.tree[PLY50000].ob_state &= ~DISABLED;
		mboard_dia.tree[MB50000].ob_state &= ~DISABLED;
		
		if (playopt_dia.w_handle)
			force_oredraw(playopt_dia.w_handle, -PLY50000);
		if (mboard_dia.w_handle)
			force_oredraw(mboard_dia.w_handle, -MB50000);
		break;
		
/*	case CODEC:
		break;*/
	}
return 0;
}

/* -------------------------
   | Count manual speed up |
   ------------------------- */
int spd_up(void)
{
int p_ta;

p_ta = (int)((2457600L/4L) / spd_table[4] / (play_ovsm + 1));

if (p_ta > 16)
	{
	p_ta--;
	spd_table[4] = (2457600L/4L) / p_ta / (play_ovsm + 1);
	ltoa(spd_table[4], playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt, 10);
	strcat(playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt, " KHz");

	strcpy(mboard_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt,
				 playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt);

	if (playopt_dia.w_handle)
		force_oredraw(playopt_dia.w_handle, MANUSPD);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, MBMANU);
	}
return 0;
}

/* ---------------------------
   | Count manual speed down |
   --------------------------- */
int spd_down(void)
{
int p_ta;

p_ta = (int)((2457600L/4L) / spd_table[4] / (play_ovsm + 1));

if (p_ta < 255)
	{
	p_ta++;
	spd_table[4] = (2457600L/4L) / p_ta / (play_ovsm + 1);
	ltoa(spd_table[4], playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt, 10);
	strcat(playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt, " KHz");

	strcpy(mboard_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt,
				 playopt_dia.tree[MANUSPD].ob_spec.tedinfo->te_ptmplt);

	if (playopt_dia.w_handle)
		force_oredraw(playopt_dia.w_handle, MANUSPD);
	if (mboard_dia.w_handle)
		force_oredraw(mboard_dia.w_handle, MBMANU);
	}
	
return 0;
}

/* -------------------
   | Play one sample |
   ------------------- */
void play_one(void)
{
int i;
long psg_tab[4];

i = search_topsw();

if (i == -1)
	return;

if (!(menu_adr[SETMWIRE].ob_state & DISABLED))
	send_mwire();
	
psg_tab[0] = (long)samples[i]->data;
psg_tab[1] = samples[i]->len;
psg_tab[3] = 0L;
play_seqs = psg_tab;
switch (play_dev)
	{
	case PSG:
		play_onpsg();
		break;
	
	case DMA:
		play_ondma();
		break;

	case CODEC:
		play_oncodec();
		break;
	}
}

/* ----------------------
	 | Play sample on psg |
	 ---------------------- */
void play_onpsg(void)
{
long stack;

stack = Super(0L);

Ikbdws(0, "\23");
start_psg((2457600L/4L) / spd_table[ply_speed] / (play_ovsm + 1));
Ikbdws(0, "\21");

Super((void *)stack);
}

/* ----------------------
	 | Play sample on DMA |
	 ---------------------- */
void play_ondma(void)
{
long out_speed;
char *snd_buf;
char *buf_mid;
long *seq_poi;
char *akt_poi;
int two, buff_fill;
long frq, fill_len, one;
long stack;

stack = Super(0L);
snd_buf = (char *)malloc(64000L);	
if (snd_buf)
	{
	buf_mid = snd_buf + 32000;
		
	out_speed = spd_table[ply_speed] * (play_ovsm + 1);
	frq = dma_connect(out_speed);

	if (frq == out_speed)
		{
		one = 99999L;
		two = 32000;
		}
	else
		{
		buff_fill = (int)(frq - out_speed);
		one = (int)((out_speed + (buff_fill >> 1)) / buff_fill);
		fill_len = (out_speed / one) * (one + 1) + (out_speed  % one);
		if (frq < fill_len)
		  two = (int)((out_speed / one) / (fill_len - frq));
		 else
	  	two = (int)((out_speed / one) / ((fill_len - frq) >> 1));
	 	}
		 	
	seq_poi = play_seqs;
	if (seq_poi[1])
		{
		akt_poi = (char *)seq_poi[0];
		fill_len = seq_poi[1];
		buff_fill = fill_play_buffer(&akt_poi, &fill_len, snd_buf, one, two);
		if (fill_len || seq_poi[3])
			{
			set_dma((long)snd_buf, (long)buf_mid - 1L);

			while(fill_len)
				{
				buff_fill = fill_play_buffer(&akt_poi, &fill_len, buf_mid, one, two);
				set_dma((long)buf_mid, (long)buf_mid + buff_fill);
				if (!fill_len)
					{
					seq_poi += 2;
					fill_len = seq_poi[1];
					if (!fill_len)
						break;
					akt_poi = (char *)seq_poi[0];
					}

				buff_fill = fill_play_buffer(&akt_poi, &fill_len, snd_buf, one, two);
				set_dma((long)snd_buf, (long)snd_buf + buff_fill);
				if (!fill_len)
					{
					seq_poi += 2;
					fill_len = seq_poi[1];
					if (!fill_len)
						break;
					akt_poi = (char *)seq_poi[0];
					}
				}
			}
		else
			set_dma((long)snd_buf, (long)snd_buf + buff_fill);
		}
			
	while(*(char *)(0xffff8900L + SDMASTAT));
	free(snd_buf);
	}
else
	error("Tempor„rer Bereich konnte", "nicht angelegt werden.", 5);

Super((void *)stack);
}

/* ---------------------------------------
   | Connect DMA with realiest frequency |
   --------------------------------------- */
long dma_connect(long play_spd)
{
int i, b = 3;
char *dma_chip = (char *)0xffff8900L;

if (dma_spd[3] > play_spd)
	for (i = 2; i >= 0; i--)
		if (dma_spd[i] >= play_spd)
			b = i;

if (falcon_flg && !b)
	b = 1;

*(int *)(&dma_chip[SDMAMOD]) = 0x80 + dma_tab[b];
return dma_spd[b];
}

/* ---------------------
   | Set DMA registers |
   --------------------- */
void set_dma(long from, long to)
{
char *dma_chip = (char *)0xffff8900L;

while(dma_chip[SDMASTAT]);

dma_chip[SSTART + 4] = from; from >>= 8;
dma_chip[SSTART + 2] = from; from >>= 8;
dma_chip[SSTART] = from;

dma_chip[SEND + 4] = to; to >>= 8;
dma_chip[SEND + 2] = to; to >>= 8;
dma_chip[SEND] = to;
*(int *)(&dma_chip[SDMACTL]) = 0x1;
}

/* ------------------------
	 | Play sample on CODEC |
	 ------------------------ */
void play_oncodec(void)
{
long out_speed;
char *snd_buf;
char *buf_mid;
long *seq_poi;
char *akt_poi;
int buff_fill, two;
long frq, fill_len, buffers[4], one;
long stack;

stack = Super(0L);
if (locksnd() < 0)
	error("Soundsystem bereits", "belegt!", 0x5);
else
	{
/*	soundcmd(LTATTEN, 
		soundcmd(RTATTEN,		*/

	snd_buf = (char *)malloc(64000L);	
	if (snd_buf)
		{
		buf_mid = snd_buf + 32000;
		
		setsndmode(2);
		settracks(0, 0);
		setmontracks(0);
		out_speed = spd_table[ply_speed] * (play_ovsm + 1);
		frq = codec_connect(out_speed);

		if (frq == out_speed)
			{
			one = 99999L;
			two = 32000;
			}
		else
			{
			buff_fill = (int)(frq - out_speed);
			one = (int)((out_speed + (buff_fill >> 1)) / buff_fill);
			fill_len = (out_speed / one) * (one + 1) + (out_speed  % one);
			if (frq < fill_len)
			  two = (int)((out_speed / one) / (fill_len - frq));
			 else
		  	two = (int)((out_speed / one) / ((fill_len - frq) >> 1));
		 	}
		 	
		seq_poi = play_seqs;
		if (seq_poi[1])
			{
			akt_poi = (char *)seq_poi[0];
			fill_len = seq_poi[1];
			buff_fill = fill_play_buffer(&akt_poi, &fill_len, snd_buf, one, two);

			if (fill_len || seq_poi[3])
				{
				setbuffer(0, snd_buf, buf_mid);
				buffoper(1);
				
				while(fill_len)
					{
					buff_fill = fill_play_buffer(&akt_poi, &fill_len, buf_mid, one, two);
					do
						{
						buffptr(buffers);
						}while((char *)buffers[0] != snd_buf);
					setbuffer(0, buf_mid, buf_mid + buff_fill);
					buffoper(1);
					
					if (!fill_len)
						{
						seq_poi += 2;
						fill_len = seq_poi[1];
						if (!fill_len)
							break;
						akt_poi = (char *)seq_poi[0];
						}

					buff_fill = fill_play_buffer(&akt_poi, &fill_len, snd_buf, one, two);
					do
						{
						buffptr(buffers);
						}while((char *)buffers[0] != buf_mid);
					setbuffer(0, snd_buf, snd_buf + buff_fill);
					buffoper(1);

					if (!fill_len)
						{
						seq_poi += 2;
						fill_len = seq_poi[1];
						if (!fill_len)
							{
							buf_mid = snd_buf;
							break;
              }
						akt_poi = (char *)seq_poi[0];
						}
					}
				}
			else
				{
				setbuffer(0, snd_buf, snd_buf + buff_fill);
				buffoper(1);
				buf_mid = snd_buf;
				}
			}

    do
			{
			buffptr(buffers);
			}while((char *)buffers[0] != buf_mid);
		buffoper(0);
			
		free(snd_buf);
		}
	else
		error("Tempor„rer Bereich konnte", "nicht angelegt werden.", 5);
		
	devconnect(DMAPLAY, DAC, 0, 0, 1);																						
	unlocksnd();
	}

Super((void *)stack);
}

/* -----------------------------------------
   | Connect CODEC with realiest frequency |
   ----------------------------------------- */
long codec_connect(long play_spd)
{
int i, b = 0;

if (codec_spd[0] > play_spd)
	for (i = 1; i < 8; i++)
		if (codec_spd[i] >= play_spd)
			b = i;

devconnect(DMAPLAY, DAC, 0, codec_tab[b], 1);																						
return codec_spd[b];
}

/* --------------------------------------
   | Fill play buffer with current data |
   -------------------------------------- */
int fill_play_buffer(char **data_poi, long *len_poi, char *buffer, long one_step, int two_step)
{
int cnt = 32000, two_cnt;
char *poi, new_note;
long in_data, one_cnt;
static char note = 0, xnote;

poi = data_poi[0];
in_data = *len_poi;
one_cnt = one_step;
two_cnt = (two_step > 0) ? two_step : -two_step;

if (play_ovsm)
	while(in_data && cnt)
		{
		if (!one_cnt)
			{
			if (two_cnt <= 0)
				{
				if (two_step > 0)
					{
					two_cnt = two_step;
					one_cnt = one_step;
					continue;
					}
				else
					{
					if (!two_cnt)
						{
						xnote = note;
						new_note = (((*poi + note) >> 1) + note) >> 1;
						}
					else
						if (two_cnt == -1)
							{
							new_note = (*poi + xnote) >> 1;
							two_cnt = -two_step + 1;
							one_cnt = one_step;
							}
					}
				}
			else
				{
				new_note = (*poi + note) >> 1;
				one_cnt = one_step;
				}
			two_cnt--;
			}
		else
			{
			new_note = *(poi++);
			one_cnt--;
			in_data--;
			}

		*(buffer++) = (new_note + note) >> 1;
		note = *(buffer++) = new_note;
		cnt -= 2;
		}
else
	while(in_data && cnt)
		{
		if (!one_cnt)
			{
			if (two_cnt <= 0)
				{
				if (two_step > 0)
					{
					two_cnt = two_step;
					one_cnt = one_step;
					continue;
					}
				else
					{
					if (!two_cnt)
						{
						xnote = note;
						note = (((*poi + note) >> 1) + note) >> 1;
						}
					else
						if (two_cnt == -1)
							{
							note = (*poi + xnote) >> 1;
							two_cnt = -two_step + 1;
							one_cnt = one_step;
							}
					}
				}
			else
				{
				note = (*poi + note) >> 1;
				one_cnt = one_step;
				}
			two_cnt--;
			}
		else
			{
			note = *(poi++);
			one_cnt--;
			in_data--;
			}
			
		*(buffer++) = note;
		cnt--;
		}

*data_poi = poi;
*len_poi = in_data;	
return 32000 - cnt;
}
