/*
 * function to compress resource files
 * the algorithm is fairly straight-forward:
 * (1) first, we find the least frequently occuring bytes
 * (2) next, we use 8 of those bytes, as follows:
 *       (a) to mark 0000
 *       (b) to mark ffff
 *       (c) to mark a run of 0s (next byte gives the run length)
 *       (d) to mark a run of ffs (next byte gives the run length)
 *       (e) to mark a run of arbitrary characters (next byte is the char,
 *            and the one following that is the run length)
 *	 (f) to mark 0000 0000
 *	 (g) to mark ffff ffff
 *	 (h) to mark tokenized strings
 *
 * The run character is also used as an escape character, i.e. to output
 * one of the reserved bytes, we output a 1-length run.
 *
 * The output file contains a header giving:
 * (1) The magic number 0xab08
 * (2) the size of the uncompressed data (as a LONG),
 * (3) followed by the 8 special bytes above
 * (4) followed by the number of tokens (a byte)
 * (5) the tokens themselves, as pascal format strings (i.e.
 *     a 1 byte length, followed by a 0-255 character string)
 * (6) finally, the compressed data
 */

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <stat.h>
#include <signal.h>

#define MAXESC 8

static int zeroc, ffffc, zerorunc, ffffrunc, runc;
static int longzeroc, longffffc;
static int tokenesc;

/* character frequency data */
static struct cdata {
	int ch;
	long frequency;
	long runs1;
	long runs2;
} d[256];

static int cmp(struct cdata *a, struct cdata *b)
{
	if (a->frequency != b->frequency)
		return a->frequency - b->frequency;
	return a->ch - b->ch;
}

#define output(c)	outbuf[outsize++] = c

/*
 * the compression is done in 2 passes. First, we do the run length
 * encoding and crunching out of 0's and FF's. Then, we take that output
 * and run it through the tokenizer
 */

/*
 * here is the tokenizer function
 * How it works:
 * We use a hash table; each n byte string in the file is
 * kept somewhere in the table, along with a count of how many times
 * it occurs.
 * After we've collected all the strings, we find the 255 most commonly
 * occuring strings and put them into a table. We then go through and
 * tokenize the file.
 */

static int tokensused;

#define HASHSIZE 15000

typedef unsigned char byte;

typedef struct hashentry {
	byte *str;	/* pointer to the actual string */
	int frequency;	/* how often this string appears */
	int hash;	/* what this string hashes to */
	struct hashentry *next;		/* link to next hash entry */
} hentry;

static hentry *hashtable[HASHSIZE];

#define TOKENSIZE 256

static hentry *tokens[TOKENSIZE];
static int numtokens;

inline static unsigned hashfunc(byte *str, int len)
{
	int i;
	unsigned hash = *str++;

	for (i = 1; i < len; i++) {
	  hash = i + (hash << 2) + *str++;
	}
	return hash % HASHSIZE;
}

inline static unsigned match(byte *str1, byte *str2, int len)
{
	int i;

	for (i = 0; i < len; i++) {
		if (*str1 != *str2) return 0;
		str1++; str2++;
	}
	return 1;
}

inline hentry *newhash()
{
	return malloc(sizeof(hentry));
}

inline static void update_table(unsigned hash, byte *str, int len)
{
	hentry *h, **lastnext, *y;
	long lastfrequency = 0x7fffffffL;
	hentry temp;

	h = hashtable[hash];
	lastnext = &hashtable[hash];
	while (h) {
		if (match(str, h->str, len)) {
			h->frequency++;
		/* see if we moved up in frequency */
			if (h->frequency > lastfrequency) {
		/* if so, swap with the previous entry */
				for (y = hashtable[hash]; y; y = y->next) {
					if (y->next == h) {
						temp = *y;
						y->frequency = h->frequency;
						y->str = h->str;
						h->frequency = temp.frequency;
						h->str = temp.str;
						return;
					}
				}
			}
			return;
		}
		lastnext = &h->next;
		lastfrequency = h->frequency;
		h = h->next;
	}
	h = newhash();
	h->str = str;
	h->frequency = 1;
	h->next = 0;
	h->hash = hash;
	*lastnext = h;
}

extern int gl_matchsize;

/*
 * return the highest-frequency string remaining in the table, and delete
 * it from the table
 *
 * In update_table we kept the highest frequency strings at the beginning
 * of the table, so we only need to check the first hash table entry for
 * each hash value.
 *
 * returns NULL if no string occurs more than once
 */

static hentry *
reporthigh()
{
	long i;
	hentry *h;
	long maxfrequency = 1;
	unsigned maxhash = 0;
	byte *ptr;

	maxhash = 0;
	for (i = 0; i < HASHSIZE; i++) {
		h = hashtable[i];
		if (h && h->frequency > maxfrequency) {
			maxhash = i;
			maxfrequency = h->frequency;
		}
	}
	if (maxfrequency == 1) return 0;
	h = hashtable[maxhash];
	ptr = h->str;
	hashtable[maxhash] = h->next;
	return h;
}

int no_more_tokens = 0;

void ctrlc()
{
	no_more_tokens = 1;
}


/*
 * long tokenize(byte *input, long inpsize, byte *output):
 * input points to the input buffer
 * inpsize is the number of bytes in that buffer
 * output points to the output buffer
 * returns: number of bytes written to the output buffer
 */

static long
tokenize(byte *input, long inpsize, byte *output)
{
	long i;
	long outsize;
	int matchsize;
	unsigned hash;
	hentry *h;
	byte *ptr, *outptr;
	int c, j;

	signal(SIGINT, ctrlc);

	matchsize = gl_matchsize;
	if (matchsize < 4) {
		fprintf(stderr, "strings must be at least 4 bytes long\n");
		return 0;
	}

	ptr = input;

	printf("analyzing for tokens...\n");

	for (i = 0; i < inpsize - matchsize; i++) {
		hash = hashfunc(ptr, matchsize);
		update_table(hash, ptr, matchsize);
		ptr++;
	}

	printf("getting tokens...\n");

/*
 * whenever a hash table entry is taken from the hash table and
 * put into the tokens table, its frequency changes meaning:
 * after this point, it means the number of times the token
 * is used
 */
	numtokens = 1;

moretokens:
	outsize = 0L;
	outptr = output;

	while (!no_more_tokens && numtokens < TOKENSIZE) {  
		h = reporthigh();
		if (!h || h->frequency < 3) {
			no_more_tokens = 1;
			break;
		}
		tokens[numtokens] = h;
		h->frequency = 0;
		numtokens++;
	}

	printf("compressing...\n");

	tokensused = 1;
	ptr = input;

	for (i = 0; i < inpsize; i++) {
		c = *ptr;
		hash = hashfunc(ptr, matchsize);
		for (j = 1; j < numtokens; j++) {
			if (hash == tokens[j]->hash &&
			    match(ptr, tokens[j]->str, matchsize)) {
				if (!tokens[j]->frequency) {
					tokens[j]->frequency++;
					tokensused++;
				}
				*outptr++ = tokenesc;
				*outptr++ = j;
				outsize += 2;
				ptr += matchsize;
				i += (matchsize-1);
				goto foundtoken;
			}
		}
		*outptr++ = c;
		outsize++;
		if (c == tokenesc) {
			*outptr++ = 0;
			outsize++;
		}
		ptr++;
foundtoken: ;
	}
	j = 1;
	for (i = 1; i < numtokens; i++) {
		if (tokens[i]->frequency) {
			tokens[i]->frequency = 0;
			tokens[j] = tokens[i];
			j++;
		}
	}
	if (tokensused < numtokens) {
		printf("only %d tokens used out of %d\n", tokensused,
			numtokens);
		printf("searching for more tokens\n");
		numtokens = j;
		goto moretokens;
	}
	numtokens = j;

	printf("tokenizing stage: input size: %ld\n", inpsize);
	i = 4L + (long)matchsize * numtokens;
	printf("output size: header: %ld body: %ld   total: %ld\n",
		i, outsize, i+outsize);

	return outsize;
}

long
crunch(byte *inbuf, long insize, byte *outbuf)
{
	int j, c;
	int lastc;
	int currunlen = 0;
	long i;
	int mustescape = 0;
	byte *ptr;
	long headsize;
	long outsize = 0;

	for (c = 0; c < 256; c++) {
		d[c].ch = c;
	}

	lastc = -1;
	for (i = 0; i < insize; i++) {
		c = inbuf[i];
		d[c].frequency++;
		if (c == lastc) {
			currunlen++;
		} else {
			if (currunlen > 2) {
				d[lastc].runs2++;
			} else if (currunlen) {
				d[lastc].runs1++;
			}
			currunlen = 0;
		}

		lastc = c;
	}

	qsort(d, (size_t)256, sizeof(struct cdata), cmp);

/* now, find our markers */
	zeroc = d[0].ch;
	ffffc = d[1].ch;
	zerorunc = d[2].ch;
	ffffrunc = d[3].ch;
	runc = d[4].ch;
	longzeroc = d[5].ch;
	longffffc = d[6].ch;
	tokenesc = d[7].ch;

	lastc = -1;
	currunlen = 0;
	mustescape = 0;

	for (i = 0; i <= insize; i++) {
		c = inbuf[i];
		if (c == lastc && currunlen < 255 && i != insize) {
			currunlen++;
		} else {
			if (mustescape || currunlen > 0) {
				if (lastc == 0) {
					if (currunlen == 1)
						output(zeroc);
					else if (currunlen == 3) {
						output(longzeroc);
					} else {
						output(zerorunc);
						output(currunlen);
					}
				} else if (lastc == 0xff) {
					if (currunlen == 1)
						output(ffffc);
					else if (currunlen == 3)
						output(longffffc);
					else {
						output(ffffrunc);
						output(currunlen);
					}
				} else {
					output(runc);
					output(lastc);
					output(currunlen);
				}
			} else {
				if (currunlen == 1)
					output(lastc);
				if (lastc >= 0)
					output(lastc);
			}

	/* check for special characters */
	/* note: the token escape character is escaped in the tokenizing code */
			mustescape = 0;
			for (j = 0; j < MAXESC-1; j++) {
				if (c == d[j].ch) {
					mustescape = 1;
				}
			}
			lastc = c;
			currunlen = 0;
		}

	}

	printf("before tokenizing: input size: %ld output size: %ld\n",
		insize, outsize);

/*
 * ASSUMPTION: input buffer is big enough to handle the overflow if
 * the file is actually expanded by our RLE encoding
 */
	for (i = 0; i < outsize; i++) {
		inbuf[i] = outbuf[i];
	}
	outsize = tokenize(inbuf, outsize, outbuf);


/* now we must copy the data to leave room for the compression header */
/* that header will be 8 bytes (escape characters) + 1 byte (no. of tokens)
 * plus (number of tokens-1) * (token size)
 */
	headsize = 9 + (numtokens-1) * (1L+gl_matchsize);

	for (i = outsize-1; i >= 0; --i) {
		outbuf[i+headsize] = outbuf[i];
	}

/* output the escape characters */
	outbuf[0] = zeroc;
	outbuf[1] = ffffc;
	outbuf[2] = zerorunc;
	outbuf[3] = ffffrunc;
	outbuf[4] = runc;
	outbuf[5] = longzeroc;
	outbuf[6] = longffffc;
	outbuf[7] = tokenesc;
	outbuf[8] = numtokens - 1;

/* output the token table */
	c = 9;

	for (i = 1; i < numtokens; i++) {
		outbuf[c++] = gl_matchsize;
		ptr = tokens[i]->str;
		for (j = 0; j < gl_matchsize; j++) {
			outbuf[c++] = *ptr++;
		}
	}

	if (c != headsize) {
		printf("WARNING: c == %ld headsize == %ld\n",
			(long)c, (long)headsize);
	}
	return outsize + headsize;
}
