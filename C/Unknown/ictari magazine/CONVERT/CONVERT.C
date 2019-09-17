/************************************************************************/
/* Convert a binary file into an Assebler file source code		*/
/************************************************************************/

/************************************************************************/
/* includes								*/
/************************************************************************/

#include <osbind.h>
#include <define.h>
#include <gemdefs.h>
#include <obdefs.h>

/************************************************************************/
/* externals								*/
/************************************************************************/

extern	int	gl_apid;

/************************************************************************/
/* Globals 								*/
/************************************************************************/

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];
int	work_in[11];
int	work_out[57];
int	pxyarray[10];

int	handle;
int	i,j;
int	phys_handle;
int	drive,fhandle,f2handle;

char	pathname[65];
char	currpath[65] = "?:";
char	filename[15];
char	buffer[32767];


main()
{ int  fs_exit;

  appl_init();
  for (i=0;i<10;work_in[i++]=1);
  work_in[10] = 2;
  handle = phys_handle;
  v_opnvwk(work_in,&handle,work_out);

  graf_mouse(M_OFF,0x0L);
  v_clrwk(handle);
  graf_mouse(M_ON,0x0L);

  drive = Dgetdrv();
  currpath[0] = 'A'+drive;
  Dgetpath(&currpath[2],drive+1);
  strcat(currpath,"\\*.*");

  do
  {  fsel_input(currpath,filename,&fs_exit);
     if (fs_exit)
       { v_clrwk(handle);
         graf_mouse(M_OFF,0x0L);
         v_enter_cur(handle);
         v_curhome(handle);
	 pathname[0] = '\0';
	 strcat(pathname,currpath);
	 add_filename(pathname,filename);
	 convert(pathname);
	 graf_mouse(M_ON,0x0L);
	 v_exit_cur(handle);
       }
   }
  while (fs_exit);

  graf_mouse(M_ON,0x0L);

  appl_exit();
    
}

convert(fname)
char	*fname;

{ long count;
  fhandle = Fopen(fname,0);
  strip_ext(fname);
  strcat(fname,".s");
  f2handle = Fcreate(fname,0);

  count = Fread(fhandle,32767L,buffer);
  for (i=0;i<count;i+=2)
    { if ((i % 16) == 0)
        Fwrite(f2handle,8L,"\n\r\tdc.w\t");
      else
	Fwrite(f2handle,2L,", ");
      fi_s_num(f2handle,(buffer[i] << 8)+buffer[i+1]);
    }
   
  Fclose(f2handle);
  Fclose(fhandle);
}

/************************************************************************/
/* strlen gets the string length of the string				*/
/************************************************************************/

int	strlen(str_ptr)

char	*str_ptr;

{ int	ret_count;

  for (ret_count=0;*str_ptr++ != '\0';ret_count++); /* set length to zero */

  return(ret_count);

}

/**************************************************************************/
/* strcat concats 2 strings together					  */
/**************************************************************************/

strcat(str1_ptr,str2_ptr)

char	*str1_ptr,*str2_ptr;

{ int	st1len,st2len,i;

  st1len = strlen(str1_ptr);		/* get the string lengths */
  st2len = strlen(str2_ptr);

  str1_ptr = str1_ptr + st1len;

  for (i=0;i<=st2len;i++)
    *str1_ptr++ = *str2_ptr++;
}

/************************************************************************/
/* fi_s_num writes the number specified to the file opened		*/
/************************************************************************/

fi_s_num(in_handle,in_num)

int	in_handle,in_num;

{ int 	i,j,k;
  char out_num[7];

  out_num[0] = '$';
  j=1;
  for (i=12;i>=0;i=i-4)
    { k=((in_num>>i) &0x000f);
      out_num[j] = k>9 ? 'A'+k-10 : '0'+k;
      j=j+1;
    }
  out_num[5] = 0;
  
  Fwrite(in_handle,5L,out_num);
}

/************************************************************************/
/* add the file name to the path name					*/
/************************************************************************/

add_filename(pathname,filename)

char	*pathname,*filename;
{ int i;
  i = strlen(pathname);
  pathname += i;
  while (i-- && ((*(pathname-1) != '\\') && (*(pathname-1) != ':')))
     pathname--;
  *pathname = '\0';		/* strip off file in path name */
  strcat(pathname,filename);    /* add real file name to path */
}

/************************************************************************/
/* strip_ext strips the extension off of the filename			*/
/************************************************************************/
strip_ext(filename)

char	*filename;

{ int i;
  i = strlen(filename);
  filename += i;
  while (i && (*filename-- != '.'));
  *(filename+1) = '\0';
}
    
