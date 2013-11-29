#include "extern.h"

#define fsgn(a) ((a > 8) ? 1 : ((a < 8) ? -1 : 0))
#define cabs(a) ((a<0) ? -a : a)

static int boost_tab[256];

/* ------------------
	 | Analyse maxima |
	 ------------------ */
void calc_boost(void)
{
long i;
char c;
int frq_max, boost, j;

frq_max = 0;
for (i = 0; i < total; i++)
	{
	c = cabs(o_bytes[i]);
	frq_max = (c > frq_max) ? c : frq_max;
	}
boost = 12700 / frq_max;

for (j = -128; j < 128; j++)
	{
	frq_max = j * boost / 100;
	if (frq_max > 127)
		frq_max = 127;
	else
		if (frq_max < -128)
			frq_max = -128;
	
	boost_tab[j + 128] = frq_max;
	}
}

/* -----------------------
   | Get len of one wave |
   ----------------------- */
long get_wave(long pos)
{
int n, q;
long l;
char c;

l = 0L;
c = boost_tab[o_bytes[pos++] + 128] >> 2;
n = fsgn(c);
do
	{
	l++;
	
	if (pos == total)
		break;

	c = boost_tab[o_bytes[pos++] + 128] >> 2;
	q = fsgn(c);
  }while(n == q || !q);

return l;
}

/* ----------------------
	 | Sequenziere sample |
	 ---------------------- */
void sequencer(void)
{
OBJECT *seq_fm;
int seq_hndl, i;
long pos, pos1, last, flast;
long ll;
long l;
char seq_cnt[5], smp_len[8], smp_done[8];

if (seq_data)
	{
	free(seq_data);
	free(play_list);
	seq_data = (SEQUENZ *)NULL;
	}
	
seq_data = (SEQUENZ *)malloc(sizeof(SEQUENZ) * 200L);
max_seq = 200;

rsrc_gaddr(R_TREE, SEQ_INFO, &seq_fm);

seq_fm[SEQ_SLD].ob_width = 0;
strcpy(seq_cnt, "0");
seq_fm[SEQ_NUM].ob_spec.free_string = seq_cnt;
ltoa(total, smp_len, 10);
seq_fm[SEQ_SMP].ob_spec.free_string = smp_len;
strcpy(smp_done, "0");
seq_fm[SEQ_DONE].ob_spec.free_string = smp_done;

seq_hndl = dialog_window(0, seq_fm, OPN_DIA, 0);
dialog_window(seq_hndl, seq_fm, ACT_DIA, -1);

pos = 0;
pos1 = 7500L;
last = 0;

ll = 0;
flast = 0;

seq_num = 0;
strcpy(seq_data[0].name, "Sequenz 1");
strcpy(seq_data[0].file, "seq_1");
seq_data[0].pos = 0;
seq_data[0].link = 1;

calc_boost();
while (pos < total)
	{
  l = get_wave(pos);

	if (l * 5 < ll)
		{
		if (pos > flast + 2000)
			{
			seq_data[seq_num++].len = pos - last;
			
			if (seq_num == max_seq)
				{
				max_seq += 50;
				seq_data = realloc(seq_data, sizeof(SEQUENZ) * max_seq);
				}
			strcpy(seq_data[seq_num].name, "Sequenz ");
			itoa(seq_num + 1, seq_data[seq_num].name + 8, 10);
			strcpy(seq_data[seq_num].file, "seq_");
			itoa(seq_num + 1, seq_data[seq_num].file + 4, 10);

			seq_data[seq_num].pos = pos;
			seq_data[seq_num].link = 1;
      last = pos;

			itoa(seq_num + 1, seq_cnt, 10);
			objc_offset(seq_fm, SEQ_NUM, &red_x, &red_y);
			red_w = seq_fm[SEQ_NUM].ob_width;
			red_h = seq_fm[SEQ_NUM].ob_height;
			dialog_window(seq_hndl, seq_fm, RDW_DIA, ROOT);
      }
    flast = pos;
    }

  ll = l;
  pos += l;

	if (pos >= pos1)
		{
		ltoa(pos, smp_done, 10);
		objc_offset(seq_fm, SEQ_DONE, &red_x, &red_y);
		red_w = seq_fm[SEQ_DONE].ob_width;
		red_h = seq_fm[SEQ_DONE].ob_height;
		dialog_window(seq_hndl, seq_fm, RDW_DIA, ROOT);
		
		seq_fm[SEQ_SLD].ob_width = (int)(seq_fm[SEQ_BKG].ob_width * pos / total);
		if (dialog_window(seq_hndl, seq_fm, ACT_DIA, -1))
			break;
			
		wind_get(seq_hndl, WF_WORKXYWH, &red_x, &red_y, &red_w, &red_h);
		dialog_window(seq_hndl, seq_fm, RDW_DIA, SEQ_SLD);
		
		pos1 += 7500L;
		if (pos1 > total)
			pos1 = total;
		}
	}
seq_data[seq_num++].len = pos - last;

play_list = (int *)malloc(seq_num * sizeof(int));
for (i = 0; i < seq_num; i++)
	play_list[i] = i;
lst_num = seq_num;

dialog_window(seq_hndl, seq_fm, CLS_DIA, 0);
}
