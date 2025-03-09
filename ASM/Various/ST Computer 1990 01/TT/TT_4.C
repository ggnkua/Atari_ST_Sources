*******************************************************************
* Listing 3 noch einmal als C-Funktion, in Anlehnung an [4].      *
* Das Ergebnis ist TRUE, falls es sich um einen TT handelt.       *
*******************************************************************


#define MCH 0x5f4d4348l /* Cookie fr Prozessortyp */


struct cookie
  {
  long c;
  long v;
  };


boolean tttest()
{
  long oldssp=0;
  struct cookie *cookie_ptr;

  if (!Super(1l)) oldssp=Super(0l);
  cookie_ptr= *(struct cookie **) 0x5a0;
  if (oldssp) Super(oldssp);
  if (cookie_ptr)
    {
    while (cookie_ptr->c)
      {
      if (cookie_ptr->c!=MCH) cookie_ptr++;
      else break;
      }
    if (cookie_ptr->c) return(cookie_ptr->v>=0x00020000l);
    }
  return(FALSE);
}

