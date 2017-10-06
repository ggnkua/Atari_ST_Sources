/* Parameter:
*     start : Anfangsadresse des Samples (vorher)
*     end   : Endadresse des Samples (vorher)
*     unsign: Samplewerte sind unsigned (TRUE) oder signed (FALSE)
*
* Rckgabe:
*     neue Endadresse (Anfangsadresse bleibt gleich)
* Code by Dirk Haun (dirk@haun-online.de)
*/

unsigned char *to_eight(unsigned char *start,unsigned char *end,int unsign)
{
 int i, imn, imx, ic, *ip;
 unsigned int u, umn, umx, *up;
 long l, lmx;

 if(unsign)
 {
  up=(unsigned int*)start;
  umn=65535U;
  umx=0;
  while((unsigned char*)up<end)
  {
   u=*up++;
   if(u<umn) umn=u;
   else if(u>umx) umx=u;
  }
  lmx=umx; lmx-=umn;
  up=(unsigned int*)start;
  while((unsigned char*)up<end)
  {
   u=*up++;
   l=u; l-=umn;
   l*=255L;
   l/=lmx;
   l&=0x00ff;
   *start++=(unsigned char)l;
  }
  end=start;
 }
 else
 {
  ip=(int*)start;
  imn=32767;
  imx=-32767;
  while((unsigned char*)ip<end)
  {
   i=*ip++;
   if(i<imn) imn=i;
   else if(i>imx) imx=i;
  }
  ic=-imn;
  lmx=imx; lmx+=ic;
  ip=(int*)start;
  while((unsigned char*)ip<end)
  {
   i=*ip++;
   l=i+ic;
   l*=255L;
   l/=lmx;
   if(imn<0) l-=128;
   l&=0x00ff;
   *start++=(unsigned char)l;
  }
  end=start;
 }
 return(end);
}