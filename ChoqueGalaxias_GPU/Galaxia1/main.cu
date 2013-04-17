#include <string.h>
#include <stdio.h>
#include <gl/glut.h>
//#include <gl.h>
#include <Windows.h>
#include "Graficar.h"


/* Windows parameters */
#define WIDTH  800
#define HEIGHT 800
#define TITLE  "GALAXIA"
int winIdMain;
int winIdSub;

Graficar *dibujo=new Graficar();
float rotx_angle=0,xold;
float roty_angle=0,yold;
GLint profundidad=-60;
char * NombDoc=dibujo->ubicacion;
int NumP=dibujo->NumParticulas();

/* Animation State Variables */
#define SMALL_ANGLE  5.0
#define TIME_STEP    0.1
static double tiempoT = 0.0;
static double spin = 0.0;


/* This function renders a character string
   onto the current position */
static char label[100];

void drawString (char *s)
{
  unsigned int i;
  for (i = 0; i < strlen (s); i++)
    glutBitmapCharacter (GLUT_BITMAP_HELVETICA_10, s[i]);
};

void drawStringBig (char *s)
{
  unsigned int i;
  for (i = 0; i < strlen (s); i++)
    glutBitmapCharacter (GLUT_BITMAP_HELVETICA_18, s[i]);
};

void init(void){

	//glClearColor(125.0, 125.0, 125.0, 1.0); //define el color de fondo
	glShadeModel(GL_SMOOTH); // modelar las esferas
	glViewport(0,0,WIDTH,HEIGHT); //resetea el puerto de vision
	glMatrixMode(GL_PROJECTION);  // Selecciona la matriz de proyeccion
	glLoadIdentity();  // Resetea la matriz de proyeccion
	gluPerspective(45.0f,(GLfloat)WIDTH/(GLfloat)HEIGHT,1.0f,100.0f); //define el volumen
	gluLookAt(0, 0,profundidad,  //permite definir el angulo de la camara
		0,0,0,
		0.0f,1.0f,0.0f);
	glEnable(GL_DEPTH_TEST);  //activar el buffer de profundidad
	glPolygonMode (GL_FRONT_AND_BACK, GL_FILL); //ecuacion de superficie 3D
	glEnable(GL_LIGHTING);
	glEnable(GL_NORMALIZE);
	glEnable(GL_COLOR_MATERIAL);

}

void dibuja(){


	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); //se borra el buffer de la pantalla

	glFlush();
	glRotatef(rotx_angle,0.0,1.0,0.0);
	glRotatef(roty_angle,1.0,0.0,0.0);	
	dibujo->Iniciar();		


	glFlush();
	glutSwapBuffers();
	glutPostRedisplay();

}
/* Here is a display fucntion that updates
   the main graphic window */
void mainDisplay (void)
{

  /* Clean drawing board */
  glutSetWindow (winIdMain);
 
 
  init();

  //dibujo->AlgNBody();

  dibuja();

  //dibujo->AlgNBody();
};



/* Another display function, this one will be 
   used to update the graphic subwindow */
void subDisplay ()
{

  /* Clear subwindow */
  glutSetWindow (winIdSub);
  glClearColor (0.25, 0.25, 0.25, 0.0);
  glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  /* Draw border */
  glColor3f (0.0F, 1.0F, 0.0F);
  glBegin (GL_LINE_LOOP);
  glVertex2f (0.0F, 0.0F);
  glVertex2f (0.0F, 0.99F);
  glVertex2f (0.999F, 0.99F);
  glVertex2f (0.999F, 0.0F);
  glEnd ();

  /* Type State Variables */
  glColor3f (1.0F, 1.0F, 1.0F);
  sprintf (label, "Tiempo = %8.3f ", tiempoT);
  glRasterPos2f (0.05F, 0.75F);
  drawString (label);


  sprintf (label, "Nombre Archivo = %s ", NombDoc);
  glRasterPos2f (0.05F, 0.55F);
  drawString (label);

   sprintf (label, "Numero de Particulas = %i ", NumP);
  glRasterPos2f (0.05F, 0.35F);
  drawString (label);

  /* Type Banner and info */
  glColor3f (1.0F, 0.0F, 1.0F);
  sprintf (label, " Galaxia OPENGL ");
  glRasterPos2f (0.40F, 0.70F);
  drawStringBig (label);

  sprintf (label, " Curso de Computacion Grafica. UNSA 2012 ");
  glRasterPos2f (0.33F, 0.35F);
  drawStringBig (label);

  glutSwapBuffers ();
};

void redimensionado(int anchop, int altop) {
	glViewport(0,0,anchop,altop);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60.0f,(GLfloat)WIDTH/(GLfloat)HEIGHT,0.1,100);
	gluLookAt(0,0,profundidad,0,0,0,0,1,0);

	glMatrixMode(GL_MODELVIEW);
}

/* Callback function for reshaping the main window */
void mainReshape (int w, int h)
{
  glViewport (0, 0, w, h);
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity ();
  gluOrtho2D (-1.0F, 1.0F, -1.0F, 1.0F);
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity ();

  glutSetWindow (winIdSub);
  glutReshapeWindow (w - 10, h / 10);
  glutPositionWindow (5, 5);
  glutSetWindow (winIdMain);

};


/* Callback function for reshaping the subwindow */
void subReshape (int w, int h)
{
  glViewport (0, 0, w, h);
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity ();
  gluOrtho2D (0.0F, 1.0F, 0.0F, 1.0F);
};


void inputKey(int key, int x, int y) {

	switch (key) {

		case GLUT_KEY_LEFT :
			rotx_angle-=0.5;
			dibuja();
			break;
		case GLUT_KEY_RIGHT :
			rotx_angle+=0.5;
			dibuja();
			break;
		case GLUT_KEY_UP :
			roty_angle+=0.5;
			dibuja();
			break;
		case GLUT_KEY_DOWN :
			roty_angle-=0.5;
			dibuja();
			break;
		
	}
}

/* Now comes a function that processes keyboard events */
void keyboard (unsigned char key, int x, int y)
{
  static int info_banner = 1;

  switch (key)
    {
    case 'i':
    case 'I':
      if (info_banner)	{
	  glutSetWindow (winIdSub);
	  glutHideWindow ();
	}else{
	  glutSetWindow (winIdSub);
	  glutShowWindow ();
	};
      info_banner = !info_banner;
      break;
    case 'q':
    case 'Q':
      //exit (0);
      break;
	case 'n':
	case 'N':
	  dibujo->AlgNBody();
	  dibuja();
	  break;
    };
	
};	





/* There can be only one idle() callback function. In an
   animation, this idle() function must update not only the
   main window but also all derived subwindows */
void idle (void)
{

  /* Update  state variables */
  spin += SMALL_ANGLE;
  tiempoT += TIME_STEP;

  /* Update main and sub window */
  glutSetWindow (winIdMain);
  glutPostRedisplay ();
  glutSetWindow (winIdSub);
  glutPostRedisplay ();
};




int main (int argc, char **argv)
{

  /* Glut initializations */
  glutInit (&argc, argv);
  glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
  glutInitWindowPosition (5, 5);
  glutInitWindowSize (WIDTH, HEIGHT);

  /* Main window creation and setup */
  winIdMain = glutCreateWindow (TITLE);


  glutDisplayFunc (mainDisplay);
  glutReshapeFunc (redimensionado);
  glutSpecialFunc(inputKey);
  glutKeyboardFunc (keyboard);
  glutIdleFunc (idle);

  /* Sub window creation and setup */
  winIdSub = glutCreateSubWindow (winIdMain, 5, 5, WIDTH - 10, HEIGHT / 10);
  glutDisplayFunc (subDisplay);
  glutReshapeFunc (subReshape);

  glutMainLoop ();

  return 0;
};