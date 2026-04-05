
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <mint/sysbind.h>
#include <ldg.h>

#include "defs.h"

#define TRUE 1
#define FALSE 0
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

/* global variables */

#define FILE_BUFFER_SIZE 384
#define TEXT_BUFFER_SIZE 4096
#define STATUS_BUFFER_SIZE 78
#define ACTION_BUFFER_SIZE 256

static unsigned char* msg_fatal = NULL;
static int32_t is_fatal = 0;

static char load_name[FILE_BUFFER_SIZE];
static char save_name[FILE_BUFFER_SIZE];
static uint16_t file_mode = 0;
#define FILE_MODE_DISABLED 0
#define FILE_MODE_ENABLED  1
#define FILE_FAILED  0
#define FILE_SUCCESS 1

static unsigned char text_buffer_ptr[TEXT_BUFFER_SIZE];
static uint16_t text_buffer_pos = 0;
static uint32_t text_end_type = 0;
#define TEXT_NOT_ENDED         0
#define TEXT_END_TYPE_LINEFEED 1
#define TEXT_END_TYPE_PROMPT   2
#define TEXT_END_TYPE_INPUT    3
#define TEXT_END_TYPE_QUESTION 4

static unsigned char status_buffer_ptr[STATUS_BUFFER_SIZE];
static uint16_t status_buffer_pos = 0;
static uint16_t status_updated = 0;

static unsigned char action_buffer_ptr[ACTION_BUFFER_SIZE];
static uint16_t action_buffer_pos = 0;

#define NO_PICTURE -1;
static int32_t picture_current_id = NO_PICTURE;
static unsigned char* picture_rawdata = NULL;
static uint16_t picture_width = 0;
static uint16_t picture_height = 0;
static uint16_t picture_palette[16];

#define MAX_FRAMES 20
struct picture_frame
{
  uint16_t number;
  uint16_t width;
  uint16_t height;
  unsigned char* rawdata;
  unsigned char* rawmask;
};
static struct picture_frame frames[MAX_FRAMES];
static unsigned char picture_animated = FALSE;
static uint16_t frames_count = 0;
static char *picture_current_an = NULL;

static struct ms_position *anim_positions;

static struct ms_hint *hints_list;

/* implemented functions */

void ms_fatal(char* txt) { is_fatal = 1; msg_fatal = (unsigned char *)txt; }

unsigned char ms_load_file(type8s *name, type8 *ptr, type16 size)
{
	FILE *fh; int32_t r;
	
  if (load_name[0] == 0) { return 1; }
 
  fh = fopen(load_name, "rb");

  if (fh == NULL) { return 1; }

	r = fread(ptr, 1, size, fh);

	fclose(fh);

	return (r == size) ? 0 : 1;
}

unsigned char ms_save_file(type8s *name, type8 *ptr, type16 size)
{
	FILE *fh; int32_t r;

  if (save_name[0] == 0) { return 1; }

  fh = fopen(save_name, "wb");
	
  if (fh == NULL) { return 1; }
	
  r = fwrite(ptr, 1, size, fh);
	
  fclose(fh);
	
  return (r == size) ? 0 : 1;
}

void ms_flush(void)
{
  if (text_buffer_pos == 0) { return; }
  
  text_buffer_pos = 0;
  memset(text_buffer_ptr, 0, TEXT_BUFFER_SIZE);
  
  text_end_type = TEXT_NOT_ENDED;
}
void ms_putchar(uint8_t c)
{
  if (text_buffer_pos < TEXT_BUFFER_SIZE)
  {
    switch(c)
    {
      case 0x00: // string termination
        text_buffer_ptr[text_buffer_pos] = c;
        break;
      case 0x08: // backspace
        if (text_buffer_pos > 0) { text_buffer_pos--; }
        break;
      case 0x0a: // '\n'
        text_buffer_ptr[text_buffer_pos++] = c;
        text_end_type = TEXT_END_TYPE_LINEFEED;
        break;
      case 0x3a: // ':'
        text_buffer_ptr[text_buffer_pos++] = c;
        if (file_mode == FILE_MODE_ENABLED) { text_end_type = TEXT_END_TYPE_INPUT; }
        break;
      case 0x3e: // '>'
        text_buffer_ptr[text_buffer_pos++] = c;
        text_end_type = TEXT_END_TYPE_PROMPT;
        break;
      case 0x3f: // '?'
        text_buffer_ptr[text_buffer_pos++] = c;
        if (text_buffer_ptr[text_buffer_pos - 2] == 0x29 /* ')' before '?' */) { text_end_type = TEXT_END_TYPE_QUESTION; }
        break;
      default:
        text_buffer_ptr[text_buffer_pos++] = c;
    }
  }
}
void ms_statuschar(unsigned char c)
{
  if (c == 0x0a)
  {
    status_updated = 1;
  }
  else if (c == 0x09)
  {
    while (status_buffer_pos < STATUS_BUFFER_SIZE - 11)
    {
      status_buffer_ptr[status_buffer_pos] = 0x20;
      status_buffer_pos++;
    }
  }
  else if (status_buffer_pos < STATUS_BUFFER_SIZE)
  {
    status_buffer_ptr[status_buffer_pos] = c;
    status_buffer_pos++;
  }
}

unsigned char ms_getchar(type8 trans)
{
  unsigned char c;
  
  if (action_buffer_pos < ACTION_BUFFER_SIZE) { c = action_buffer_ptr[action_buffer_pos++]; } else { c = 0x0a; }
    
  if (c == 0x0a || c == 0)
  {
    action_buffer_pos = 0;
    memset(action_buffer_ptr, 0x0a, ACTION_BUFFER_SIZE);
  }

  return c;
}

void ms_showpic(type32 c, type8 mode)
{
  if (mode > 0)
  {
    picture_current_id = NO_PICTURE;
    picture_current_an = NULL;
    picture_animated = FALSE;
    
    picture_rawdata = ms_extract(c, &picture_width, &picture_height, picture_palette, &picture_animated);

    if (picture_rawdata)
    {
      picture_current_id = c;
      picture_current_an = anim_name(c);
    }
    else
    {
      picture_width = 0;
      picture_height = 0;
      picture_animated = FALSE;
    }
  }
  else
  {
    picture_current_id = NO_PICTURE;
    picture_current_an = NULL;
    picture_rawdata = NULL;
    picture_width = 0;
    picture_height = 0;
    picture_animated = FALSE;
  }
}

type8 ms_showhints(struct ms_hint *hints)
{
  hints_list = hints;
  return 1;
}

/* functions */

uint32_t CDECL gms_init(char* mag_buf, uint32_t mag_len, char* gfx_ptr, uint32_t gfx_len, char* hnt_buf, uint32_t hnt_len)
{
  uint16_t i;

  text_buffer_pos = 0;
  memset(text_buffer_ptr, 0, TEXT_BUFFER_SIZE);
  text_end_type = TEXT_NOT_ENDED;

  status_buffer_pos = 0;
  memset(status_buffer_ptr, 0, STATUS_BUFFER_SIZE);
  status_updated = 0;

  action_buffer_pos = 0;
  memset(action_buffer_ptr, 0x0a, ACTION_BUFFER_SIZE);

  picture_current_id = NO_PICTURE;
  picture_rawdata = NULL;
  picture_width = 0;
  picture_height = 0;
  picture_animated = FALSE;

  for (i = 0; i < MAX_FRAMES; i++)
  {
    if (frames[i].rawdata) { ldg_Free(frames[i].rawdata); }
  }

  hints_list = NULL;
  
  memset(load_name, 0, FILE_BUFFER_SIZE);
  memset(save_name, 0, FILE_BUFFER_SIZE);
    
  return (uint32_t)ms_init(mag_buf, mag_len, gfx_ptr, gfx_len, hnt_buf, hnt_len);
}
uint32_t CDECL gms_rungame()
{
  uint32_t count = 4096;
  type8 running = 1;
  text_end_type = TEXT_NOT_ENDED;
  
  while(running && (count > 0) && (text_end_type < TEXT_END_TYPE_PROMPT))
  {
    running = ms_rungame();
    count--;
  }
  
  /*Cconws(text_buffer_ptr);*/
     
  return text_end_type;
}
uint32_t CDECL gms_freemem()
{
  uint16_t i;
  
  for (i = 0; i < MAX_FRAMES; i++)
  {
    if (frames[i].rawdata) { ldg_Free(frames[i].rawdata); }
  }
  
  ms_freemem();
  
  return (uint32_t)1;
}

uint32_t CDECL gms_has_text() { return (uint32_t)(text_buffer_pos > 0 ? 1 : 0); }
unsigned char* CDECL gms_get_text() { return text_buffer_ptr; }
uint32_t CDECL gms_flush_text() { ms_flush(); return (uint32_t)1; }

uint32_t CDECL gms_is_status_updated() { return (uint32_t)status_updated; }
unsigned char* CDECL gms_get_status() { return status_buffer_ptr; }
uint32_t CDECL gms_flush_status()
{
  status_updated = 0;
  status_buffer_pos = 0;
  memset(status_buffer_ptr, 0, STATUS_BUFFER_SIZE);
  
  return (uint32_t)1;
}

uint32_t CDECL gms_seed(uint32_t seed) { ms_seed(seed); return (uint32_t)1; }
uint32_t CDECL gms_send_string(const char* action)
{
  /*Cconws(action);*/

  action_buffer_pos = 0;
  memset(action_buffer_ptr, 0x0a, ACTION_BUFFER_SIZE);
  
  memcpy(action_buffer_ptr, action, MIN(strlen(action), ACTION_BUFFER_SIZE - 1));

  return (uint32_t)1;
}

int32_t CDECL gms_get_picture_current_id() { return (int32_t)picture_current_id; }
char* CDECL gms_get_picture_current_an() { return (char *)picture_current_an; }

uint32_t CDECL gms_get_picture_width() { return (uint32_t)picture_width; }
uint32_t CDECL gms_get_picture_height() { return (uint32_t)picture_height; }
unsigned char* CDECL gms_get_picture_rawdata() {  return picture_rawdata; }
uint16_t* CDECL gms_get_picture_palette() { return picture_palette; }

uint32_t CDECL gms_is_picture_animated() { return (uint32_t)picture_animated; }
uint32_t gms_list_frames(void)
{
  uint16_t count, i;
  unsigned char *data;
  uint32_t size;
  
  if (ms_animate(&anim_positions, &count) == 0) { picture_animated = FALSE; return 0; }

  if (count > MAX_FRAMES) { return 0; }

  // clean
  for (i = 0; i < MAX_FRAMES; i++)
  {
    frames[i].number = 0;
    frames[i].width = 0;
    frames[i].height = 0;
    if (frames[i].rawdata) { ldg_Free(frames[i].rawdata); } frames[i].rawdata = NULL;
    frames[i].rawmask = NULL;
  }
  frames_count = 0;
    
  // list
  for (i = 0; i < count; i++)
  {
    frames[i].number = anim_positions[i].number;
    
    data = ms_get_anim_frame(anim_positions[i].number, &(frames[i].width), &(frames[i].height), &(frames[i].rawmask));
    size = frames[i].width * frames[i].height;
    
    frames[i].rawdata = ldg_Malloc(size);
    
    if (frames[i].rawdata) { memcpy(frames[i].rawdata, data, size); }
  }
  frames_count = count;
  
  return (uint32_t)count;
}
struct ms_position * CDECL gms_get_positions() { return anim_positions; }
uint32_t CDECL gms_get_frame_count() { return (uint32_t)frames_count; }
uint32_t CDECL gms_get_frame_number(uint32_t i) { if (i < frames_count) { return (uint32_t)(frames[i].number); } return (uint32_t)0; }
uint32_t CDECL gms_get_frame_width(uint32_t i) { if (i < frames_count) { return (uint32_t)(frames[i].width); } return (uint32_t)0; }
uint32_t CDECL gms_get_frame_height(uint32_t i) { if (i < frames_count) { return (uint32_t)(frames[i].height); } return (uint32_t)0; }
unsigned char* CDECL gms_get_frame_rawdata(uint32_t i) { if (i < frames_count) { return frames[i].rawdata; } return NULL; }
unsigned char* CDECL gms_get_frame_rawmask(uint32_t i) { if (i < frames_count) { return frames[i].rawmask; } return NULL; }

struct ms_hint* CDECL gms_get_hints_list() { return hints_list; }

uint32_t CDECL gms_is_running() { return (uint32_t)ms_is_running(); }
uint32_t CDECL gms_is_magwin() { return (uint32_t)ms_is_magwin(); }

uint32_t CDECL gms_stop() { ms_stop(); return (uint32_t)1; }
uint32_t CDECL gms_count() { return (uint32_t)ms_count(); }

uint32_t CDECL gms_set_load_name(const char* name)
{
  if (name == NULL) { return (uint32_t)0; }
  if (strlen(name) == 0) { return (uint32_t)0; }
  if (strlen(name) > (FILE_BUFFER_SIZE -1)) { return (uint32_t)0; }

  strcpy(load_name, name);

  return (uint32_t)1;
}
uint32_t CDECL gms_load_game()
{
  uint32_t ret = FILE_FAILED;

  if (action_buffer_pos == 0)
  {
    file_mode = FILE_MODE_ENABLED;
    
    gms_send_string("load\n");  gms_rungame(); gms_flush_text();
    gms_send_string("dummy\n"); gms_rungame(); gms_flush_text();
    gms_send_string("y\n");

    status_buffer_pos = 0;
    memset(status_buffer_ptr, 0, STATUS_BUFFER_SIZE);
    status_updated = 1;

    picture_current_id = NO_PICTURE;
    picture_rawdata = NULL;
    picture_width = 0;
    picture_height = 0;

    file_mode = FILE_MODE_DISABLED;
    ret = FILE_SUCCESS;
  }
  return ret;
}
uint32_t CDECL gms_set_save_name(const char* name)
{
  if (name == NULL) { return (uint32_t)0; }
  if (strlen(name) == 0) { return (uint32_t)0; }
  if (strlen(name) > (FILE_BUFFER_SIZE -1)) { return (uint32_t)0; }
  
  strcpy(save_name, name);

  return (uint32_t)1;
}
uint32_t CDECL gms_save_game()
{
  uint32_t ret = FILE_FAILED;
  
  if (action_buffer_pos == 0)
  {
    file_mode = FILE_MODE_ENABLED;
    
    gms_send_string("save\n");  gms_rungame(); gms_flush_text();
    gms_send_string("dummy\n"); gms_rungame(); gms_flush_text();
    gms_send_string("y\n");

    file_mode = FILE_MODE_DISABLED;
    
    ret = FILE_SUCCESS;
  }
  return ret;
}
uint32_t CDECL gms_enable_graphics()
{
  uint32_t ret = ms_is_magwin();
  
  if (ret == 1)
  {
    gms_send_string("graphics off\n"); gms_rungame(); gms_flush_text();
    gms_send_string("graphics on\n");  gms_rungame(); gms_flush_text();
  }
  return ret;
}
uint32_t CDECL gms_enable_hints()
{
  uint32_t ret = ms_is_magwin();
  
  if (ret == 1)
  {
    gms_send_string("hints\n"); gms_rungame(); gms_flush_text();
  }
  return ret;
}

uint32_t CDECL gms_is_fatal() { return is_fatal; }
unsigned char* CDECL gms_get_fatal() { return msg_fatal; }


/* populate functions list and info for the LDG */

PROC LibFunc[] =
{
  {"gms_init", "uint32_t gms_init(char* mag_buf, uint32_t mag_len, char* gfx_ptr, uint32_t gfx_len, char* hnt_buf, uint32_t hnt_len);\n", gms_init},
  {"gms_rungame", "uint32_t gms_rungame();\n", gms_rungame},
  {"gms_freemem", "uint32_t gms_freemem();\n", gms_freemem},

  {"gms_has_text", "uint32_t gms_has_text();\n", gms_has_text},
  {"gms_get_text", "unsigned char* gms_get_text();\n", gms_get_text},
  {"gms_flush_text", "uint32_t gms_flush_text();\n", gms_flush_text},

  {"gms_is_status_updated", "uint32_t gms_is_status_updated();\n", gms_is_status_updated},
  {"gms_get_status", "unsigned char* gms_get_status();\n", gms_get_status},
  {"gms_flush_status", "uint32_t gms_flush_status();\n", gms_flush_status},

  {"gms_seed", "uint32_t gms_seed(uint32_t seed);\n", gms_seed},
  {"gms_send_string", "uint32_t gms_send_string(const char* action);\n", gms_send_string},

  {"gms_get_picture_current_id", "int32_t gms_get_picture_current_id();\n", gms_get_picture_current_id},
  {"gms_get_picture_current_an", "char* gms_get_picture_current_an();\n", gms_get_picture_current_an},

  {"gms_get_picture_width", "uint32_t gms_get_picture_width();\n", gms_get_picture_width},
  {"gms_get_picture_height", "uint32_t gms_get_picture_height();\n", gms_get_picture_height},
  {"gms_get_picture_rawdata", "unsigned char* gms_get_picture_rawdata();\n", gms_get_picture_rawdata},
  {"gms_get_picture_palette", "uint16_t* gms_get_picture_palette();\n", gms_get_picture_palette},

  {"gms_is_picture_animated", "uint32_t gms_is_picture_animated();\n", gms_is_picture_animated},
  {"gms_list_frames", "uint32_t gms_list_frames();\n", gms_list_frames},
  {"gms_get_positions", "struct ms_position* gms_get_positions();\n", gms_get_positions},
  {"gms_get_frame_count", "uint32_t gms_get_frame_count();\n", gms_get_frame_count},
  {"gms_get_frame_number", "uint32_t gms_get_frame_number(uint32_t i);\n", gms_get_frame_number},
  {"gms_get_frame_width", "int32_t gms_get_frame_width(uint32_t i);\n", gms_get_frame_width},
  {"gms_get_frame_height", "uint32_t gms_get_frame_height(uint32_t i);\n", gms_get_frame_height},
  {"gms_get_frame_rawdata", "unsigned char* gms_get_frame_rawdata(uint32_t i);\n", gms_get_frame_rawdata},
  {"gms_get_frame_rawmask", "unsigned char* gms_get_frame_rawmask(uint32_t i);\n", gms_get_frame_rawmask},

  {"gms_get_hints_list", "struct ms_hint* gms_get_hints_list();\n", gms_get_hints_list},

  {"gms_is_running", "uint32_t gms_is_running();\n", gms_is_running},
  {"gms_is_magwin", "uint32_t gms_is_magwin();\n", gms_is_magwin},

  {"gms_stop", "uint32_t gms_stop();\n", gms_stop},
  {"gms_count", "uint32_t gms_count();\n", gms_count},

  {"gms_set_load_name", "uint32_t gms_set_load_name(const unsigned char* name);\n", gms_set_load_name},
  {"gms_load_game", "uint32_t gms_load_game();\n", gms_load_game},
  {"gms_set_save_name", "uint32_t gms_set_save_name(const unsigned char* name);\n", gms_set_save_name},
  {"gms_save_game", "uint32_t gms_save_game();\n", gms_save_game},

  {"gms_enable_graphics", "uint32_t gms_enable_graphics();\n", gms_enable_graphics},
  {"gms_enable_hints", "uint32_t gms_enable_hints();\n", gms_enable_hints},

  {"gms_is_fatal", "uint32_t gms_is_fatal();\n", gms_is_fatal},
  {"gms_get_fatal", "unsigned char* gms_get_fatal();\n", gms_get_fatal},
};

LDGLIB LibLdg[] = { { 0x0002, 39, LibFunc, "Magnetic Scrolls Interpreter v2.3 (c) Niclas Karlsson, 1997-2008", 1} };

/*  */

int main(void)
{
  ldg_init(LibLdg);
  return 0;
}
