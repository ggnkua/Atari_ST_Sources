/*****************************************************************************
 *
 * Module : REDEFS.H
 * Author : Dieter Geiﬂ
 *
 * Creation date    : 01.07.89
 * Last modification: 14.11.92
 *
 *
 * Description: This module redefines the data and tree routines.
 *
 * History:
 * 14.11.92: Functions of db_root added
 * 26.10.92: Module header added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef _REDEFS_H
#define _REDEFS_H

/****** DBROOT ***************************************************************/

#define get_dberror   _ROOT01
#define set_dberror   _ROOT02
#define build_pass    _ROOT03
#define expand_file   _ROOT04

/****** DBDATA ***************************************************************/

#define init_data     _DATA01
#define create_data   _DATA02
#define open_data     _DATA03
#define close_data    _DATA04
#define flush_data    _DATA05

#define insert_data   _DATA06
#define delete_data   _DATA07
#define undelete_data _DATA08
#define update_data   _DATA09
#define read_data     _DATA10

#define test_multi    _DATA11
#define read_dpg0     _DATA12
#define db_lock       _DATA13
#define db_unlock     _DATA14
#define read_dfn      _DATA15
#define write_dfn     _DATA16

#define expand_data   _DATA17
#define inc_released  _DATA18

/****** DBTREE ***************************************************************/

#define create_tree   _TREE01
#define open_tree     _TREE02
#define close_tree    _TREE03

#define insert_key    _TREE04
#define delete_key    _TREE05
#define search_key    _TREE06
#define update_key    _TREE07

#define new_cursor    _TREE08
#define free_cursor   _TREE09
#define init_cursor   _TREE10
#define move_cursor   _TREE11
#define read_cursor   _TREE12
#define test_cursor   _TREE13
#define locate_addr   _TREE14
#define is_firstlast  _TREE15

#define kill_virtual  _TREE16
#define flush_virtual _TREE17

#define kill_tree     _TREE18
#define expand_tree   _TREE19

#endif /* _REDEFS_H */
