#include "lh5.h"
#include <stdlib.h>
#include <string.h>  /* memmove() */
#ifdef __TOS__
 #include "goodputc.h"
#endif

/* #define _lhufs_ */

extern uchar text_buf[DICSIZ];
#define buffer text_buf
/* static uchar buffer[DICSIZ]; */



#define CRCPOLY  0xA001  /* ANSI CRC-16 */
                         /* CCITT: 0x8408 */
#define UPDATE_CRC(c) \
	crc = crctable[(crc ^ (c)) & 0xFF] ^ (crc >> CHAR_BIT)

extern FILE *infile, *outfile;
extern uint crc;
ulong  origsize,compsize;
#ifdef _lhufs_
 uint   bitbuf;
 extern uint   subbitbuf;
 extern int    bitcount;
 extern ulong  origsize,compsize;
#else
 uint          bitbuf;
 uint  	       subbitbuf;
 int   	       bitcount;
 ulong         origsize,compsize;
#endif
extern uchar flg_n;

ushort crctable[UCHAR_MAX + 1];
uint  subbitbuf;
int   bitcount;

static void error(char *fmt, ...)
{
	va_list args;

	va_start(args, fmt);
	putc('\n', stderr);
	vfprintf(stderr, fmt, args);
	putc('\n', stderr);
	va_end(args);
	exit(EXIT_FAILURE);
}

void make_crctable(void)
{
    uint i, j, r;
    static int crc_ready = 0;
    if (crc_ready == 0) {

	for (i = 0; i <= UCHAR_MAX; i++) {
		r = i;
		for (j = 0; j < CHAR_BIT; j++)
			if (r & 1) r = (r >> 1) ^ CRCPOLY;
			else       r >>= 1;
		crctable[i] = r;
	}
	crc_ready=1;
    }
}

void fillbuf(int n)  /* Shift bitbuf n bits left, read n bits */
{
	bitbuf <<= n;
	while (n > bitcount) {
		bitbuf |= subbitbuf << (n -= bitcount);
		if (compsize != 0) {
			compsize--;  subbitbuf = (uchar) getc(infile);
		} else subbitbuf = 0;
		bitcount = CHAR_BIT;
	}
	bitbuf |= subbitbuf >> (bitcount -= n);
}


static uint getbits(int n)
{
	uint x;

	x = bitbuf >> (BITBUFSIZ - n);  fillbuf(n);
	return x;
}

static void putbits(int n, uint x)  /* Write rightmost n bits of x */
{
	if (n < bitcount) {
		subbitbuf |= x << (bitcount -= n);
	} else {
		if (compsize < origsize) {
			if (putc(subbitbuf | (x >> (n -= bitcount)), outfile) == EOF) error("Unable to write");
			compsize++;
		} else unpackable = 1;
		if (n < CHAR_BIT) {
			subbitbuf = x << (bitcount = CHAR_BIT - n);
		} else {
			if (compsize < origsize) {
				if (putc(x >> (n - CHAR_BIT), outfile) == EOF) error("Unable to write");
				compsize++;
			} else unpackable = 1;
			subbitbuf = x << (bitcount = 2 * CHAR_BIT - n);
		}
	}
}

int fread_crc(uchar *p, int n, FILE *f)
{
	int i;

	i = n = fread(p, 1, n, f);  origsize += n;
	while (--i >= 0) UPDATE_CRC(*p++);
	return n;
}

static void fwrite_crc(uchar *p, int n, FILE *f)
{
	if (f!= NULL) if (fwrite(p, 1, n, f) < n) error("Unable to write");
	while (--n >= 0) UPDATE_CRC(*p++);
}

static void init_getbits(void)
{
	bitbuf = 0;  subbitbuf = 0;  bitcount = 0;
	fillbuf(BITBUFSIZ);
}

static void init_putbits(void)
{
	bitcount = CHAR_BIT;  subbitbuf = 0;
}

/* --------------------------- End of IO.C --------------------------- */

/***********************************************************
	decode.c
***********************************************************/



/* ----------------------Start of huf.c ------------------------------- */

/***********************************************************
	huf.c -- static Huffman
***********************************************************/

#define NP (DICBIT + 1)
#define NT (CODE_BIT + 3)
#define PBIT 4  /* smallest integer such that (1U << PBIT) > NP */
#define TBIT 5  /* smallest integer such that (1U << TBIT) > NT */
#if NT > NP
	#define NPT NT
#else
	#define NPT NP
#endif

extern ushort left[2 * NC - 1], right[2 * NC - 1];
extern uchar *buf, c_len[NC], pt_len[NPT];
extern int   bufsiz = 0, blocksize;
extern ushort c_freq[2 * NC - 1], c_table[4096], c_code[NC],
              p_freq[2 * NP - 1], pt_table[256], pt_code[NPT],
	          t_freq[2 * NT - 1];
extern ushort dad[4096];
#define c_table dad

/***** encoding *****/

void count_t_freq(void)
{
	int i, k, n, count;

	for (i = 0; i < NT; i++) t_freq[i] = 0;
	n = NC;
	while (n > 0 && c_len[n - 1] == 0) n--;
	i = 0;
	while (i < n) {
		k = c_len[i++];
		if (k == 0) {
			count = 1;
			while (i < n && c_len[i] == 0) {  i++;  count++;  }
			if (count <= 2) t_freq[0] += count;
			else if (count <= 18) t_freq[1]++;
			else if (count == 19) {  t_freq[0]++;  t_freq[1]++;  }
			else t_freq[2]++;
		} else t_freq[k + 2]++;
	}
}

void write_pt_len(int n, int nbit, int i_special)
{
	int i, k;

	while (n > 0 && pt_len[n - 1] == 0) n--;
	putbits(nbit, n);
	i = 0;
	while (i < n) {
		k = pt_len[i++];
		if (k <= 6) putbits(3, k);
		else putbits(k - 3, (1U << (k - 3)) - 2);
		if (i == i_special) {
			while (i < 6 && pt_len[i] == 0) i++;
			putbits(2, (i - 3) & 3);
		}
	}
}

void write_c_len(void)
{
	int i, k, n, count;

	n = NC;
	while (n > 0 && c_len[n - 1] == 0) n--;
	putbits(CBIT, n);
	i = 0;
	while (i < n) {
		k = c_len[i++];
		if (k == 0) {
			count = 1;
			while (i < n && c_len[i] == 0) {  i++;  count++;  }
			if (count <= 2) {
				for (k = 0; k < count; k++)
					putbits(pt_len[0], pt_code[0]);
			} else if (count <= 18) {
				putbits(pt_len[1], pt_code[1]);
				putbits(4, count - 3);
			} else if (count == 19) {
				putbits(pt_len[0], pt_code[0]);
				putbits(pt_len[1], pt_code[1]);
				putbits(4, 15);
			} else {
				putbits(pt_len[2], pt_code[2]);
				putbits(CBIT, count - 20);
			}
		} else putbits(pt_len[k + 2], pt_code[k + 2]);
	}
}

void encode_c(int c)
{
	putbits(c_len[c], c_code[c]);
}

void encode_p(uint p)
{
	uint c, q;

	c = 0;  q = p;  while (q) {  q >>= 1;  c++;  }
	putbits(pt_len[c], pt_code[c]);
	if (c > 1) putbits(c - 1, p & (0xFFFFU >> (17 - c)));
}

void send_block(void)
{
	uint i, k, flags, root, pos, size;

	root = make_tree(NC, c_freq, c_len, c_code);
	size = c_freq[root];  putbits(16, size);
	if (root >= NC) {
		count_t_freq();
		root = make_tree(NT, t_freq, pt_len, pt_code);
		if (root >= NT) {
			write_pt_len(NT, TBIT, 3);
		} else {
			putbits(TBIT, 0);  putbits(TBIT, root);
		}
		write_c_len();
	} else {
        putbits(TBIT, 0);  putbits(TBIT, 0);
		putbits(CBIT, 0);  putbits(CBIT, root);
	}
	root = make_tree(NP, p_freq, pt_len, pt_code);
	if (root >= NP) {
		write_pt_len(NP, PBIT, -1);
	} else {
		putbits(PBIT, 0);  putbits(PBIT, root);
	}
	pos = 0;
	for (i = 0; i < size; i++) {
		if (i % CHAR_BIT == 0) flags = buf[pos++];  else flags <<= 1;
		if (flags & (1U << (CHAR_BIT - 1))) {
			encode_c(buf[pos++] + (1U << CHAR_BIT));
			k = buf[pos++] << CHAR_BIT;  k += buf[pos++];
			encode_p(k);
		} else encode_c(buf[pos++]);
		if (unpackable) return;
	}
	for (i = 0; i < NC; i++) c_freq[i] = 0;
	for (i = 0; i < NP; i++) p_freq[i] = 0;
}
uint output_pos, output_mask;

#ifdef _lhufs_
extern void output5(uint c, uint p);
#else
void output5(uint c, uint p)
{
	static uint cpos;

	if ((output_mask >>= 1) == 0) {
		output_mask = 1U << (CHAR_BIT - 1);
		if (output_pos >= bufsiz - 3 * CHAR_BIT) {
			send_block();
			if (unpackable) return;
			output_pos = 0;
		}
		cpos = output_pos++;  buf[cpos] = 0;
	}
	buf[output_pos++] = (uchar) c;  c_freq[c]++;
	if (c >= (1U << CHAR_BIT)) {
		buf[cpos] |= output_mask;
		buf[output_pos++] = (uchar)(p >> CHAR_BIT);
		buf[output_pos++] = (uchar) p;
		c = 0;  while (p) {  p >>= 1;  c++;  }
		p_freq[c]++;
	}
}
#endif
void start_huf(void)
{
	int i;

	if (bufsiz == 0) {
		bufsiz = 16 * 1024U;
		while ((buf = malloc(bufsiz)) == NULL) {
			bufsiz = (bufsiz / 10U) * 9U;
			if (bufsiz < 4 * 1024U) error("Out of memory.");
		}
	}
	buf[0] = 0;
	for (i = 0; i < NC; i++) c_freq[i] = 0;
	for (i = 0; i < NP; i++) p_freq[i] = 0;
	output_pos = output_mask = 0;
	init_putbits();
}

void end_huf(void)
{
	if (! unpackable) {
		send_block();
		putbits(CHAR_BIT - 1, 0);  /* flush remaining bits */
	}
}

/***** decoding *****/

static void read_pt_len(int nn, int nbit, int i_special)
{
	int i, c, n;
	uint mask;

	n = getbits(nbit);
	if (n == 0) {
		c = getbits(nbit);
		for (i = 0; i < nn; i++) pt_len[i] = 0;
		for (i = 0; i < 256; i++) pt_table[i] = c;
	} else {
		i = 0;
		while (i < n) {
			c = bitbuf >> (BITBUFSIZ - 3);
			if (c == 7) {
				mask = 1U << (BITBUFSIZ - 1 - 3);
				while (mask & bitbuf) {  mask >>= 1;  c++;  }
			}
			fillbuf((c < 7) ? 3 : c - 3);
			pt_len[i++] = c;
			if (i == i_special) {
				c = getbits(2);
				while (--c >= 0) pt_len[i++] = 0;
			}
		}
		while (i < nn) pt_len[i++] = 0;
		make_table(nn, pt_len, 8, pt_table);
	}
}

static void read_c_len(void)
{
	int i, c, n;
	uint mask;

	n = getbits(CBIT);
	if (n == 0) {
		c = getbits(CBIT);
		for (i = 0; i < NC; i++) c_len[i] = 0;
		for (i = 0; i < 4096; i++) c_table[i] = c;
	} else {
		i = 0;
		while (i < n) {
			c = pt_table[bitbuf >> (BITBUFSIZ - 8)];
			if (c >= NT) {
				mask = 1U << (BITBUFSIZ - 1 - 8);
				do {
					if (bitbuf & mask) c = right[c];
					else               c = left [c];
					mask >>= 1;
				} while (c >= NT);
			}
			fillbuf(pt_len[c]);
			if (c <= 2) {
				if      (c == 0) c = 1;
				else if (c == 1) c = getbits(4) + 3;
				else             c = getbits(CBIT) + 20;
				while (--c >= 0) c_len[i++] = 0;
			} else c_len[i++] = c - 2;
		}
		while (i < NC) c_len[i++] = 0;
		make_table(NC, c_len, 12, c_table);
	}
}

static uint decode_c(void)
{
	uint j, mask;

	if (blocksize == 0) {
		blocksize = getbits(16);
		read_pt_len(NT, TBIT, 3);
		read_c_len();
		read_pt_len(NP, PBIT, -1);
	}
	blocksize--;
	j = c_table[bitbuf >> (BITBUFSIZ - 12)];
	if (j >= NC) {
		mask = 1U << (BITBUFSIZ - 1 - 12);
		do {
			if (bitbuf & mask) j = right[j];
			else               j = left [j];
			mask >>= 1;
		} while (j >= NC);
	}
	fillbuf(c_len[j]);
	return j;
}

static uint decode_p(void)
{
	uint j, mask;

	j = pt_table[bitbuf >> (BITBUFSIZ - 8)];
	if (j >= NP) {
		mask = 1U << (BITBUFSIZ - 1 - 8);
		do {
			if (bitbuf & mask) j = right[j];
			else               j = left [j];
			mask >>= 1;
		} while (j >= NP);
	}
	fillbuf(pt_len[j]);
	if (j != 0) j = (1U << (j - 1)) + getbits(j - 1);
	return j;
}

static void huf_decode_start(void)
{
	init_getbits();  blocksize = 0;
}

/* ----------------------End   of huf.c ------------------------------- */

/* ----------------------Start of maketre.c---------------------------- */

/***********************************************************
	maketree.c -- make Huffman tree
***********************************************************/

static int    n, heapsize;
static short  heap[NC + 1];
static ushort *freq, *sortptr, len_cnt[17];
static uchar  *len;

static void count_len(int i)  /* call with i = root */
{
	static int depth = 0;

	if (i < n) len_cnt[(depth < 16) ? depth : 16]++;
	else {
		depth++;
		count_len(left [i]);
		count_len(right[i]);
		depth--;
	}
}

static void make_len(int root)
{
	int i, k;
	uint cum;

	for (i = 0; i <= 16; i++) len_cnt[i] = 0;
	count_len(root);
	cum = 0;
	for (i = 16; i > 0; i--)
		cum += len_cnt[i] << (16 - i);
	while (cum != (1U << 16)) {
		fprintf(stderr, "17");
		len_cnt[16]--;
		for (i = 15; i > 0; i--) {
			if (len_cnt[i] != 0) {
				len_cnt[i]--;  len_cnt[i+1] += 2;  break;
			}
		}
		cum--;
	}
	for (i = 16; i > 0; i--) {
		k = len_cnt[i];
		while (--k >= 0) len[*sortptr++] = i;
	}
}

static void downheap(int i)
	/* priority queue; send i-th entry down heap */
{
	int j, k;

	k = heap[i];
	while ((j = 2 * i) <= heapsize) {
		if (j < heapsize && freq[heap[j]] > freq[heap[j + 1]])
		 	j++;
		if (freq[k] <= freq[heap[j]]) break;
		heap[i] = heap[j];  i = j;
	}
	heap[i] = k;
}

static void make_code(int n, uchar len[], ushort code[])
{
	int    i;
	ushort start[18];

	start[1] = 0;
	for (i = 1; i <= 16; i++)
		start[i + 1] = (start[i] + len_cnt[i]) << 1;
	for (i = 0; i < n; i++) code[i] = start[len[i]]++;
}

int make_tree(int nparm, ushort freqparm[],
				uchar lenparm[], ushort codeparm[])
	/* make tree, calculate len[], return root */
{
	int i, j, k, avail;

	n = nparm;  freq = freqparm;  len = lenparm;
	avail = n;  heapsize = 0;  heap[1] = 0;
	for (i = 0; i < n; i++) {
		len[i] = 0;
		if (freq[i]) heap[++heapsize] = i;
	}
	if (heapsize < 2) {
		codeparm[heap[1]] = 0;  return heap[1];
	}
	for (i = heapsize / 2; i >= 1; i--)
		downheap(i);  /* make priority queue */
	sortptr = codeparm;
	do {  /* while queue has at least two entries */
		i = heap[1];  /* take out least-freq entry */
		if (i < n) *sortptr++ = i;
		heap[1] = heap[heapsize--];
		downheap(1);
		j = heap[1];  /* next least-freq entry */
		if (j < n) *sortptr++ = j;
		k = avail++;  /* generate new node */
		freq[k] = freq[i] + freq[j];
		heap[1] = k;  downheap(1);  /* put into queue */
		left[k] = i;  right[k] = j;
	} while (heapsize > 1);
	sortptr = codeparm;
	make_len(k);
	make_code(nparm, lenparm, codeparm);
	return k;  /* return root */
}

/* ----------------------End   of maketre.c---------------------------- */
/* ----------------------End   of maketbl.c---------------------------- */

/***********************************************************
	maketbl.c -- make table for decoding
***********************************************************/

static void make_table(int nchar, uchar bitlen[], int tablebits, ushort table[])
{
	ushort count[17], weight[17], start[18], *p;
	uint i, k, len, ch, jutbits, avail, nextcode, mask;

	for (i = 1; i <= 16; i++) count[i] = 0;
	for (i = 0; i < nchar; i++) count[bitlen[i]]++;

	start[1] = 0;
	for (i = 1; i <= 16; i++)
		start[i + 1] = start[i] + (count[i] << (16 - i));
	if (start[17] != (ushort)(1U << 16)) error("Bad table");

	jutbits = 16 - tablebits;
	for (i = 1; i <= tablebits; i++) {
		start[i] >>= jutbits;
		weight[i] = 1U << (tablebits - i);
	}
	while (i <= 16) weight[i++] = 1U << (16 - i);

	i = start[tablebits + 1] >> jutbits;
	if (i != (ushort)(1U << 16)) {
		k = 1U << tablebits;
		while (i != k) table[i++] = 0;
	}

	avail = nchar;
	mask = 1U << (15 - tablebits);
	for (ch = 0; ch < nchar; ch++) {
		if ((len = bitlen[ch]) == 0) continue;
		nextcode = start[len] + weight[len];
		if (len <= tablebits) {
			for (i = start[len]; i < nextcode; i++) table[i] = ch;
		} else {
			k = start[len];
			p = &table[k >> jutbits];
			i = len - tablebits;
			while (i != 0) {
				if (*p == 0) {
					right[avail] = left[avail] = 0;
					*p = avail++;
				}
				if (k & mask) p = &right[*p];
				else          p = &left[*p];
				k <<= 1;  i--;
			}
			*p = ch;
		}
		start[len] = nextcode;
	}
}

/* ----------------------End   of maketbl.c---------------------------- */

/* --------------------- start of decode.c ---------------------------- */


static int dec_j;  /* remaining bytes to copy */

static void decode_start(void)
{
	huf_decode_start();
	dec_j = 0;
}

static void decode5(uint count, uchar buffer[])
	/* The calling function must keep the number of
	   bytes to be processed.  This function decodes
	   either 'count' bytes or 'DICSIZ' bytes, whichever
	   is smaller, into the array 'buffer[]' of size
	   'DICSIZ' or more.
	   Call decode_start() once for each new file
	   before calling this function. */
{
	static uint i;
	uint r, c;

	r = 0;
	while (--dec_j >= 0) {
		buffer[r] = buffer[i];
		i = (i + 1) & (DICSIZ - 1);
		if (++r == count) return;
	}
	for ( ; ; ) {
		c = decode_c();
		if (c <= UCHAR_MAX) {
			buffer[r] = c;
			if (++r == count) return;
		} else {
			dec_j = c - (UCHAR_MAX + 1 - THRESHOLD);
			i = (r - decode_p() - 1) & (DICSIZ - 1);
			while (--dec_j >= 0) {
				buffer[r] = buffer[i];
				i = (i + 1) & (DICSIZ - 1);
				if (++r == count) return;
			}
		}
	}
}


void decode_lh5(ulong orgsize, ulong pacsize)
{
  int n;
  make_crctable();
  origsize=orgsize;
  compsize=pacsize;
  crc = INIT_CRC;

  decode_start();
  while (origsize != 0) {
  	n = (uint)((origsize > DICSIZ) ? DICSIZ : origsize);
  	decode5(n, buffer);
  	fwrite_crc(buffer, n, outfile);
  	if (outfile != stdout) if (!flg_n) putc('*', stdout);
  	origsize -= n;
  }
}

/* ------------------------End of Deocde.c- --------------------------- */

/* ----------------------Start of Encode.c ---------------------------- */

/***********************************************************
	encode.c -- sliding dictionary with percolating update
***********************************************************/

#define PERCOLATE  1
#define NIL        0
#define MAX_HASH_VAL (3 * DICSIZ + (DICSIZ / 512 + 1) * UCHAR_MAX)

typedef short node;

extern uchar *text, *childcount;
extern node pos, matchpos, avail, *position, *parent, *prev, *next = NULL;
extern int remainder, matchlen;

#if MAXMATCH <= (UCHAR_MAX + 1)
	extern uchar *level;
#else
	extern ushort *level;
#endif

void allocate_memory(void)
{
	if (next != NULL) return;
    text = malloc(DICSIZ * 2 + MAXMATCH);
	level      = malloc((DICSIZ + UCHAR_MAX + 1) * sizeof(*level));
	childcount = malloc((DICSIZ + UCHAR_MAX + 1) * sizeof(*childcount));
	#if PERCOLATE
	  position = malloc((DICSIZ + UCHAR_MAX + 1) * sizeof(*position));
	#else
	  position = malloc(DICSIZ * sizeof(*position));
	#endif
	parent     = malloc(DICSIZ * 2 * sizeof(*parent));
	prev       = malloc(DICSIZ * 2 * sizeof(*prev));
	next       = malloc((MAX_HASH_VAL + 1) * sizeof(*next));
	if (next == NULL) error("Out of memory.");
}

#ifdef _lhufs_
/* extern void split(node old);
extern void insert_node(void);
extern void delete_node(void);
extern void get_next_match(void);
extern ulong encode5(ulong orgsize); */
#else

void init_slide(void)
{
	node i;

	for (i = DICSIZ; i <= DICSIZ + UCHAR_MAX; i++) {
		level[i] = 1;
		#if PERCOLATE
			position[i] = NIL;  /* sentinel */
		#endif
	}
	for (i = DICSIZ; i < DICSIZ * 2; i++) parent[i] = NIL;
	avail = 1;
	for (i = 1; i < DICSIZ - 1; i++) next[i] = i + 1;
	next[DICSIZ - 1] = NIL;
	for (i = DICSIZ * 2; i <= MAX_HASH_VAL; i++) next[i] = NIL;
}

#define HASH(p, c) ((p) + ((c) << (DICBIT - 9)) + DICSIZ * 2)

node child(node q, uchar c)
	/* q's child for character c (NIL if not found) */
{
	node r;

	r = next[HASH(q, c)];
	parent[NIL] = q;  /* sentinel */
	while (parent[r] != q) r = next[r];
	return r;
}

void makechild(node q, uchar c, node r)
	/* Let r be q's child for character c. */
{
	node h, t;

	h = HASH(q, c);
	t = next[h];  next[h] = r;  next[r] = t;
	prev[t] = r;  prev[r] = h;
	parent[r] = q;  childcount[q]++;
}
static void split(node old)
{
	node new, t;

	new = avail;  avail = next[new];  childcount[new] = 0;
	t = prev[old];  prev[new] = t;  next[t] = new;
	t = next[old];  next[new] = t;  prev[t] = new;
	parent[new] = parent[old];
	level[new] = matchlen;
	position[new] = pos;
	makechild(new, text[matchpos + matchlen], old);
	makechild(new, text[pos + matchlen], pos);
}
static void insert_node(void)
{
	node q, r, j, t;
	uchar c, *t1, *t2;
	int matchl;

	matchl=matchlen;

	if (matchl >= 4) {
		matchl--;
		r = (matchpos + 1) | DICSIZ;
		while ((q = parent[r]) == NIL) r = next[r];
		while (level[q] >= matchl) {
			r = q;  q = parent[q];
		}
		#if PERCOLATE
			t = q;
			while (position[t] < 0) {
				position[t] = pos;  t = parent[t];
			}
			if (t < DICSIZ) position[t] = pos | PERC_FLAG;
		#else
			t = q;
			while (t < DICSIZ) {
				position[t] = pos;  t = parent[t];
			}
		#endif
	} else {
		q = text[pos] + DICSIZ;  c = text[pos + 1];
		matchlen=matchl;
		if ((r = child(q, c)) == NIL) {
			makechild(q, c, pos);  matchl = 1;
			return;
		}
		matchl = 2;
	}
	for ( ; ; ) {
		if (r >= DICSIZ) {
			j = MAXMATCH;  matchpos = r;
		} else {
			j = level[r];
			matchpos = position[r] & ~PERC_FLAG;
		}
		if (matchpos >= pos) matchpos -= DICSIZ;
		t1 = &text[pos + matchl];  t2 = &text[matchpos + matchl];
		while (matchl < j) {
			if (*t1 != *t2) {  matchlen=matchl; split(r);  return;  }
			matchl++;  t1++;  t2++;
		}
		if (matchl >= MAXMATCH) break;
		position[r] = pos;
		q = r;
		if ((r = child(q, *t1)) == NIL) {
		    matchlen=matchl;
			makechild(q, *t1, pos);  return;
		}
		matchl++;
	}
	t = prev[r];  prev[pos] = t;  next[t] = pos;
	t = next[r];  next[pos] = t;  prev[t] = pos;
	parent[pos] = q;  parent[r] = NIL;
	next[r] = pos;  /* special use of next[] */
	matchlen=matchl;
}
static void delete_node(void)
{
	#if PERCOLATE
		node q, r, s, t, u;
	#else
		node r, s, t, u;
	#endif

	if (parent[pos] == NIL) return;
	r = prev[pos];  s = next[pos];
	next[r] = s;  prev[s] = r;
	r = parent[pos];  parent[pos] = NIL;
	if (r >= DICSIZ || --childcount[r] > 1) return;
	#if PERCOLATE
		t = position[r] & ~PERC_FLAG;
	#else
		t = position[r];
	#endif
	if (t >= pos) t -= DICSIZ;
	#if PERCOLATE
		s = t;  q = parent[r];
		while ((u = position[q]) & PERC_FLAG) {
			u &= ~PERC_FLAG;  if (u >= pos) u -= DICSIZ;
			if (u > s) s = u;
			position[q] = (s | DICSIZ);  q = parent[q];
		}
		if (q < DICSIZ) {
			if (u >= pos) u -= DICSIZ;
			if (u > s) s = u;
			position[q] = s | DICSIZ | PERC_FLAG;
		}
	#endif
	s = child(r, text[t + level[r]]);
	t = prev[s];  u = next[s];
	next[t] = u;  prev[u] = t;
	t = prev[r];  next[t] = s;  prev[s] = t;
	t = next[r];  prev[t] = s;  next[s] = t;
	parent[s] = parent[r];  parent[r] = NIL;
	next[r] = avail;  avail = r;
}

static void get_next_match(void)
{
	int n;

	remainder--;
	if (++pos == DICSIZ * 2) {
		memmove(&text[0], &text[DICSIZ], DICSIZ + MAXMATCH);
		n = fread_crc(&text[DICSIZ + MAXMATCH], DICSIZ, infile);
		remainder += n;  pos = DICSIZ;  if (!flg_n) putc('*', stdout);
	}
	delete_node();  insert_node();
}

void init_encode5(void)
{
  allocate_memory();  init_slide();  start_huf();
}

ulong encode5(ulong orgsize)
{
	int lastmatchlen;
	node lastmatchpos;
	unpackable=0;
	make_crctable();
	origsize=orgsize;
	compsize=0;

	remainder = fread_crc(&text[DICSIZ], DICSIZ + MAXMATCH, infile);
	if (!flg_n) putc('*', stdout);
	matchlen = 0;
	pos = DICSIZ;  insert_node();
	if (matchlen > remainder) matchlen = remainder;
	while (remainder > 0 && ! unpackable) {
		lastmatchlen = matchlen;  lastmatchpos = matchpos;
		get_next_match();
		if (matchlen > remainder) matchlen = remainder;
		if (matchlen > lastmatchlen || lastmatchlen < THRESHOLD)
			output5(text[pos - 1], 0);
		else {
			output5(lastmatchlen + (UCHAR_MAX + 1 - THRESHOLD),
				   (pos - lastmatchpos - 2) & (DICSIZ - 1));
			while (--lastmatchlen > 0) get_next_match();
			if (matchlen > remainder) matchlen = remainder;
		}
	}
	end_huf();
	if (unpackable) compsize=orgsize+1;
	return compsize;
}
#endif
/* ----------------------- End of Encode.c ---------------------------- */
