#include "GalaxiaQT.cuh"

#include <iostream>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>


using namespace std;

//Nbody
double Pxi,Pyi,Pzi,Fx,Fy,Fz,Mi;
double s,d,dx,dy,dz,dist2,dist,Fs,Fsdx,Fsdy,Fsdz,Gdtm;
int contador=0;
double Gdt;
double dt;

GalaxiaQT::GalaxiaQT(){
	
	//this->MaxNumCuerpos=(81920);

	//int numElem=35000;

	int numElem=81920;

	this->MaxNumCuerpos=(numElem);
	this->n_Cuerpos=0;

	//l_Cuerpos=new Cuerpo *[numElem];
	//l_Cuerpos=(Cuerpo**)malloc(sizeof(Cuerpo*)*numElem);

	Root=NULL;
	
}

void GalaxiaQT::addCuerpo(Cuerpo *cuerp){
	if (this->n_Cuerpos<MaxNumCuerpos){
		l_Cuerpos[this->n_Cuerpos] = *cuerp;
		n_Cuerpos++;				
	}
}


void GalaxiaQT::ObtenerHijo(Cuerpo *P,Cuerpo* H) {

	/*		0	|	1	|	2	|	3	|	4	|	5	|	6	|	7
			NE1	   SE1     SO1     NO1	   NE2	   SE2	    SO2	   NO2
	*/

	if(P->PosX<H->PosX){
		
		if(P->PosY<H->PosY){
			if(P->PosZ<H->PosZ){
				P->NE1=addCuerpo(P->NE1,H);	//0
			}else{
				P->NE2=addCuerpo(P->NE2,H);	//4
			}
		}else{
			if (P->PosZ<H->PosZ){
				P->SE1=addCuerpo(P->SE1,H);	//1	
			}else{
				P->SE2=addCuerpo(P->SE2,H);	//5	
			}
		}
	}else{
		if(P->PosY<H->PosY){
			if(P->PosZ<H->PosZ){
				P->NO1=addCuerpo(P->NO1,H);	//3		
			}else{
				P->NO2=addCuerpo(P->NO2,H);	//7
			}  
		}else{
			if (P->PosZ<H->PosZ){
				P->SO1=addCuerpo(P->SO1,H);	//2
			}else{
				P->SO2=addCuerpo(P->SO2,H);	//6
			}
		}
	}
}



Cuerpo* GalaxiaQT::addCuerpo(Cuerpo* Actual, Cuerpo *cuerp){
	if(n_Cuerpos==0){
		Root=new Cuerpo();
		Root->tipo=1;
		Root->indCuerpo=cuerp->indCuerpo;
		Root->masa=cuerp->masa;
		Root->PosX=cuerp->PosX;
		Root->PosY=cuerp->PosY;
		Root->PosZ=cuerp->PosZ;
		Root->VelX=cuerp->VelX;
		Root->VelY=cuerp->VelY;
		Root->VelZ=cuerp->VelZ;
		n_Cuerpos++;
	}
	else{
		if(Actual==NULL){
			Actual=new Cuerpo();
			Actual->tipo=1;
			Actual->indCuerpo=cuerp->indCuerpo;
			Actual->masa=cuerp->masa;
			Actual->PosX=cuerp->PosX;
			Actual->PosY=cuerp->PosY;
			Actual->PosZ=cuerp->PosZ;
			Actual->VelX=cuerp->VelX;
			Actual->VelY=cuerp->VelY;
			Actual->VelZ=cuerp->VelZ;
			n_Cuerpos++;
		}else {
			ObtenerHijo(Actual,cuerp);		
		}
	}
	return Actual;
}
/*

Cuerpo* GalaxiaQT::addCuerpo(Cuerpo* Actual, Cuerpo *cuerp){
	if(n_Cuerpos==0){
		Root=cuerp;
		n_Cuerpos++;
	}else{
		if (Actual==NULL){
			Actual=cuerp;
			n_Cuerpos++;
		}else{
			ObtenerHijo(Actual,cuerp);
		}
	}
}*/

int GalaxiaQT::CargarDub(char *fileD){
	int i=0;
	int contador=0;
	char linea[100];
	Cuerpo *TempCuerpos;
	FILE *file = fopen(fileD, "rb");
	if (!file){		
		return 0; 
	}
	int indice=fseek(file,0,SEEK_END);                
	int tamFile=ftell(file);
	rewind(file);

	//leer el archivo linea por linea
	while(i<MaxNumCuerpos){

		fgets(linea, 100, file);   

		//TempCuerpos=new Cuerpo();
		//TempCuerpos=(Cuerpo*)malloc(sizeof(Cuerpo)*10);
		TempCuerpos=new Cuerpo();

		TempCuerpos->indCuerpo=i;

		TempCuerpos->masa=atof(strtok( linea, " \n\t" ));	
		TempCuerpos->PosX=round(atof(strtok( NULL, " \n\t" )),4);	
		TempCuerpos->PosY=round(atof(strtok( NULL, " \n\t" )),4);	
		TempCuerpos->PosZ=round(atof(strtok( NULL, " \n\t" )),4);	
		TempCuerpos->VelX=round(atof(strtok( NULL, " \n\t" )),4);	
		TempCuerpos->VelY=round(atof(strtok( NULL, " \n\t" )),4);	
		TempCuerpos->VelZ=round(atof(strtok( NULL, " \n\t" )),4);	

		this->addCuerpo(Root,TempCuerpos);
		i++;
	}

	fclose(file);
	return true;	
}

double GalaxiaQT::round(double r,int n_digit){
	int n=pow(10.0,n_digit);
	r=((double)((int)(r*n+0.5)))/n;
	return(r);
}

double Distancia(Cuerpo *a, Cuerpo *b){
	dx=b->PosX-a->PosX;
	dy=b->PosY-a->PosY;;
	dz=b->PosZ-a->PosZ;;
	dist2=(dx*dx) + (dy*dy) + (dz*dz);
	dist=sqrt(dist2);
	return dist;
}

/*		0	|	1	|	2	|	3	|	4	|	5	|	6	|	7
			NE1	   SE1     SO1     NO1	   NE2	   SE2	    SO2	   NO2
	*/
double MayorDist(Cuerpo *a){
	double dist=0;
	if(a->NE1!= NULL && Distancia(a,a->NE1)>dist)
		dist=Distancia(a,a->NE1);
	if(a->SE1!= NULL && Distancia(a,a->SE1)>dist)
		dist=Distancia(a,a->SE1);
	if(a->SO1!= NULL && Distancia(a,a->SO1)>dist)
		dist=Distancia(a,a->SO1);
	if(a->NO1!= NULL && Distancia(a,a->NO1)>dist)
		dist=Distancia(a,a->NO1);
	if(a->NE2!= NULL && Distancia(a,a->NE2)>dist)
		dist=Distancia(a,a->NE2);
	if(a->SE2!= NULL && Distancia(a,a->SE2)>dist)
		dist=Distancia(a,a->SE2);
	if(a->SO2!= NULL && Distancia(a,a->SO2)>dist)
		dist=Distancia(a,a->SO2);
	if(a->NO2!= NULL && Distancia(a,a->NO2)>dist)
		dist=Distancia(a,a->NO2);
	return dist;
}

void GalaxiaQT::ActualizaPos(Cuerpo *c){
	while (c!=NULL)	{
		Gdtm=Gdt/c->masa;
		c->VelX=c->VelX+c->FueX *Gdtm;
		c->PosX=c->PosX+c->VelX*dt/4;
		c->VelY=c->VelY+c->FueY *Gdtm;
		c->PosY=c->PosY+c->VelY*dt/4;
		c->VelZ=c->VelZ+c->FueZ *Gdtm;
		c->PosZ=c->PosZ+c->VelZ*dt/4;
		c->FueX=c->FueY=c->FueZ=0;
		ActualizaPos(c->NE1);
		ActualizaPos(c->SE1);
		ActualizaPos(c->SO1);
		ActualizaPos(c->NO1);
		ActualizaPos(c->NE2);
		ActualizaPos(c->SE2);
		ActualizaPos(c->SO2);
		ActualizaPos(c->NO2);
		break;
	}
}

void GalaxiaQT::CalculoFuerza(Cuerpo *a,Cuerpo *b){

	while (b!=NULL)	{

		s=MayorDist(b);
		d=Distancia(a,b);

		if(s/d<0.45 || a==b){
			//cout<<"entro al ciclo"<<endl;
			CalculoFuerza(a,b->NE1);
			CalculoFuerza(a,b->SE1);
			CalculoFuerza(a,b->SO1);
			CalculoFuerza(a,b->NO1);
			CalculoFuerza(a,b->NE2);
			CalculoFuerza(a,b->SE2);
			CalculoFuerza(a,b->SO2);
			CalculoFuerza(a,b->NO2);
			break;
		}else{
			/*CALCULAMOS LA FUERZA*/
			//cout<<"calculo fuerza"<<endl;
			dx=b->PosX-a->PosX;
			dy=b->PosY-a->PosY;;
			dz=b->PosZ-a->PosZ;;
			dist2=(dx*dx) + (dy*dy) + (dz*dz);
			dist=sqrt(dist2);
			Fs=(b->masa*a->masa)/(dist*dist2);
			Fsdx=Fs*dx;
			Fsdy=Fs*dy;
			Fsdz=Fs*dz;
			b->FueX=b->FueX-Fsdx;
			a->FueX=a->FueX+Fsdx;
			b->FueY=b->FueY-Fsdy;
			a->FueY=a->FueY-Fsdy;
			b->FueZ=b->FueZ-Fsdz;
			a->FueZ=a->FueZ-Fsdz;
			break;
		}
	}
}



void GalaxiaQT::N_Body(Cuerpo *c){


	double G=0.00000000667;//cte gravitacional
	dt=5;//tiempo por iteracion
	double T=10;//tiempo total
	double k=T/dt;
	double temp=0;
	Gdt=G*dt;
	//cout<<"algoritmo NBODY "<<contador<<endl;
	contador++;

	Fx=Fy=Fz=0;
	while (c!=NULL){
		CalculoFuerza(c,c);
		N_Body(c->NE1);
		N_Body(c->SE1);
		N_Body(c->SO1);
		N_Body(c->NO1);
		N_Body(c->NE2);
		N_Body(c->SE2);
		N_Body(c->SO2);
		N_Body(c->NO2);
		break;
	}
}


GalaxiaQT::~GalaxiaQT(){		
}