
#ifndef GALAXIA_H_
#define GALAXIA_H_

#include "Cuerpos.h"

class Galaxia{

public:

	Cuerpos cuerpos;
	int n_Cuerpos;
	int MaxNumCuerpos;

	//variables particulas
	float * masa_GPU;
	float * PosX_GPU;
	float * PosY_GPU;
	float * PosZ_GPU;
	float * VelX_GPU;
	float * VelY_GPU;
	float * VelZ_GPU;
	float * FueX_GPU;
	float * FueY_GPU;
	float * FueZ_GPU;

	Galaxia();

	int CargarDub(char *fd);			
	float round(float r,int n_digit);

	void N_Body();

	void calcN_Body(int i,int MaxNumCuerpos,float Pxi,float Pyi,float Pzi,float Mi);

	//void calcN_Body(int MaxNumCuerpos);

	virtual ~Galaxia();

};

#endif