/**************************************************
*
*  example bindings for vq_devinfo()
*
*  This file is provided for info only, it probably needs mods
*/

void vq_devinfo(int handle, int device, int *dev_open, char *file_name, char *device_name)
{
register short	i;
short	len;

   _intin[0] = device;
   _control[0] = 248;
   _control[1] = 0;
   _control[3] = 1;
   _control[5] = 0;
   /* _control[6] = handle;   not necessary! */

   /* workaround for fontgdos & earlier versions of GDOS ... */
   _intout[0] = 0;	/* only set if driver found */
   _contrl[2] = 1;   /* nr words in ptsout */
   _contrl[4] = 11;  /* strlen(filename) */

   vdi();		/* call vdi */

   *dev_open = _ptsout[0];

   if( _intout[0] != 0 ) {	/* if anything returned */
      for( i=0; i<_contrl[4]; i++ ) {	/* for each char in filename */
      register char c = (char)_intout[i];
         if( c != ' ' ) {
            if( i>=1 && _intout[i-1] == ' ' ) *file_name++ = '.';
            *file_name++ = c;
         } /* if */
      } /* for */

      /* Name in ptsout als C-String, d.h. pro ptsout[] 2 Buchstaben!! */
      if((_control[2] == 1 ) && (_control[1] > 0 )) /* says so in NVDI4-Doc */
         len = _control[1];
      else
         len = _control[2] - 1;
      for(i=1; i<=len; i++) *((short *)device_name)++ = _ptsout[i];
   } /* if */

   *file_name = 0;             /* null terminate */
   *device_name = 0;
} /* vq_devinfo() */
