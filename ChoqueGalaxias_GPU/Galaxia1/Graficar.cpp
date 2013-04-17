
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
	
	/*float radius=0.15;
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
	galax=new Galaxia();		
	galax->CargarDub(my_file);

}


void Graficar::dibujarGalaxia(){

	int nCuerpos = galax->n_Cuerpos;

	int i=0;

	while(i<nCuerpos){	

		dibujarCuerpo(i, resolSphere);

		i++;
	}
	
}

void Graficar::dibujarCuerpo(int indCuerpo, int resol){

	float radius=pow((galax->cuerpos.masa[indCuerpo])/((4/3)*3.1416*1.5),1.0/3);

	glPushMatrix();

	if (indCuerpo < 32768)
		glColor3f(1.0f,1.0f,1.0f);

	if (32768 <= indCuerpo && indCuerpo < 49152)
		glColor3f(1.0f,1.0f,1.0f);

	if (indCuerpo >= 49152)
		glColor3f(0.0f,0.5f,0.7f);
			
	//glTranslated(cuerpo->PosX-1.5,cuerpo->PosY+8,cuerpo->PosZ-12);
	glTranslated(galax->cuerpos.PosX[indCuerpo],galax->cuerpos.PosY[indCuerpo],galax->cuerpos.PosZ[indCuerpo]);
	glRotatef(1.0f,galax->cuerpos.VelX[indCuerpo],galax->cuerpos.VelY[indCuerpo],galax->cuerpos.VelZ[indCuerpo]);

	gluSphere(m_qobj,radius,resol,resol);	

	glPopMatrix();
}

void Graficar::AlgNBody(){

	galax->N_Body();

}

int Graficar::NumParticulas(){
	return galax->MaxNumCuerpos;
}