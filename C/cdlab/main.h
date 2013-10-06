/*
 * GEMDAO.H - Squelette du programme principal sous GEM
 *
 * Copyright 2004 Francois Galea
 *
 * This file is part of CDLab.
 *
 * CDLab is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CDLab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef __GEMDAO_H__
#define __GEMDAO_H__

/* Définition des nouveaux messages */
#define UE_CLICKED   0x4600
/* #define UE_ACCMAN    0x4601 */
#define UE_TOOLBAR   0x4602

/* Nombre maxi de devices à gérer */
#define MAX_DEVICES 16

/* Nombre maxi de vitesses de gravage dans les popups */
#define MAX_SPEEDS 32

/* Attributs par défaut d'un formulaire en fenêtre */
#define DEFAULT_FLAGS (CLOSER|MOVER|NAME|SMALLER)

struct popup_item
{
  char * text;
  void * info;
};

struct popup_str
{
/*  OBJECT * tree; */
  int object;
  struct popup_item * item;
  int item_count;
  int selected;
};

extern int reg_ok;
extern char rsc_name[];

void editable3d( OBJECT *tree );
void reduce_name( char * dest, char * source, int max_len );
void gen_speed_popup( struct popup_str * popup, int max_speed );
int fileselect( char * pathname, char * ext, const char * title );
void form_mgr( WINDOW * win );
void toolbar_mgr( WINDOW * win );
WINDOW * open_dialog( OBJECT *tree, char *name );
void gen_dev_popup_buf( void );
void gen_dev_popup( struct popup_str * popup, unsigned short mask, int file );
int popup_mgr( WINDOW * win, struct popup_str * popup, int obj );
void wind_center( WINDOW * win, int w, int h );
void objc_redraw( OBJECT * tree, int obj );
void objc_enable( OBJECT * tree, int obj, int enable );
void objc_lock( OBJECT * tree, int obj, int lock );
void objc_select( OBJECT * tree, int obj, int select );

#endif

