/*****************************************************************************
*
* shell sort function (standard K&R sort)
* For interface with GFA Basic to sort an array of (strings$)
* Program by Timothy Purves of MichTron Inc.
*  Compiled with Alcyon Compiler
*  To be linked with REL.O
*****************************************************************************/
#define EVEN (~1L)

typedef struct
{
     char     *address;
     int     len;
} VARPTR;

main(number,base)
int number;
VARPTR *base;
{
     int gap,i,j;

     for (gap = number / 2 ;gap > 0;gap /= 2)
          for(i = gap;i < number;i++)
               for(j = i-gap;j >= 0;j -= gap)
                    if(stringcmp(base + j, base + (j + gap)))
                         break;
}

stringcmp(s,d)
VARPTR *s,*d;
{
     char *sptr,*dptr;
     int slen,dlen,diff;

     slen = (sptr = s->address) ? s->len : 0;
     dlen = (dptr = d->address) ? d->len : 0;
     diff = 0;

     /* while data in both strings and chars are the same */
     while(slen && dlen && (diff = *sptr - *dptr) == 0)
          {
          ++sptr;     /* next token */
          ++dptr;
          --slen;
          --dlen;
          }

     /* if first is NULL and second has data
          || if(first > second
          || same up to second lenght and first is longer
     */

     if((dptr && !sptr) || diff > 0 || (diff == 0 && slen))
          {
          sptr = s->address;
          slen = s->len;
          s->address = d->address;
          s->len = d->len;
          d->address = sptr;
          d->len = slen;

          *((VARPTR **)(((long)s->address + s->len + 1) & EVEN)) = s; /* back tracker */
          *((VARPTR **)(((long)d->address + d->len + 1) & EVEN)) = d; /* back tracker */

          return 0;     /* we swaped don't breakout! */
          }
     return 1;     /* break out */
}
