/********************************************************************/
/*                          Submenu V1.15                           */
/*              - Einsatz von Submenus unter GEM -                  */
/* - lauff„hig unter allen TOS-Versionen und in allen Aufl”sungen - */
/*                     von Uwe Hax in Megamax C                     */
/*								Pure C-Konvertierung: Thomas Werner								*/
/*                   (c) 1992 MAXON Computer GmbH   								*/
/********************************************************************/

#include	<stddef.h>
#include	<tos.h>
#include	<aes.h>
#include	<vdi.h>

typedef enum
{
    FALSE,
    TRUE
}
boolean;


int	 subnum;                      /* Rckgabewert: Index des Submenu-Eintrags */

/* Alle folgenden globalen Variablen werden nur in den folgenden Routinen
   benutzt und drfen auf keinen Fall von anderen Routinen ver„ndert werden!  */

struct ext_appl_blk {                       /* erweiterten APPLBLK definieren */
                       int  (*ub_code)();   /* Zeiger auf Zeichen-Routine     */
                       long ub_parm;        /* Index der Submenu-Box          */
                       char *text;          /* Men-Text                      */
                    } *block;

void *menu_buffer;                        /* Hintergrundspeicher fr Submenus */
int  copy_array[8];                       /* Hintergrund-Koordinaten          */
int  fill_array[8];                       /* Box-Koordinaten                  */
OBJECT *sub_menu;                         /* Adresse der Submenus             */
MFDB memory;                              /* zum Kopieren                     */
MFDB screen;                              /* zum Kopieren                     */
int  device;                              /* VDI-Handle                       */
int  pxyarray[4];                         /* zum Zeichnen                     */
int  mbutton,mx,my;                       /* Maus                             */
long sm_index;                            /* Submenu-Index                    */


void init_submenus(int handle, OBJECT *menu, OBJECT *submenu,
									 int count,int *menu_index)
/* handle:          VDI-Handle   														*/
/* *menu, *submenu: Adressen der beiden Men-Zeilen 				*/
/* count:           Anzahl der Elemente in der Liste        */
/* *menu_index:     Liste mit Indices aller Men-Eintr„ge,
                    die Titel fr Submenus sein sollen      */
{
  int  i;
  int  cdecl draw_submenu(PARMBLK *parmblock);
  int  box2;
  int  *size;
  int  max_size=0;
  int  submenu_index;
  int  menubar;

  /* H”he der Men-Leiste ist abh„ngig von der Aufl”sung */
  menubar=(Getrez()==2) ? 19 : 11; 
    
  /* Speicher reservieren fr alle APPLBLK's */
  size=(int  *)Malloc((long)count*2L);
  block=(struct ext_appl_blk *)
                    Malloc((long)(sizeof(struct ext_appl_blk)*count));

  /* Index der G_BOX fr das erste Submenu holen */
  submenu_index=submenu[submenu[submenu[0].ob_tail].ob_head].ob_next;

  for (i=0; i<count; i++)
  {
    /* Text retten */
    block[i].text=menu[menu_index[i]].ob_spec.free_string;

    /* eigene Zeichen-Routine installieren */
    menu[menu_index[i]].ob_type=G_USERDEF;

    /* Zeiger auf zugeh”rigen APPLBLK setzen */
    menu[menu_index[i]].ob_spec.userblk=(void *)&block[i];

    /* Adresse der neuen Zeichenroutine eintragen */
    block[i].ub_code=(void *)draw_submenu;

    /* Parameter-šbergabe: Index der G_BOX des zugeh”rigen Submenus */
    block[i].ub_parm=(long)submenu_index;

    /* Index der bergeordneten G_BOX fr das Men suchen */
    box2=menu_index[i];
    while (menu[box2].ob_type!=G_BOX)
      box2=menu[box2].ob_next;

    /* Koordinaten des Submenus errechnen */
    submenu[submenu_index].ob_x=menu[box2].ob_x+menu[menu_index[i]].ob_width+1;
    submenu[submenu_index].ob_y=menubar+menu[menu_index[i]].ob_y;

    /* Gr”e des ben”tigten Hintergrundspeichers merken */
    size[i]=(submenu[submenu_index].ob_width+16)/8*
                                submenu[submenu_index].ob_height;
    /* n„chstes Submenu */
    submenu_index=submenu[submenu_index].ob_next;
  }

  /* Speicher fr das gr”te Men belegen */
  for (i=0; i<count; i++)
    if (max_size<size[i])
      max_size=size[i];
  menu_buffer=(int  *)Malloc((long)max_size);

  /* globale Variablen setzen */
  sub_menu=submenu;
  device=handle;
}


int cdecl draw_submenu(PARMBLK *parmblock)
{
  int  index;
  char *sm_text;
  struct ext_appl_blk *appl_pointer;
  int  tx,ty;
  int  attrib[5];
  int  state;
  int  resolution;
  int  correct;

	void do_submenu(void);
	void redraw_bg(void);
	void switch_entry(boolean disabled);
	

  /* Zeiger auf den angesprochenen APPLBLK */
  appl_pointer=(struct ext_appl_blk *)
                 parmblock->pb_tree[parmblock->pb_obj].ob_spec.userblk;
  /* Text des Men-Eintrags */
  sm_text=appl_pointer->text;

  /* aktuelle Fllattribute merken */
  vqf_attributes(device,attrib);

  /* Index der Submenu-Box */
  sm_index=parmblock->pb_parm;

  /* kein Submenu angew„hlt */
  subnum=0;

  /* Korrekturfaktor fr die Ausgabe von Texten (abh„ngig von der Aufl”sung) */
  resolution=Getrez();
  correct=(resolution==2) ? 3 : 2;

  /* Auf keinen Fall Clipping durchfhren; Clip-Koordinaten sind 0!!! */

  /* ist der Eintrag NORMAL? */
  if (!parmblock->pb_currstate)    /* ja */
  {
    /* war der Eintrag vorher SELECTED? */
    if (parmblock->pb_prevstate)       /* ja */
    {
      /* Maus im Submenu? */
      vq_mouse(device,&mbutton,&mx,&my);

      /* wenn ja, Submenu-Kontrolle */
      if ((mx>=sub_menu[sm_index].ob_x-1) &&
          (mx<=sub_menu[sm_index].ob_x+sub_menu[sm_index].ob_width) &&
          (my>=sub_menu[sm_index].ob_y) &&
          (my<=sub_menu[sm_index].ob_y+sub_menu[sm_index].ob_height+1))
        do_submenu();

      /* Hintergrund restaurieren */
      redraw_bg();

      /* Men-Eintrag neu zeichnen */
      pxyarray[0]=parmblock->pb_x;
      pxyarray[1]=parmblock->pb_y;
      pxyarray[2]=parmblock->pb_x+parmblock->pb_w-1;
      pxyarray[3]=parmblock->pb_y+parmblock->pb_h-1;
      switch_entry(FALSE);
    }
    else
    {
      /* Text ausgeben */
      v_gtext(device,parmblock->pb_x,parmblock->pb_y+parmblock->pb_h-correct,
                sm_text);
    }
    state=NORMAL;
  }
  else      /* SELECTED */
  {
    /* Men-Eintrag selektieren */
    pxyarray[0]=parmblock->pb_x;
    pxyarray[1]=parmblock->pb_y;
    pxyarray[2]=parmblock->pb_x+parmblock->pb_w-1;
    pxyarray[3]=parmblock->pb_y+parmblock->pb_h-1;
    switch_entry(FALSE);

    /* Submenu zeichnen */
    /* ================ */
    /* Hintergrund retten */
    screen.fd_addr=NULL;
    memory.fd_addr=(void *)menu_buffer;
    memory.fd_wdwidth=sub_menu[sm_index].ob_width/16+1;
    memory.fd_stand=0;
    memory.fd_nplanes=resolution ? 2/resolution : 4;
    copy_array[0]=sub_menu[sm_index].ob_x;
    copy_array[1]=sub_menu[sm_index].ob_y-1;
    copy_array[2]=sub_menu[sm_index].ob_x+sub_menu[sm_index].ob_width+1;
    copy_array[3]=sub_menu[sm_index].ob_y+sub_menu[sm_index].ob_height;
    copy_array[4]=0;
    copy_array[5]=0;
    copy_array[6]=sub_menu[sm_index].ob_width+1;
    copy_array[7]=sub_menu[sm_index].ob_height+1;
    vro_cpyfm(device,3,copy_array,&screen,&memory);

    /* Box zeichnen */
    fill_array[0]=copy_array[0];
    fill_array[1]=copy_array[1];
    fill_array[2]=copy_array[2];
    fill_array[3]=copy_array[1];
    fill_array[4]=copy_array[2];
    fill_array[5]=copy_array[3];
    fill_array[6]=copy_array[0];
    fill_array[7]=copy_array[3];
    vsf_interior(device,0);
    vswr_mode(device,1);
    v_fillarea(device,4,fill_array);

    /* Texte ausgeben */
    index=sub_menu[sm_index].ob_head;
    while (sub_menu[index].ob_type==G_STRING)
    {
      if (sub_menu[index].ob_state & DISABLED)
        vst_effects(device,2);
      tx=sub_menu[sm_index].ob_x+sub_menu[index].ob_x+1;
      ty=sub_menu[sm_index].ob_y+sub_menu[index].ob_y+
         sub_menu[index].ob_height-correct;
      v_gtext(device,tx,ty,sub_menu[index].ob_spec.free_string);
      if (sub_menu[index].ob_state & CHECKED)
        v_gtext(device,tx+2,ty,"\10");
      vst_effects(device,0);
      index=sub_menu[index].ob_next;
    }
    state=SELECTED;
  }

  /* alte Fllattribute wieder herstellen */
  vsf_interior(device,attrib[0]);
  vsf_color(device,attrib[1]);
  vsf_style(device,attrib[2]);
  vswr_mode(device,attrib[3]);
  vsf_perimeter(device,attrib[4]);

  /* Zustand des angew„hlten Men-Eintrags zurckgeben */
  return(state);
}


void redraw_bg(void)
{
  v_hide_c(device);

  copy_array[0]=0;
  copy_array[1]=0;
  copy_array[2]=sub_menu[sm_index].ob_width+1;
  copy_array[3]=sub_menu[sm_index].ob_height+1;
  copy_array[4]=sub_menu[sm_index].ob_x;
  copy_array[5]=sub_menu[sm_index].ob_y-1;
  copy_array[6]=sub_menu[sm_index].ob_x+sub_menu[sm_index].ob_width+1;
  copy_array[7]=sub_menu[sm_index].ob_y+sub_menu[sm_index].ob_height;

  /* alle anderen Parameter sind bereits gesetzt */
  vro_cpyfm(device,3,copy_array,&memory,&screen);

  v_show_c(device,1);
}


void switch_entry(boolean disabled)
{
  /* je nach bergebenem Parameter Men-Eintrag entweder normal oder
     selektiert zeichnen */
  if (!disabled)
  {
    vsf_interior(device,1);
    vswr_mode(device,3);
    vr_recfl(device,pxyarray);
  }
}

void do_submenu(void)
{
  int  index;
  int  prev_obj=0;

  /* Cursor einschalten */
  v_show_c(device,1);

  /* Mauszeiger innerhalb des Submenus? */
  while ((mx>=sub_menu[sm_index].ob_x-1) &&
         (mx<=sub_menu[sm_index].ob_x+sub_menu[sm_index].ob_width) &&
         (my>=sub_menu[sm_index].ob_y) &&
         (my<=sub_menu[sm_index].ob_y+sub_menu[sm_index].ob_height+1))
  {
    /* Eintrag unter Mauszeiger suchen */
    index=sub_menu[sm_index].ob_head;
    while (sub_menu[index].ob_type==G_STRING)
      if ((my>sub_menu[sm_index].ob_y+sub_menu[index].ob_y) &&
          (my<sub_menu[sm_index].ob_y+sub_menu[index].ob_y+
              sub_menu[index].ob_height))
        break;
      else
        index=sub_menu[index].ob_next;

    /* gefunden? */
    if (index!=sm_index)  /* ja */
    {
      /* Eintrag ungleich letztem angew„hlten Eintrag? */
      if (index!=prev_obj)     /* ja */
      {
        /* zum Zeichnen Mauszeiger ausschalten */
        v_hide_c(device);

        /* vorigen Eintrag normalisieren */
        if (prev_obj && !(sub_menu[prev_obj].ob_state & DISABLED))
          switch_entry(FALSE);
        /* neuen Eintrag selektieren, falls m”glich */
        pxyarray[0]=sub_menu[sm_index].ob_x+1;
        pxyarray[1]=sub_menu[sm_index].ob_y+sub_menu[index].ob_y;
        pxyarray[2]=pxyarray[0]+sub_menu[index].ob_width-1;
        pxyarray[3]=pxyarray[1]+sub_menu[index].ob_height-1;
        switch_entry(sub_menu[index].ob_state & DISABLED);

        v_show_c(device,1);
        prev_obj=index;
      }

      /* Maustaste gedrckt? */
      if (mbutton)   /* ja */
      {
        /* Men-Eintrag anw„hlbar? */
        if (!(sub_menu[index].ob_state & DISABLED))  /* ja */
          subnum=index;         /* Index des Eintrags zurckgeben */
        break;
      }
    }
    /* aktuelle Mauskoordinaten holen */
    vq_mouse(device,&mbutton,&mx,&my);
  }
  /* Mauszeiger wieder ausschalten */
  v_hide_c(device);
}

