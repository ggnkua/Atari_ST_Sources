// cad-3d v2.0 to pov
// (c) 2014 by folkert@vanheusden.com
#include <fcntl.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string>
#include <vector>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "error.h"

#define max(x, y) ((x) > (y) ? (x) : (y))

int obCount = 0;

typedef struct {
	int vA, vB, vC;
	int colorGroup;
	bool acIsEdge, bcIsEdge, abIsEdge;
} face_t;

typedef struct {
	double x, y, z;
} vert_t;

class obj {
public:
	std::string name;
	std::vector<vert_t> vertices;
	std::vector<face_t> faces;
};

std::vector<obj> objects;

bool lightAEnabled = false, lightBEnabled = false, lightCEnabled = false;
int lightABrightness = 1, lightBBrightness = 1, lightCBrightness = 1;
double lightAx = 1, lightBx = 1, lightCx = 1;
double lightAy = 1, lightBy = 1, lightCy = 1;
double lightAz = 1, lightBz = 1, lightCz = 1;
int ambientBrightness = 1;

int palette[16], colorGroup[16];

int getWord(int fd)
{
	uint8_t buffer[2];

	if (read(fd, buffer, sizeof buffer) != 2)
		error_exit(true, "problem reading data from file (getWord)");

	return (buffer[0] << 8) | buffer[1];
}

int getSWord(int fd)
{
	return (int16_t)getWord(fd);
}

// is this also libf? or was v1 of this format only using libf?
double getLibf(int fd)
{
	int16_t v = getSWord(fd);

	return (double)v / 100.0;
}

void processHeader(int fd)
{
	int id = getWord(fd);

	if (id != 0x3d02)
		error_exit(false, "might not be a valid file");

	obCount = getWord(fd);
	fprintf(stderr, "object count: %d\n", obCount);

	if (obCount < 1 || obCount > 40)
		error_exit(false, "invalid object count");

	lightAEnabled = getWord(fd);
	lightBEnabled = getWord(fd);
	lightCEnabled = getWord(fd);

	lightABrightness = getWord(fd) & 7;
	lightBBrightness = getWord(fd) & 7;
	lightCBrightness = getWord(fd) & 7;

	ambientBrightness = getWord(fd) & 7;

	lightAz = getSWord(fd);
	lightBz = getSWord(fd);
	lightCz = getSWord(fd);

	lightAy = getSWord(fd);
	lightBy = getSWord(fd);
	lightCy = getSWord(fd);

	lightAx = getSWord(fd);
	lightBx = getSWord(fd);
	lightCx = getSWord(fd);

	for(int pi=0; pi<16; pi++)
		palette[pi] = getWord(fd);

	for(int pgi=0; pgi<16; pgi++)
		colorGroup[pgi] = getWord(fd);

	(void)getWord(fd);	// col pal type (0=7shade, 1=14shade, 2=custom)
	(void)getWord(fd);	// wireframe color (1-15)
	(void)getWord(fd);	// outline line color (0-15)
	
	char buffer[150];
	read(fd, buffer, 150);
}

void processData(int fd)
{
	for(int oi=0; oi<obCount; oi++)
	{
		obj newObj;

		char buffer[9 + 1];
		read(fd, buffer, 9);
		buffer[9] = 0x00;
		newObj.name = std::string(buffer);

		int nVertices = getWord(fd);
		if (nVertices > 15000)
			error_exit(false, "invalid vertices count %d", nVertices);

		fprintf(stderr, "%d] name: %s\n", oi + 1, buffer);

		fprintf(stderr, "%d] vertices: %d\n", oi + 1, nVertices);

		for(int vi=0; vi<nVertices; vi++)
		{
			double x = getLibf(fd);
			double y = getLibf(fd);
			double z = getLibf(fd);
			vert_t v = { x, y, z };

			newObj.vertices.push_back(v);
		}

		int nFaces = getWord(fd);

		fprintf(stderr, "%d] faces: %d\n", oi + 1, nFaces);

		for(int mi=0; mi<nFaces; mi++)
		{
			face_t f = { 0 };

			f.vA = getWord(fd);
			f.vB = getWord(fd);
			f.vC = getWord(fd);

			int meta = getWord(fd);

			f.colorGroup = meta & 15;

			f.acIsEdge = meta & (1 <<  8);
			f.bcIsEdge = meta & (1 <<  9);
			f.abIsEdge = meta & (1 << 10);

			newObj.faces.push_back(f);
		}

		objects.push_back(newObj);
	}
}

void lightSource(FILE *fh, bool enabled, int brightness, double x, double y, double z)
{
	if (enabled)
	{
		double r = (double)brightness / 15.0;
		double g = r;
		double b = r;

		fprintf(fh, "light_source { <%f, %f, %f> color rgb <%f, %f, %f> }\n", x, y, z, r, g, b);
	}
}

void camera(FILE *fh)
{
	double minx = 65535.0;
	double miny = 65535.0;
	double minz = 65535.0;
	double maxx = -65535.0;
	double maxy = -65535.0;
	double maxz = -65535.0;

	for(unsigned int oi=0; oi<objects.size(); oi++)
	{
		obj *o = &objects.at(oi);

		for(unsigned int vi=0; vi<o -> vertices.size(); vi++)
		{
			double x = o -> vertices.at(vi).x;
			double y = o -> vertices.at(vi).y;
			double z = o -> vertices.at(vi).z;

			if (x < minx)
				minx = x;
			if (x > maxx)
				maxx = x;

			if (y < miny)
				miny = y;
			if (y > maxy)
				maxy = y;

			if (z < minz)
				minz = z;
			if (z > maxz)
				maxz = z;
		}
	}

	double lax = (minx + maxx) / 2.0;
	double lay = (miny + maxy) / 2.0;
	double laz = (minz + maxz) / 2.0;

	// FIXME improve this
	// http://www.java-gaming.org/index.php?topic=30834.0
	double alpha = atan2(minx, miny);
	double beta  = atan2(miny, minz);
	double gamma = atan2(minx, minz);
	///
	double sin_a = sin(alpha);
	double sin_b = sin(beta);
	double sin_g = sin(gamma);  

	double cos_a = cos(alpha);
	double cos_b = cos(beta);
	double cos_g = cos(gamma);

	double PositionMatrix[] = { minx, miny, minz };      

	double RotationMatrix[3][3] = {
		{ cos_a * cos_b, (cos_a * sin_b * sin_g) - (sin_a * cos_g),   (cos_a * sin_b * cos_g) + (sin_a * sin_g)  },
		{ sin_a * cos_b, (sin_a * sin_b * sin_g) + (cos_a * cos_g),   (sin_a * sin_b * cos_g) - (cos_a * sin_g)  },
		{ -sin_b       ,  cos_b * sin_g                           ,   cos_b * cos_g                              }
			};

	double new_x_calc_1 = RotationMatrix[0][0] * PositionMatrix[0];
	double new_x_calc_2 = RotationMatrix[0][1] * PositionMatrix[1];
	double new_x_calc_3 = RotationMatrix[0][2] * PositionMatrix[2];

	double new_y_calc_1 = RotationMatrix[1][0] * PositionMatrix[0];
	double new_y_calc_2 = RotationMatrix[1][1] * PositionMatrix[1];
	double new_y_calc_3 = RotationMatrix[1][2] * PositionMatrix[2];

	double new_z_calc_1 = RotationMatrix[2][0] * PositionMatrix[0];
	double new_z_calc_2 = RotationMatrix[2][1] * PositionMatrix[1];
	double new_z_calc_3 = RotationMatrix[2][2] * PositionMatrix[2];

	double cx = (float)(new_x_calc_1 + new_x_calc_2 + new_x_calc_3);
	double cy = (float)(new_y_calc_1 + new_y_calc_2 + new_y_calc_3);
	double cz = (float)(new_z_calc_1 + new_z_calc_2 + new_z_calc_3);
	///

	fprintf(fh, "camera { location <%f, %f, %f> look_at<%f, %f, %f> }\n", cx, cy, cz, lax, lay, laz);
}

int main(int argc, char *argv[])
{
	printf("cad3d_to_pov v" VERSION ", (c) 2014 by folkert@vanheusden.com\n\n");

	if (argc != 3)
		error_exit(false, "Usage: %s file.3d2 file-out.pov\n\n", argv[0]);

	int fd = open(argv[1], O_RDONLY);

	if (fd == -1)
		error_exit(true, "Cannot open %s", argv[1]);

	processHeader(fd);

	processData(fd);

	close(fd);

	FILE *fh = fopen(argv[2], "w");
	if (!fh)
		error_exit(true, "Cannot create %s", argv[2]);

	camera(fh);

	lightSource(fh, lightAEnabled, lightABrightness, lightAx, lightAy, lightAz);
	lightSource(fh, lightBEnabled, lightBBrightness, lightBx, lightBy, lightBz);
	lightSource(fh, lightCEnabled, lightCBrightness, lightCx, lightCy, lightCz);

	for(unsigned int oi=0; oi<objects.size(); oi++)
	{
		obj *o = &objects.at(oi);

		for(unsigned int fi=0; fi<o -> faces.size(); fi++)
		{
			int vA = o -> faces.at(fi).vA;
			int vB = o -> faces.at(fi).vB;
			int vC = o -> faces.at(fi).vC;

			int cg = o -> faces.at(fi).colorGroup;

			double x1 = o -> vertices.at(vA).x;
			double y1 = o -> vertices.at(vA).y;
			double z1 = o -> vertices.at(vA).z;

			double x2 = o -> vertices.at(vB).x;
			double y2 = o -> vertices.at(vB).y;
			double z2 = o -> vertices.at(vB).z;

			double x3 = o -> vertices.at(vC).x;
			double y3 = o -> vertices.at(vC).y;
			double z3 = o -> vertices.at(vC).z;

			int ri = (palette[cg + 4] >> 6) & 7;
			int gi = (palette[cg + 4] >> 3) & 7;
			int bi = palette[cg + 4] & 7;

			double r = (double)ri / 7.0;
			double g = (double)gi / 7.0;
			double b = (double)bi / 7.0;

			fprintf(fh, "triangle { <%f, %f, %f>, <%f, %f, %f>, <%f, %f, %g> pigment { color rgb <%f, %f, %f> } }\n", x1, y1, z1, x2, y2, z2, x3, y3, z3, r, g, b);
		}
	}

	fclose(fh);

	return 0;
}
