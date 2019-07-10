/*
 * hash.c -- hash a string to an integer
 *
 * 90Aug27 AA	Split from old libhash.c
 */

short int
hash(char *str)
{
    register short int accum, shift, c;

    for (accum=shift=0; c = *str; (shift=(1+shift)&7), str++)
	accum ^= ((c=='_')?' ':toupper(c)) << shift;
    return accum;
}
