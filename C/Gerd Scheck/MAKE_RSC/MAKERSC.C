                         /***************************
                          * Makersc V 1.0           *
                          * (C) by Gerd Scheck      *
                          * Karlsruhe, den 18.04.89 *
                          ***************************/

  /* Das Programm wandelt eine Resource '.C' Datei wieder in eine '.RSC'
     Datei um                                                            */ 

#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <stdio.h>
#define BYTE char
#define WORD int
#define LONG long

#include "test.c"    /* hier Namen der umzuwandelden '.C' Datei eintragen */
#define RSC_DATNAME "new.rsc" /* hier Namen der zu erzeugenden '.RSC' Datei
                                 eintragen                                */
                     
RSHDR rscheader={1,0,0,0,0,0,0,0,0,0,NUM_OBS,NUM_TREE,NUM_TI,NUM_IB,
                 NUM_BB,NUM_FRSTR,NUM_FRIMG,0};
                                        
char *strptr; /* Zeiger auf den neuen Stringblock */

str_size()        /* Gr”že des Stringblocks ermitteln */
{ int i,size=0;
  for(i=0;i<=NUM_STRINGS-1;i++)
    size +=strlen(rs_strings[i])+1;
  return(size);
}

image_size()     /* Gr”že der Imageblocks ermitteln */
{ int i,j,size=0;
  for(i=0;i<=NUM_BB-1;i++)
    { j=(int)rs_bitblk[i].bi_pdata;
      if(rs_imdope[j].dummy==0)
        { rs_imdope[j].dummy=rs_bitblk[i].bi_wb*rs_bitblk[i].bi_hl;
          size +=rs_imdope[j].dummy;
        }
    }
  for(i=0;i<=NUM_IB-1;i++)
    { j=(int)rs_iconblk[i].ib_pmask;
      if(rs_imdope[j].dummy==0)
        { rs_imdope[j].dummy=(rs_iconblk[i].ib_wicon/8)*
                             rs_iconblk[i].ib_hicon;
          size +=rs_imdope[j].dummy;
        }
      j=(int)rs_iconblk[i].ib_pdata;
      if(rs_imdope[j].dummy==0)
        { rs_imdope[j].dummy=(rs_iconblk[i].ib_wicon/8)*
                             rs_iconblk[i].ib_hicon;
          size +=rs_imdope[j].dummy;
        }
    }
  return(size);
}

str_copy(strsize) /* Strings in einen Block kopieren */
int *strsize;
{ int i;
  char *p;
  (*strsize)++;
  strptr=malloc((unsigned)*strsize);
  strptr=(char *)((long)strptr+((long)strptr%2));
  p=strptr;
  for(i=0;i<=NUM_STRINGS-1;i++)
    { strcpy(p,rs_strings[i]);
      p +=strlen(rs_strings[i])+1;
    }
}

make_frstr() /* rel. Adressen der freien Strings errechnen */
{ int i;
  char *rel_stradr();
  for(i=0;i<=NUM_FRSTR-1;i++)
    rs_frstr[i]=(long)rel_stradr((int)rs_frstr[i]);
}

/* rel. Adressen der Images in den Bitblocks errechnen */
make_bitblk(strsize)
int strsize;
{ int i,*rel_imgadr();
  for(i=0;i<=NUM_BB-1;i++)
    rs_bitblk[i].bi_pdata=rel_imgadr((int)rs_bitblk[i].bi_pdata,strsize);  
}

/* berechnet rel. Adresse der einzelnen Imagebl”cke */
int *rel_imgadr(imgindex,strsize) 
int imgindex,strsize;
{ int reladr=sizeof(RSHDR)+strsize,i;
  for(i=0;i<imgindex;i++)
    reladr +=rs_imdope[i].dummy;
  return((int *)reladr);
}

/* rel. Adressen der freien Images errechnen */
make_frimg(strsize,imgsize,frstrsize)
int strsize,imgsize,frstrsize;
{ int i;
  for(i=0;i<=NUM_FRIMG-1;i++)
    rs_frimg[i]=(long)(sizeof(RSHDR)+strsize+imgsize+frstrsize+
                       (int)rs_frimg[i]*sizeof(BITBLK));
}

make_tedinfo()  /* rel. Adrressen der Strings in Tedinfo errechnen */
{ int i;
  char *rel_stradr();
  for(i=0;i<=NUM_TI-1;i++)
    { rs_tedinfo[i].te_ptext=rel_stradr((int)rs_tedinfo[i].te_ptext);
      rs_tedinfo[i].te_ptmplt=rel_stradr((int)rs_tedinfo[i].te_ptmplt);
      rs_tedinfo[i].te_pvalid=rel_stradr((int)rs_tedinfo[i].te_pvalid);
    }
}

char *rel_stradr(strindex) /* berechnet rel. Adresse eines Strings */
int strindex;              
{ int reladr=sizeof(RSHDR),i;
  for(i=0;i<strindex;i++)
    reladr +=strlen(rs_strings[i])+1;
  return((char *)reladr);
}

/* rel. Aressen der Icon-Masken und -Daten, und der Strings in 
   den Iconblocks errechnen                                    */
make_iconblk(strsize)
int strsize;
{ int i,*rel_imgadr();
  char *rel_stradr();
  for(i=0;i<=NUM_IB-1;i++)
    { rs_iconblk[i].ib_pmask=rel_imgadr((int)rs_iconblk[i].ib_pmask,strsize);
      rs_iconblk[i].ib_pdata=rel_imgadr((int)rs_iconblk[i].ib_pdata,strsize); 
      rs_iconblk[i].ib_ptext=rel_stradr((int)rs_iconblk[i].ib_ptext);
    }
}

/* rel. Adressen von ob_spec der Objekte errechnen */
make_obj(strsize,imgsize,frstrsize,bitsize,frimgsize,tedsize) 
int strsize,imgsize,frstrsize,bitsize,frimgsize,tedsize;
{ int i;
  char *rel_stradr();
  for(i=0;i<=NUM_OBS-1;i++)
    { switch(rs_object[i].ob_type)
        { case G_TEXT:    /* ob_spec zeigt auf Tedinfos */
          case G_BOXTEXT:
          case G_FTEXT:
          case G_FBOXTEXT:rs_object[i].ob_spec=(char *)(sizeof(RSHDR)+
                          strsize+imgsize+frstrsize+bitsize+frimgsize+
                          (int)rs_object[i].ob_spec*sizeof(TEDINFO));
                          break;
          case G_BUTTON:  /* ob_spec zeigt auf Strings */
          case G_STRING:
          case G_TITLE: rs_object[i].ob_spec=
                        rel_stradr((int)rs_object[i].ob_spec);
                        break;
                          /* ob_spec zeigt auf Bitblocks */
          case G_IMAGE: rs_object[i].ob_spec=(char *)(sizeof(RSHDR)+
                        strsize+imgsize+frstrsize+
                        (int)rs_object[i].ob_spec*sizeof(BITBLK));
                        break;
                          /* ob_spec zeigt auf Iconblocks */
          case G_ICON:rs_object[i].ob_spec=(char *)(sizeof(RSHDR)+
                      strsize+imgsize+frstrsize+bitsize+frimgsize+tedsize+
                      (int)rs_object[i].ob_spec*sizeof(ICONBLK));
                      break;
        }  
    }
}

/* rel. Adressen der B„ume errechnen */
make_tree(strsize,imgsize,frstrsize,bitsize,frimgsize,tedsize,iconsize)
int strsize,imgsize,frstrsize,bitsize,frimgsize,tedsize,iconsize;
{ int i;
  for(i=0;i<=NUM_TREE-1;i++)
    rs_trindex[i]=(long)(sizeof(RSHDR)+strsize+imgsize+frstrsize+bitsize+
                         frimgsize+tedsize+iconsize+
                         (int)rs_trindex[i]*sizeof(OBJECT));
}

/* speichern der einzelnen Bl”cke */  
make_rsc(strsize,frstrsize,bitsize,frimgsize,tedsize,iconsize,objsize,
         treesize)
int strsize,frstrsize,bitsize,frimgsize,tedsize,iconsize,objsize,treesize;
{ int handle,i;
  handle=Fcreate(RSC_DATNAME,0);
  Fwrite(handle,(long)sizeof(RSHDR),&rscheader);
  Fwrite(handle,(long)strsize,strptr);
  for(i=0;i<=NUM_IMAGES-1;i++)
    Fwrite(handle,(long)rs_imdope[i].dummy,(char *)rs_imdope[i].image);
  Fwrite(handle,(long)frstrsize,(char *)rs_frstr);
  Fwrite(handle,(long)bitsize,(char *)rs_bitblk);
  Fwrite(handle,(long)frimgsize,(char *)rs_frimg);
  Fwrite(handle,(long)tedsize,(char *)rs_tedinfo);
  Fwrite(handle,(long)iconsize,(char *)rs_iconblk);
  Fwrite(handle,(long)objsize,(char *)rs_object);
  Fwrite(handle,(long)treesize,(char *)rs_trindex);
  Fclose(handle);
}

main()
{ int radr=0,strsize,imgsize,frstrsize,bitsize,frimgsize,tedsize,iconsize,
      objsize,treesize;
  strsize=str_size();  /* Gr”že des Stringblocks ermitteln */
  imgsize=image_size(); /* Gr”že der Imageblocks ermitteln */
  frstrsize=NUM_FRSTR*sizeof(long);
  bitsize=NUM_BB*sizeof(BITBLK);
  frimgsize=NUM_FRIMG*sizeof(long);
  tedsize=NUM_TI*sizeof(TEDINFO);
  iconsize=NUM_IB*sizeof(ICONBLK);
  objsize=NUM_OBS*sizeof(OBJECT);
  treesize=NUM_TREE*sizeof(long);
  str_copy(&strsize);  /* Strings in einen Block kopieren  */
  if(NUM_FRSTR!=0) make_frstr();
  if(NUM_BB!=0) make_bitblk(strsize);
  if(NUM_FRIMG!=0) make_frimg(strsize,imgsize,frstrsize);
  if(NUM_TI!=0) make_tedinfo();
  if(NUM_IB!=0) make_iconblk(strsize);
  if(NUM_OBS!=0) make_obj(strsize,imgsize,frstrsize,bitsize,frimgsize,
                          tedsize);
  make_tree(strsize,imgsize,frstrsize,bitsize,frimgsize,tedsize,iconsize);
    /* die rel. Adressen der Bl”cke werden berechnet und in 
       den RSC-HEADER eingetragen                           */
  radr +=sizeof(RSHDR);rscheader.rsh_string=radr;
  radr +=strsize;rscheader.rsh_imdata=radr;
  radr +=imgsize;rscheader.rsh_frstr=radr;
  radr +=frstrsize;rscheader.rsh_bitblk=radr;
  radr +=bitsize;rscheader.rsh_frimg=radr;
  radr +=frimgsize;rscheader.rsh_tedinfo=radr;
  radr +=tedsize;rscheader.rsh_iconblk=radr;
  radr +=iconsize;rscheader.rsh_object=radr;
  radr +=objsize;rscheader.rsh_trindex=radr;
    /* gr”že der RSC-Datei berechnen und in den RSC-HEADER eintragen */
  radr +=treesize;rscheader.rsh_rssize=radr;
    /* RSC-Datei wird generiert */
  make_rsc(strsize,frstrsize,bitsize,frimgsize,tedsize,iconsize,
           objsize,treesize);
  free(strptr);
}
 
      
                            
           
         

