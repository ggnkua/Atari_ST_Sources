/**************************************************/
/******								******/
/******								******/
/******		  Amiga DSP-Replay			******/
/******		   with P56 Loader			******/
/******								******/
/******								******/
/******	   by Simplet / FATAL DESIGN		******/
/******								******/
/**************************************************/

/*	Structures and Variables	*/

struct	VOICE
		{	long	Voice_Next,Voice_Sample_Start,
				Voice_Sample_Offset,Voice_Sample_Position,
				Voice_Sample_Length,Voice_Sample_Loop_Length;
			int	Voice_Sample_Volume,Voice_Sample_Period,
				Voice_Sample_Fine_Tune;
			long	Voice_Start;
			int	Voice_Volume,Voice_Period,
				Voice_Wanted_Period,Voice_Note;
			char	Voice_Sample,Voice_Command,Voice_Parameters,
				Voice_Tone_Port_Direction,Voice_Tone_Port_Speed,
				Voice_Glissando_Control,Voice_Vibrato_Command,
				Voice_Vibrato_Position,Voice_Vibrato_Control,
				Voice_Tremolo_Command,Voice_Tremolo_Position,
				Voice_Tremolo_Control;

		}	extern	MGTK_Fx_Voices[4],MGTK_Voices[32];

extern	char			MGTK_Restart_Loop,MGTK_Restart_Done;
extern	char			MGTK_Replay_Problem,MGTK_Replay_In_Service;
extern	unsigned int	MGTK_Replay_Satured;
extern	unsigned int	MGTK_Master_Volume_Left,MGTK_Master_Volume_Right;

/*	Functions		*/

extern	int	MGTK_Init_Module_Samples(void *Module,void *EndWorkSpace);
extern	int	MGTK_Init_DSP(void);
extern	void	MGTK_P56_Loader(void *P56_Program,int DSP_Word_Size);
extern	void	MGTK_Save_Sound(void);
extern	void	MGTK_Init_Sound(void);
extern	void	MGTK_Restore_Sound(void);
extern	void	MGTK_Set_Replay_Frequency(int Frequency_Divider);
extern	void	MGTK_Play_Music(void);
extern	void	MGTK_Pause_Music(void);
extern	void	MGTK_Stop_Music(void);
extern	void	MGTK_Play_Position(int Position);
extern	void	MGTK_Previous_Position(void);
extern	void	MGTK_Next_Position(void);
extern	void	MGTK_Play_FX_Module(void);
extern	void	MGTK_Play_FX_Sample(void);
extern	void	MGTK_Clear_Voices(void);
