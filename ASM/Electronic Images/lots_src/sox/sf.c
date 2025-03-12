/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools IRCAM SoundFile format handler.
 * 
 * Derived from: Sound Tools skeleton handler file.
 */

#include "st.h"
#include "sfheader.h"
#include <string.h>

/* Private data for SF file */
typedef struct sfstuff {
	struct sfinfo info;
} *sf_t;

IMPORT int summary, verbose;

/*
 * Read the codes from the sound file, allocate space for the comment and
 * assign its pointer to the comment field in ft.
 */
readcodes(ft, sfhead)
ft_t ft;
SFHEADER *sfhead;
{
	char *commentbuf = NULL, *sfcharp, *newline;
	short bsize, finished = 0;
	SFCODE *sfcodep;

	sfcodep = (SFCODE *) &sfcodes(sfhead);
	do {
		sfcharp = (char *) sfcodep + sizeof(SFCODE);
		if (ft->swap) {
			sfcodep->bsize = swapl(sfcodep->bsize);
			sfcodep->code = swapl(sfcodep->code);
		}
		bsize = sfcodep->bsize - sizeof(SFCODE);
		switch(sfcodep->code) {
		case SF_END:
			finished = 1;
			break;
		case SF_COMMENT:
			if((commentbuf = (char *) malloc(bsize + 1)) != NULL) {
				bcopy(sfcharp, commentbuf, bsize);
				report("IRCAM comment: %s", sfcharp);
				commentbuf[bsize] = '\0';
				if((newline = strchr(commentbuf, '\n')) != NULL)
					*newline = '\0';
			}
			break;
		}
		sfcodep = (SFCODE *) (sfcharp + bsize);
	} while(!finished);
	if(commentbuf != NULL)	/* handles out of memory condition as well */
		ft->comment = commentbuf;
}

/*
 * Do anything required before you start reading samples.
 * Read file header. 
 *	Find out sampling rate, 
 *	size and style of samples, 
 *	mono/stereo/quad.
 */
sfstartread(ft) 
ft_t ft;
{
	sf_t sf = (sf_t) ft->priv;
	SFHEADER sfhead;
	int i;
	
	if (fread(&sfhead, 1, sizeof(SFHEADER), ft->fp) != sizeof(SFHEADER))
		fail("unexpected EOF in SF header");
	bcopy(&sfhead.sfinfo, &sf->info, sizeof(struct sfinfo));
	if (ft->swap) {
		sf->info.sf_magic = swapl(sf->info.sf_magic);
		sf->info.sf_srate = swapl(sf->info.sf_srate);
		sf->info.sf_packmode = swapl(sf->info.sf_packmode);
		sf->info.sf_chans = swapl(sf->info.sf_chans);
	}
	if (sf->info.sf_magic != SF_MAGIC)
		if (sf->info.sf_magic == swapl(SF_MAGIC))
			fail("SF %s file: can't read, it is probably byte-swapped");
		else
			fail("SF %s file: can't read, it is not an IRCAM SoundFile");

	/*
	 * If your format specifies or your file header contains
	 * any of the following information. 
	 */
	ft->info.rate = sf->info.sf_srate;
	switch(sf->info.sf_packmode) {
		case SF_SHORT:
			ft->info.size = WORD;
			ft->info.style = SIGN2;
			break;
		case SF_FLOAT:
			ft->info.size = FLOAT;
			ft->info.style = SIGN2;
			break;
		default:
			fail("Soundfile input: unknown format 0x%x\n",
				sf->info.sf_packmode);
	}
	ft->info.channels = sf->info.sf_chans;

	/* Read codes and print as comments. */
	readcodes(ft, &sfhead);
}

sfstartwrite(ft) 
ft_t ft;
{
	sf_t sf = (sf_t) ft->priv;
	SFHEADER sfhead;
	SFCODE *sfcodep;
	char *sfcharp;
	int i;

	sf->info.sf_magic = SF_MAGIC;
	sf->info.sf_srate = ft->info.rate;
#ifdef	LATER
	/* 
	 * CSound sound-files have many formats. 
	 * We stick with the IRCAM short-or-float scheme.
	 */
	if (ft->info.size == WORD) {
		sf->info.sf_packmode = SF_SHORT;
		ft->info.style = SIGN2;		/* Default to signed words */
	} else if (ft->info.size == FLOAT)
		sf->info.sf_packmode = SF_FLOAT;
	else
		fail("SoundFile %s: must set output as signed shorts or floats",
			ft->filename);
#else
	if (ft->info.size == FLOAT) {
		sf->info.sf_packmode = SF_FLOAT;
		ft->info.size = FLOAT;
	} else {
		sf->info.sf_packmode = SF_SHORT;
		ft->info.size = WORD;
		ft->info.style = SIGN2;		/* Default to signed words */
	}
#endif
	sf->info.sf_chans = ft->info.channels;

	bcopy(&sf->info, &sfhead.sfinfo, sizeof(struct sfinfo));
	sfcodep = (SFCODE *) &sfcodes(&sfhead);
	sfcodep->code = SF_COMMENT;
	sfcodep->bsize = strlen(ft->comment) + sizeof(SFCODE);
	sfcharp = (char *) sfcodep;
	strcpy(sfcharp + sizeof(SFCODE), ft->comment);
	sfcodep = (SFCODE *) (sfcharp + sfcodep->bsize);
	sfcodep->code = SF_END;
	sfcodep->bsize = sizeof(SFCODE);
	sfcharp = (char *) sfcodep + sizeof(SFCODE);
	while(sfcharp < (char *) &sfhead + SIZEOF_BSD_HEADER)
		*sfcharp++ = '\0';
	(void) fwrite(&sfhead, 1, sizeof(SFHEADER), ft->fp);
}

/* Read and write are supplied by raw.c */



