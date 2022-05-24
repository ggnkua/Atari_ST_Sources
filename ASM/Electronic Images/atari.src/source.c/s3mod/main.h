/* MAIN.H */




struct option_struct {
	int gravis_playing;
       	int main_volume;
	int def_tempo;
	int def_bpm;
};


extern struct option_struct options;
extern int gus_dev;


#define VERSION "v1.05"

