#ifndef GRAFICAR_H_
#define GRAFICAR_H_

#include "Cuerpo.h"
#include "GalaxiaQT.cuh"

class Graficar{
public:	
	void dibujarCuerpo(Cuerpo *cuerpo, int resol);
	void iluminar();
	void dibujarGalaxia();	
	int NumParticulas();

	GalaxiaQT *galax;
	void leerArchivo(char *my_file);
	void Iniciar();
	void Preorden(Cuerpo *cuerpo);
	void AlgNBody();
	double M_2PI;
	GLUquadricObj *m_qobj;	
	int resolSphere;
	char* ubicacion;

	Graficar() {
		M_2PI=6.283185307179586476925286766559;
		//velocidad
		resolSphere=15;
		galax=NULL;

		ubicacion="dubinski.tab";
		this->leerArchivo(ubicacion);
	}
};

#endif