/* Prototypen */

int  Dsetpath(const char *path);
int  Dgetpath(char *path,int driveno);
int  Dsetdrv(int drv);
int  Dgetdrv(void);
void    v_opnwk( int *work_in,  int *handle, int *work_out);
void    v_clswk( int handle );
void    v_updwk( int handle );
void    v_pline( int handle, int count, int *pxyarray );
void    v_gtext( int handle, int x, int y, char *string );
void    v_meta_extents( int handle, int min_x, int min_y,
                        int max_x, int max_y );
void    vm_filename( int handle, const char *filename );
void    vm_coords( int handle, int llx, int lly, int urx, int ury );
void    vm_pagesize( int handle, int pgwidth, int pdheight );


/* Interface-Routinen */

void pascal m_opnwk(int *handle)
{
     int  i,
          work_in[11],
          work_out[57];

     work_in[0]=*handle;
     for(i=1;i<10;work_in[i++]=1);
     work_in[10]=2;
     v_opnwk(work_in,handle,work_out);
}

void pascal m_clswk(int handle)
{
     v_clswk(handle);
}

void pascal m_updwk(int handle)
{
     v_updwk(handle);
}

void pascal m_meta_extents(int handle, int min_x, int min_y, int max_x, int max_y)
{
     v_meta_extents(handle,min_x,min_y,max_x,max_y);
}

void pascal m_gtext(int handle, int x, int y, char *s)
{
     v_gtext(handle,x,y,s);
}

void pascal m_line(int handle, int x1, int y1, int x2, int y2)
{
     int  pxyarray[4];

     pxyarray[0]=x1;
     pxyarray[1]=y1;
     pxyarray[2]=x2;
     pxyarray[3]=y2;
     v_pline(handle,2,pxyarray);
}

void pascal m_filename(int handle, char *cs)
{
     vm_filename(handle,cs);
}

void pascal m_pagesize(int handle, int width, int height)
{
     vm_pagesize(handle,width,height);
}

void pascal m_coords(int handle, int llx, int lly, int urx, int ury)
{
     vm_coords(handle,llx,lly,urx,ury);
}

void str_del(char *s)
{
     *s='\0';
}

int cstr_length(char *s)
{
     int  i;

     i=0;
     while((*s++!='\0') && (i<256)) i++;
     if(i==256) str_del(s);
     return(i);
}

void cstr_copy(char *src,char *dest)
{
     if(cstr_length(src))
       while((*dest++=*src++)!='\0');
     else
       str_del(dest);
}

void cstr_delete(char s[],int pos,int anz)
{
     int  i;

     if(cstr_length(s))
     {    if(pos+anz-1>cstr_length(s)) return;
          for(i=pos-1;i<=cstr_length(s)-anz;s[i]=s[i+anz],i++);
     }
}

int cstr_equ(char s[],char t[])
{
     int  i;

     if(cstr_length(s)+cstr_length(t))
     {    i=0;
          while(s[i]==t[i])
            if(s[i++]=='\0') return(1);
          return(0);
     }
     else
       return(1);
}

int search_string(char s[],char t[])
{
     char puffer[80],*ptr;
     int  i;

     i=0;
     while(i<cstr_length(s))
     {    cstr_copy(s,puffer);
          puffer[i+cstr_length(t)]='\0';
          ptr=puffer;
          ptr+=(long)i;
          if(cstr_equ(ptr,t)) return(i);
          i++;
     }
     return(-1);
}

void pascal beauty_path(char newone[])
{
     int  i;

     if(!cstr_length(newone))
       cstr_copy("\\",newone);
     else
     {    do
          {    i=search_string(newone,"\\\\");
               if(i>=0) cstr_delete(newone,i+1,1);
          }
          while(i>=0);
     }
}

void pascal make_cstring(char ps[],char cs[])
{
     int  i;

     cs[ps[0]]='\0';
     for(i=0;i<ps[0];i++) cs[i]=ps[i+1];
}

void pascal make_pstring(char *cs,char ps[])
{
     int  i=1;

     while(*cs) ps[i++]=*cs++;
     ps[0]=i-1;
}


