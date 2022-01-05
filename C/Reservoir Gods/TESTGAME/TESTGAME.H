typedef struct
{
U16 id;
U16 x;
U16 y;
U16 data[];
} GODPAINT_STRUCT;

typedef struct
{
S16 x;
S16 y;
GODPAINT_STRUCT * gfx;
} SPRITE_STRUCT;

typedef struct
{
S16 x;
S16 y;
S16 width;
S16 height;
U16 xclip;
U16 yclip;
GODPAINT_STRUCT * gfx;
} SPRITERECT_STRUCT;

typedef struct
{
U16 sprites;
SPRITERECT_STRUCT rect[256];
} PHYSLOG_STRUCT;

PHYSLOG_STRUCT physlog1;
PHYSLOG_STRUCT physlog2;
PHYSLOG_STRUCT * pl_physic_ptr=&physlog1;
PHYSLOG_STRUCT * pl_logic_ptr=&physlog2;

SPRITE_STRUCT my_sprites[256];

GODPAINT_STRUCT * backscreen;
GODPAINT_STRUCT * sprite1;

U32 my_logic;
U32 my_physic;
U32 my_screen_space;

S16 ScreenX=320;
S16 ScreenY=240;
