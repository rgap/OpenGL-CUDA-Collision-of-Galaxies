
#ifndef GALAXIAQT_H_
#define GALAXIAQT_H_

#include "Cuerpo.h"
#include <vector>

using std::string;

class GalaxiaQT{
public:

	Cuerpo *Root;
	void ObtenerHijo(Cuerpo *P,Cuerpo* H);
	int CargarDub(char *fd);		
	Cuerpo* addCuerpo(Cuerpo* Actual, Cuerpo *cuerp);
	double round(double r,int n_digit);

	Cuerpo *l_Cuerpos;
	
	void N_Body(Cuerpo *c);
	void CalculoFuerza(Cuerpo *a,Cuerpo *b);
	void ActualizaPos(Cuerpo *a);
	GalaxiaQT();
	virtual ~GalaxiaQT();

	int n_Cuerpos;

	int MaxNumCuerpos;

	void addCuerpo(Cuerpo *cuerp);

};

#endif