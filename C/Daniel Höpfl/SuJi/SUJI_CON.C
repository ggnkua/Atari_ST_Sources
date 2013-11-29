#include "SuJi_glo.h"

static char config_path[256];

void load_config (void)
{
	FILE *fp;
	
	if ( home_search( "suji.inf" , config_path ) )
	{
		fp = fopen( config_path, "r" );
		if (fp != NULL)
		{
			fread ( (void *)&config, 1, sizeof (struct CONFIG), fp );
			fclose ( fp );
		}
	}
	else
	{
		config.dialog.g_x = -1;
		config.dialog.g_y = -1;
		config.listwindow.g_x = -1;
		config.listwindow.g_y = -1;
		config.show_size = 1;
		config.show_time = 1;
		config.show_date = 1;
		config.show_flags = 1;
		config.show_origin = 1;
		config.clipboard_name = 0;
		config.clipboard_size = 0;
		config.clipboard_time = 0;
		config.clipboard_date = 0;
		config.clipboard_flags = 0;
		config.clipboard_origin = 1;
	}
	set_show();
}

void save_config (void)
{
	FILE *fp;
	
	fp = fopen( config_path, "w" );
	if (fp != NULL)
	{
		fwrite ( (void *)&config, 1, sizeof (struct CONFIG), fp );
		fclose ( fp );
	}
}

void set_show (void)
{
	show_row[BR_FILE]=1;
	show_row[BR_SIZE]=config.show_size;
	show_row[BR_TIME]=config.show_time;
	show_row[BR_DATE]=config.show_date;
	show_row[BR_ATTR]=config.show_flags;
	show_row[BR_PATH]=config.show_origin;
}

void get_show (void)
{
	config.show_size=show_row[BR_SIZE];
	config.show_time=show_row[BR_TIME];
	config.show_date=show_row[BR_DATE];
	config.show_flags=show_row[BR_ATTR];
	config.show_origin=show_row[BR_PATH];
}
