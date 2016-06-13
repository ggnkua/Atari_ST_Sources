/* DISK.H */

typedef struct
{
 U8 dta_reserved[21];
 U8 dta_attribute;
 U16 dta_time;
 U16 dta_date;
 U32 dta_length;
 U8 dta_filename[14];
} DTA_STRUCT;

typedef struct
{
U32 fat_offset;
U8 fat_filename[12];
} FAT_ENTRY_STRUCT;

typedef struct
{
FAT_ENTRY_STRUCT fat_entry[256];
} FAT_TABLE_STRUCT;

typedef struct
{
U8 link_filename[128];
U16 link_files;
FAT_TABLE_STRUCT * link_fat_ptr;
} LINKFILE_TABLE_STRUCT;

extern void load_file_at(char *, U32 *);
extern void * load_allocate_file(char *);
extern S32 disk_file_length(U8 *);
extern void disk_save_file(void * s_ptr, U32 f_length, U8 * filename);
extern void linkfile_init(U8 *, LINKFILE_TABLE_STRUCT *);
extern void linkfile_load_fat(LINKFILE_TABLE_STRUCT *);
extern S16 linkfile_find_entry(U8 *, LINKFILE_TABLE_STRUCT *);
extern void * linkfile_load_allocate_file(U8 *, LINKFILE_TABLE_STRUCT *);
void linkfile_load_file_at(U8 *, void *, LINKFILE_TABLE_STRUCT *);
extern U32 linkfile_return_filelength(U8 *, LINKFILE_TABLE_STRUCT *);
extern U32 linkfile_return_packed_filelength(U8 * filename, LINKFILE_TABLE_STRUCT * l_ptr);
extern U32 linkfile_return_program_size(U8 * filename,  LINKFILE_TABLE_STRUCT * l_ptr);

/* DISK.H */

typedef struct
{

U32	rlkb_old_118;
U32	rlkb_key_ptr;
U8 * rlkb_caps_table;
U8 * rlkb_shift_table;
U8 * rlkb_normal_table;
S16 rlkb_mousex_min;
S16 rlkb_mousey_min;
S16 rlkb_mousex_max;
S16 rlkb_mousey_max;
U16 rlkb_ppa_key;
U16 rlkb_ppb_key;
U16 rlkb_mousex;
U16 rlkb_mousey;
U8 rlkb_key_table[128];
U8 rlkb_key_buffer[256];
U8 rlkb_ppa_dir;
U8 rlkb_ppb_dir;
U8 rlkb_key_cntr;
U8 rlkb_key_pressed;
U8 rlkb_current_key;
U8 rlkb_mousek;
U8 rlkb_j1_packet;
U8 rlkb_j2_packet;
U8 rlkb_mouse_moved;

} KEYBOARD_STRUCT;

KEYBOARD_STRUCT * my_ikbd;

typedef struct
{
	U8 * unshift_table_ptr;
	U8 * shift_table_ptr;
	U8 * caps_table_ptr;
} KEYTBL_STRUCT;

KEYTBL_STRUCT * xbios_keytable;

extern void rlkb_open_keyboard();
extern void rlkb_close_keyboard();
extern void rlkb_wait_key(U8);
extern void rlkb_wait_key_off(U8);
extern U8 rlkb_last_keypress();
extern void rlkb_clear_last_keypress();
extern U8 rlkb_test_key(U8);
extern U8 rlkb_get_key();
extern U8 rlkb_return_ascii();
extern void rlkb_set_mouse_clip();
extern U16 rlkb_get_mouse_x();
extern U16 rlkb_get_mouse_y();
extern U8 rlkb_get_mouse_key();
extern U8 rlkb_check_mouse_moved();
extern void rlkb_clear_mouse_moved();
extern void rlkb_set_mouse_position(S16, S16);
extern U16 rlkb_return_powerpad_key_a();
extern U16 rlkb_return_powerpad_key_b();
extern U8 rlkb_return_powerpad_dir_a();
extern U8 rlkb_return_powerpad_dir_b();

extern	void	rlkb_install_118();
extern	void	rlkb_deinstall_118();
extern	void	rlkb_read_powerpads();
extern	KEYBOARD_STRUCT * rlkb_return_keyboard_block_ptr();

/* SPRITE.H */

typedef struct
{
U16 fs_colours[26];
U16 * fs_sprite_lines[256];
} FAST_SPRITE_STRUCT;

typedef struct
{
U16 fs_num_sprites;
U16 fs_sprite_x;
U16 fs_sprite_y;
FAST_SPRITE_STRUCT * fs_sprite_ptrs[256];
} FAST_SPRITE_BLOCK_STRUCT;

extern void rlsp_sprites_relocate(FAST_SPRITE_BLOCK_STRUCT *);
extern void rlsp_draw_fast_sprite(S16, S16, U16, FAST_SPRITE_BLOCK_STRUCT *, U32);

extern void rlsp_display_fast_sprite(S16, S16, U32, U16, U16, FAST_SPRITE_BLOCK_STRUCT *);

/* SCREEN.H */
typedef struct
{

U32 videl_screen_address;
U16 videl_horizontal_scroll;
U16 videl_hht;
U16 videl_hbb;
U16 videl_hbe;
U16 videl_hdb;
U16 videl_hde;
U16 videl_hss;
U16 videl_hfs;
U16 videl_hee;
U16 videl_vft;
U16 videl_vbb;
U16 videl_vbe;
U16 videl_vdb;
U16 videl_vde;
U16 videl_vss;
U16 videl_vsm;
U16 videl_vcl;	
U16 videl_spshift;
U8 videl_st_flag;
U8 videl_st_res;
U16 videl_vco;
U16 videl_line_width;
U16 videl_line_off;
 
} VIDEL_STRUCT;

VIDEL_STRUCT videl_current;


U16 videl_changed_flag=0;

extern int rlsc_open_video();
extern int rlsc_close_video();
extern int rlsc_open_screen(U16, U16, U8);
extern void rlsc_get_palette(U8, void *);
extern void rlsc_set_palette(U8, void *);
extern void rlsc_set_palette_entry(U8, U32);
extern void rlsc_set_palette_entry_rgb(U8, U8, U16, U16, U16);
extern void rlsc_get_palette_st(U16 *);
extern void rlsc_get_palette_falcon(U32 *);
extern void rlsc_set_palette_st(U16 *);
extern void rlsc_set_palette_falcon(U32 *);
extern void rlsc_set_st_flag(VIDEL_STRUCT *);
extern void rlsc_set_screen_mode(U16, U16, U8);
extern void rlsc_copy_horizontal_videl(VIDEL_STRUCT *, VIDEL_STRUCT *);
extern void rlsc_copy_vertical_videl(VIDEL_STRUCT *, VIDEL_STRUCT *);
extern void display_videl_registers(VIDEL_STRUCT *);
extern U16 saved_st_palette[16];
extern U32 saved_falcon_palette[256];

extern void rlsc_save_videl(void *);
extern void rlsc_restore_videl(void *);
extern void rlsc_set_videl(VIDEL_STRUCT *);
extern int rlsc_return_monitor_type();
extern void rlsc_set_new_physic(U32);
extern void rlsc_return_videl_block_ptr(VIDEL_STRUCT *);

VIDEL_STRUCT saved_videl_space;
VIDEL_STRUCT videl_screen_modes[20];

/* TRACKER.H */

typedef struct
{
void * trk_amiga_sample_ptr;
U16 trk_amiga_sample_length;
U16 trk_amiga_sample_period;
U16 trk_amiga_sample_volume;
void * trk_amiga_sample_loop_ptr;
U16 trk_amiga_sample_loop_flag;
} TRKAMIGA_STRUCT;

typedef struct
{
U16 trk_tat_stereo;
U16 trk_tat_volume;
U16 trk_tat_panning;
U32 trk_tat_jump;
U32 trk_tat_sent;
U32 trk_tat_freq;
U32 trk_tat_bobbins[5];
} TRKTAT_STRUCT;

typedef struct
{
void * sampleq_start_ptr;
U16 sampleq_word_size;
U16 sampleq_period;
U16 sampleq_volume;
U16 sampleq_stereo;
} SAMPLEQ_STRUCT;

TRKAMIGA_STRUCT * rltrk_amiga_track_ptrs[6];
TRKTAT_STRUCT * rltrk_tat_track_ptrs[6];
SAMPLEQ_STRUCT rltrk_sampleq[16];
U16 rltrk_sampleq_entries;

extern void rltrk_open_tracker();
extern void rltrk_close_tracker();
extern S8 rltrk_get_free_channel();
extern void rltrk_play_samples();
extern void rltrk_play_a_sample();
extern void rltrk_init_new_sample(void *, U16, U16, U16);
extern void rltrk_clear_free_channels();

extern void rltrk_begin_tracker();
extern void rltrk_open_module(void *);
extern void rltrk_set_master_volume(U16);
extern void rltrk_set_sample_volume(U16);
extern void rltrk_set_track_ptrs(void *, void *);
extern void rltrk_start_sample(U8);
extern void rltrk_end_sample(U8);
extern U16 rltrk_read_master_volume();
extern U16 rltrk_read_sample_volume();
extern void rltrk_close_module();
extern void rltrk_end_tracker();

/* VECTOR.H */

typedef struct 
{
U32 vector_old_cacr;
U32 vector_old_vbl;
U32 vector_old_msp;
U32 vector_old_usp;
U32 vector_old_vectors[254];
U32 vector_old_mfp[12];
} VECTOR_STRUCT;

extern void rlvc_open_system();
extern void rlvc_close_system();

extern	rlvc_save_vectors(VECTOR_STRUCT *);
extern	rlvc_restore_vectors(VECTOR_STRUCT *);
extern	rlvc_install_vbl();
extern	rlvc_wait_vbl();
extern	rlvc_install_vbl_routine(void *);
extern	rlvc_remove_vbl_routine(void *);
extern	rlsc_set_screen_vbl();


VECTOR_STRUCT vector_save_space;
