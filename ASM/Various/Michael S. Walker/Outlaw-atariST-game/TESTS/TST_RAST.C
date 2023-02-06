#include <stdio.h>
#include <osbind.h>
#include <RASTER.H>
#include <BITMAP.H>
#include <P1_NORM.C>
#include <P1_WALK.C>
#include <P2_NORM.C>
#include <P2_WALK.C>
#include <P2_SH.C>

#define P2_SHOOT 3

int main(int argc, char *argv[])
{
	Bitmap player1, player2;
	int p1_img_index, p2_img_index, read_char = -1;
	void *base = Physbase();

	p1_img_index = p2_img_index = 0;
	player1.height = 32; /* make gen */
	player1.images[0] = p1_normal;
	player1.images[1] = p1_walk;
	player1.current_image = player1.images[p1_img_index];
	player1.x_pos_col = 0;
	player1.y_pos_row = 0;
	player1.raster.Draw = Rast32Draw;
	player1.raster.Alpha = Rast32Alpha;
	player1.raster.Clear = Rast32Clear;

	player2.height = 32; /* make gen */
	player2.images[0] = p2_normal;
	player2.images[1] = p2_walk;
	player2.images[3] = p2_shoot;
	player2.current_image = player2.images[p2_img_index];
	player2.x_pos_col = 608;
	player2.y_pos_row = 350;
	player2.raster.Draw = Rast32Draw;
	player2.raster.Alpha = Rast32Alpha;
	player2.raster.Clear = Rast32Clear;

	PLotRectangle(base, 120, 32, 300, 120);

	player2.raster.Alpha(base, &player2);
	player1.raster.Alpha(base, &player1);
	while (read_char != 41)
	{
		read_char = Cnecin();
		switch (read_char)
		{
		case 119: /* w up */
			player1.raster.Clear(base, &player1);
			player1.raster.Alpha(base, &player1);
			player1.y_pos_row -= 32;
			p1_img_index ^= 0x1;
			player1.current_image = player1.images[p1_img_index];
			player1.raster.Alpha(base, &player1);
			break;
		case 115: /* s down */
			player1.raster.Clear(base, &player1);
			player1.raster.Alpha(base, &player1);
			player1.y_pos_row += 32;
			p1_img_index ^= 0x1;
			player1.current_image = player1.images[p1_img_index];
			player1.raster.Alpha(base, &player1);
			break;
		case 97: /* a left */
			player1.raster.Clear(base, &player1);
			player1.raster.Alpha(base, &player1);
			player1.x_pos_col -= 32;
			p1_img_index ^= 0x1;
			player1.current_image = player1.images[p1_img_index];
			player1.raster.Alpha(base, &player1);
			break;
		case 100: /* d right */
			player1.raster.Clear(base, &player1);
			player1.raster.Alpha(base, &player1);
			player1.x_pos_col += 32;
			p1_img_index ^= 0x1;
			player1.current_image = player1.images[p1_img_index];
			player1.raster.Alpha(base, &player1);
			break;
		default:
			break;
		}

		player2.raster.Clear(base, &player2);
		player2.raster.Alpha(base, &player2);
		if (player1.y_pos_row == player2.y_pos_row)
			player2.current_image = player2.images[P2_SHOOT];
		else
		{
			player1.y_pos_row > player2.y_pos_row ? player2.y_pos_row += 32 : player2.y_pos_row -= 32;
			p2_img_index ^= 0x1;
			player2.current_image = player2.images[p2_img_index];
		}
		player1.raster.Alpha(base, &player2);
	}
	return 0;
}
