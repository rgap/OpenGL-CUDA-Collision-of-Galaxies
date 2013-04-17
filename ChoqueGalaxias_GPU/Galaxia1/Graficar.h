#ifndef GRAFICAR_H_
#define GRAFICAR_H_

#include <GL\glut.h>
#include "Galaxia.cuh"

class Graficar{

public:	

	Galaxia *galax;
	
	float M_2PI;
	GLUquadricObj *m_qobj;	
	int resolSphere;
	char* ubicacion;


	void Iniciar();

	void iluminar();

	void leerArchivo(char *archivo);

	void dibujarGalaxia();	
	void dibujarCuerpo(int indCuerpo, int resol);
	void AlgNBody();

	int NumParticulas();

	Graficar() {
		M_2PI=6.283185307179586476925286766559;
		//velocidad
		resolSphere=15;
		galax=0;

		ubicacion="dubinski.tab";//(65536)

		this->leerArchivo(ubicacion);

	}
};

#endif