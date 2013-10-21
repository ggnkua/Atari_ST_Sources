/****************************************/
/*     JOY.C VARIABLE DECLARATIONS		*/
/****************************************/
extern short	*joystick;
extern short	*fire_buttons;

extern short	joy_result;			/* used to store result when reading 0xFF9202 */
extern short	fire_result;		/* used to store result when reading 0xFF9200 */
extern short	key_result;			/* used to store result when reading 0xFF9202 */
extern char		joypad_cur[MAX_PLAYERS];		/* useful bit configuration data */
extern char		joypad_old[MAX_PLAYERS];		/* useful bit configuration data */
extern char		joypad_edge[MAX_PLAYERS];		/* useful bit configuration data */
extern char		firebuttons_cur[MAX_PLAYERS];	/* useful bit configuration data */
extern char		firebuttons_old[MAX_PLAYERS];	/* useful bit configuration data */
extern char		firebuttons_edge[MAX_PLAYERS];	/* useful bit configuration data */
extern short	keypad_cur[MAX_PLAYERS];		/* useful bit configuration data */
extern short	keypad_old[MAX_PLAYERS];		/* useful bit configuration data */
extern short	keypad_edge[MAX_PLAYERS];		/* useful bit configuration data */
