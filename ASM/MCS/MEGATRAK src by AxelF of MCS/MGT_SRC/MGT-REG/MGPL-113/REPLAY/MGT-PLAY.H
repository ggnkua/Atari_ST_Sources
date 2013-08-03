/**************************************************/
/******								******/
/******								******/
/******	  MegaTracker v1.1 DSP-Replay		******/
/******								******/
/******								******/
/******	   by Simplet / FATAL DESIGN		******/
/******								******/
/**************************************************/

/*	Structures and Variables	*/

struct	VOICE
		{	long	Voice_Sample_Start,Voice_Sample_Offset,
				Voice_Sample_Position,Voice_Sample_Length,
				Voice_Sample_Loop_Length,Voice_Sample_End_Length;
			long	Voice_Sample_Base;
			int	Voice_Sample_Volume;
			long	Voice_Sample_Period;
			int	Voice_Sample_Fine_Tune;
			char	Voice_Dummy1,Voice_Sample_Attributes,
				Voice_Left_Volume,Voice_Right_Volume;
			long	Voice_Start,Voice_Length,Voice_Loop_Length,
				Voice_End_Length,Voice_Base;
			int	Voice_Volume;
			long	Voice_Period;
			char	Voice_Attributes,Voice_Dummy2,
				Voice_Note,Voice_Sample,
				Voice_Command,Voice_Parameter1,Voice_Parameter2;
			long	Voice_Tone_Port_Period,Voice_Tone_Port_Speed;
			char	Voice_Tone_Port_Direction,Voice_Glissando_Control,
				Voice_Vibrato_Waveform,Voice_Vibrato_Speed;
			int	Voice_Vibrato_Depth;
			char	Voice_Vibrato_Position,Voice_Tremolo_Waveform;
			int	Voice_Tremolo_Depth;
			char	Voice_Tremolo_Speed,Voice_Tremolo_Position;

		}	extern	MGTK_Fx_Voices[2],MGTK_Voices[32];

extern	int		MGTK_Global_Volume;
extern	char		MGTK_Master_Volume_Left,MGTK_Master_Volume_Right;
extern	char		MGTK_Restart_Loop,MGTK_Restart_Done;
extern	char		MGTK_Replay_Problem,MGTK_Replay_In_Service;
extern	int		MGTK_Replay_Satured;

/*	Functions		*/

extern	int	MGTK_Init_Module_Samples(void *Module,void *EndWorkSpace);
extern	int	MGTK_Init_DSP(void);
extern	void	MGTK_Save_Sound(void);
extern	void	MGTK_Init_Sound(void);
extern	void	MGTK_Restore_Sound(void);
extern	void	MGTK_Set_Replay_Frequency(int Frequency_Divider);
extern	void	MGTK_Play_Music(int Music);
extern	void	MGTK_Pause_Music(void);
extern	void	MGTK_Stop_Music(void);
extern	void	MGTK_Previous_Music(void);
extern	void	MGTK_Next_Music(void);
extern	void	MGTK_Play_Position(int Position);
extern	void	MGTK_Previous_Position(void);
extern	void	MGTK_Next_Position(void);
extern	void	MGTK_Play_FX_Module(void);
extern	void	MGTK_Play_FX_Sample(void);
extern	void	MGTK_Clear_Voices(void);
