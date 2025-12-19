/***************************************************************************
****  Ausdruck um 90 Grad gedreht                                       ****
***************************************************************************/

/* DREHE_90.S ist natÅrlich schneller */

void drehe_90( char *quelle, char *ziel, long qweite, long zweite, long x )
{
	register	i, data;

	quelle += (x/8);
	x %= 8;
	x = (7-x);
	for(  i=0;  i<=zweite;  i++  )
	{
		data = ((*quelle>>x)&1);
		quelle += qweite;
		data |= ((*quelle>>x)&1)<<1;
		quelle += qweite;
		data |= ((*quelle>>x)&1)<<2;
		quelle += qweite;
		data |= ((*quelle>>x)&1)<<3;
		quelle += qweite;
		data |= ((*quelle>>x)&1)<<4;
		quelle += qweite;
		data |= ((*quelle>>x)&1)<<5;
		quelle += qweite;
		data |= ((*quelle>>x)&1)<<6;
		quelle += qweite;
		data |= ((*quelle>>x)&1)<<7;
		quelle += qweite;
		ziel[zweite-i] = data;
	}
}


/* email: prissi@marie.physik.tu-berlin.de
 * Post:  Markus Pristovsek
 *        Boumannstraûe 66
 *        13467 Berlin
 */