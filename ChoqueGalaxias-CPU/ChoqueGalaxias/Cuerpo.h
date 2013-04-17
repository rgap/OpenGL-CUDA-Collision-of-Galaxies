#ifndef CUERPO_H_
#define CUERPO_H_

#include <string>
#include <math.h>
#include <iostream>
#include <GL/glut.h>

class Cuerpo{
public:

	int indCuerpo;

	double masa;

	double PosX;
	double PosY;
	double PosZ;
	double VelX;
	double VelY;
	double VelZ;
	double FueX;
	double FueY;
	double FueZ;

	Cuerpo * NE1;
	Cuerpo * NE2;
	Cuerpo * SE1;
	Cuerpo * SE2;
	Cuerpo * NO1;
	Cuerpo * NO2;
	Cuerpo * SO1;
	Cuerpo * SO2;
	int tipo; //

	Cuerpo(); // constructor
	virtual ~Cuerpo(); //destructor
};

#endif