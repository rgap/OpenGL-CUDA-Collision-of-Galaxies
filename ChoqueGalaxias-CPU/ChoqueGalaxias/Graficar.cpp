
#include "Graficar.h"
#include <iostream>


using namespace std;

void Graficar::Iniciar(){
	//objeto global de tipo cuadrica (superficie en 3D )
	if (m_qobj!=NULL) 
		gluDeleteQuadric(m_qobj);
	m_qobj=gluNewQuadric();
	gluQuadricDrawStyle(m_qobj,GLU_FILL);
	gluQuadricNormals(m_qobj,GLU_SMOOTH);

	dibujarGalaxia();
	
	/*double radius=0.15;
	glPushMatrix();
	glColor3f(1.0f,1.0f,1.0f);		
	glTranslated(1.70505,-5.0661,6.82502);	    
	gluSphere(m_qobj,radius,resolSphere,resolSphere);	
	glPopMatrix();
*/
	iluminar();
	glEnable(GL_COLOR_MATERIAL);
	glColorMaterial(GL_FRONT, GL_DIFFUSE);
}
void Graficar::iluminar()
{
	glMatrixMode(GL_MODELVIEW);
	GLfloat m_light_position[]={10, 10,-10, 0.0}; //Light at (0,500,1000)
	GLfloat m_light_diffuse[]={1.0, 1.0, 1.0, 1.0};

	glLightfv(GL_LIGHT0, GL_DIFFUSE, m_light_diffuse);
	glLightfv(GL_LIGHT0, GL_POSITION, m_light_position);
	glEnable(GL_LIGHT0);
	glEnable(GL_LIGHTING);

}


void Graficar::leerArchivo(char *my_file){
	if (galax!=NULL) 
		delete galax;
	galax=new GalaxiaQT();		
	galax->CargarDub(my_file);

}

/*		0	|	1	|	2	|	3	|	4	|	5	|	6	|	7
		NE1	   SE1     SO1     NO1	   NE2	   SE2	    SO2	   NO2
	*/
void Graficar::Preorden(Cuerpo *cuerpo){
	if (cuerpo!=NULL){
		
		dibujarCuerpo(cuerpo, resolSphere);
		//cout<<cuerpo->PosX<<endl;
		Preorden(cuerpo->NE1);
		Preorden(cuerpo->SE1);
		Preorden(cuerpo->SO1);
		Preorden(cuerpo->NO1);
		Preorden(cuerpo->NE2);
		Preorden(cuerpo->SE2);
		Preorden(cuerpo->SO2);
		Preorden(cuerpo->NO2);
		
		
	}
}
void Graficar::dibujarGalaxia(){

	Preorden(galax->Root);
}

void Graficar::dibujarCuerpo(Cuerpo *cuerpo, int resol){

	double radius=pow((cuerpo->masa)/((4/3)*3.1416*1.5),1.0/3);
	
	glPushMatrix();

	/*
	if (cuerpo->indCuerpo<galax->MaxNumCuerpos/2){
		glColor3f(1.0f,1.0f,1.0f);
	}
	else
	{
		glColor3f(1.0f,1.0f,0.0f);
	}
	*/

	if (cuerpo->indCuerpo < 32768)
		glColor3f(1.0f,1.0f,1.0f);

	if (32768 <= cuerpo->indCuerpo && cuerpo->indCuerpo < 49152)
		glColor3f(1.0f,1.0f,1.0f);

	if (cuerpo->indCuerpo >= 49152)
		glColor3f(0.0f,0.5f,0.7f);

	//glColor3f(0.0f,0.5f,0.7f);			
	glTranslated(cuerpo->PosX,cuerpo->PosY,cuerpo->PosZ);	   
	glRotatef(1.0f,cuerpo->VelX,cuerpo->VelY,cuerpo->VelZ);
	gluSphere(m_qobj,radius,resol,resol);	
	glPopMatrix();
}

void Graficar::AlgNBody(){
	
		galax->N_Body(galax->Root);
		galax->ActualizaPos(galax->Root);
}


int Graficar::NumParticulas(){
	return galax->MaxNumCuerpos;
}

