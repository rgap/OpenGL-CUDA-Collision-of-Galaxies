#include "Cuerpo.h"

using namespace std;

Cuerpo::Cuerpo(){

	indCuerpo=0;
	tipo=0; //vacio 0  hoja 1 nodo sin hojas 2
	masa=0;
	PosX=0;
	PosY=0;
	PosZ=0;
	VelX=0;	
	VelY=0;
	VelZ=0;
	FueX=0;	
	FueY=0;
	FueZ=0;
	
	NE1=NULL;
	NE2=NULL;
	SE1=NULL;
	SE2=NULL;
	NO1=NULL;
	NO2=NULL;
	SO1=NULL;
	SO2=NULL;
}
Cuerpo::~Cuerpo(){
}
