#include "Galaxia.cuh"

#include <iostream>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "cuPrintf.cu"

#if __CUDA_ARCH__ < 200 	//Compute capability 1.x architectures
#define CUPRINTF cuPrintf 
#else						//Compute capability 2.x architectures
#define CUPRINTF(fmt, ...) printf("[%d, %d]:\t" fmt, \
								blockIdx.y*gridDim.x+blockIdx.x,\
								threadIdx.z*blockDim.x*blockDim.y+threadIdx.y*blockDim.x+threadIdx.x,\
								__VA_ARGS__)
#endif

using namespace std;

Galaxia::Galaxia(){
	//this->MaxNumCuerpos= 81920;  65536

	this->MaxNumCuerpos=81920;
	this->n_Cuerpos=0;

	cuerpos.FueX = new float [MaxNumCuerpos];
	cuerpos.FueY = new float [MaxNumCuerpos];
	cuerpos.FueZ = new float [MaxNumCuerpos];

	cuerpos.PosX = new float [MaxNumCuerpos];
	cuerpos.PosY = new float [MaxNumCuerpos];
	cuerpos.PosZ = new float [MaxNumCuerpos];

	cuerpos.VelX = new float [MaxNumCuerpos];
	cuerpos.VelY = new float [MaxNumCuerpos];
	cuerpos.VelZ = new float [MaxNumCuerpos];

	cuerpos.masa = new float [MaxNumCuerpos];
}


int Galaxia::CargarDub(char *fileD){

	int i=0;
	int contador=0;
	char linea[100];

	FILE *file = fopen(fileD, "rb");

	if (!file) return false; 

	int indice=fseek(file,0,SEEK_END);                
	int tamFile=ftell(file);

	rewind(file);

	//leer el archivo linea por linea
	while(i<MaxNumCuerpos){

		fgets(linea, 100, file);   

		cuerpos.masa[n_Cuerpos] = atof(strtok( linea, " \n\t" ));	
		cuerpos.PosX[n_Cuerpos] = round(atof(strtok( NULL, " \n\t" )),4);	
		cuerpos.PosY[n_Cuerpos] = round(atof(strtok( NULL, " \n\t" )),4);	
		cuerpos.PosZ[n_Cuerpos] = round(atof(strtok( NULL, " \n\t" )),4);	
		cuerpos.VelX[n_Cuerpos] = round(atof(strtok( NULL, " \n\t" )),4);	
		cuerpos.VelY[n_Cuerpos] = round(atof(strtok( NULL, " \n\t" )),4);	
		cuerpos.VelZ[n_Cuerpos] = round(atof(strtok( NULL, " \n\t" )),4);	

		n_Cuerpos++;

		i++;
	}

	fclose(file);

	return true;	
}

float Galaxia::round(float r,int n_digit){

	int n = pow(10.0,n_digit);
	r=((float)((int)(r*n+0.5)))/n;

	return r;
}

__global__ 
void N_Body_kernel_P1(int i,int MaxNumCuerpos,float *masa_GPU,float *PosX_GPU,float *PosY_GPU,float *PosZ_GPU,
					float *VelX_GPU,float *VelY_GPU,float *VelZ_GPU,float *FueX_GPU,float *FueY_GPU,float *FueZ_GPU,
					float Pxi,float Pyi,float Pzi,float Mi){

	float Fx,Fy,Fz;
	float dx,dy,dz,dist2,dist,Fs,Fsdx,Fsdy,Fsdz;

	int tempX;
	int tempY;
	int tempZ;

	Fx=Fy=Fz=0;

	int j = blockIdx.x*blockDim.x+threadIdx.x;
	
	//CUPRINTF("j = %d  \n",j);
	
	if(j>=(i+1) && j<MaxNumCuerpos){

		dx=PosX_GPU[j] - Pxi;
		dy=PosY_GPU[j] - Pyi;
		dz=PosZ_GPU[j] - Pzi;

		dist2=(dx*dx) + (dy*dy) + (dz*dz);

		dist=sqrtf(dist2);

		Fs=(masa_GPU[j] * Mi)/(dist*dist2);

		Fsdx=Fs*dx;
		Fsdy=Fs*dy;
		Fsdz=Fs*dz;

		//atomicDec(&FueX_GPU[j], Fsdx);

		Fx=Fx+Fsdx;

		//atomicDec(&FueY_GPU[j], Fsdy);

		Fy=Fy+Fsdy;

		//atomicDec(&FueZ_GPU[j], Fsdz);

		Fz=Fz+Fsdz;
	}

	__syncthreads();

}

/*
__global__ 
void N_Body_kernel_P2(int MaxNumCuerpos, Cuerpo *l_CuerposGPU,float G,float dt,float T){

	float Gdtm;
	float Gdt=G*dt;
	float temp=0;

	int i = blockIdx.x*blockDim.x+threadIdx.x;

	if(i<MaxNumCuerpos){

		Gdtm=Gdt/l_CuerposGPU[i].masa;

		l_CuerposGPU[i].VelX=temp=l_CuerposGPU[i].VelX+l_CuerposGPU[i].FueX *Gdtm;
		l_CuerposGPU[i].PosX=l_CuerposGPU[i].PosX+temp*dt;
		l_CuerposGPU[i].VelY=temp=l_CuerposGPU[i].VelY+l_CuerposGPU[i].FueY *Gdtm;
		l_CuerposGPU[i].PosY=l_CuerposGPU[i].PosY+temp*dt;
		l_CuerposGPU[i].VelZ=temp=l_CuerposGPU[i].VelZ+l_CuerposGPU[i].FueZ *Gdtm;
		l_CuerposGPU[i].PosZ=l_CuerposGPU[i].PosZ+temp*dt;
		l_CuerposGPU[i].FueX=l_CuerposGPU[i].FueY=l_CuerposGPU[i].FueZ=0;

	}
}
*/


void Galaxia::calcN_Body(int i,int MaxNumCuerpos,float Pxi,float Pyi,float Pzi,float Mi){
	
	cout<<endl<<endl;
	
	for(int i=0; i<10; ++i){
		cout<<cuerpos.masa[i]<<" ";
		cout<<cuerpos.PosX[i]<<" ";
		cout<<cuerpos.VelX[i]<<" ";
		cout<<cuerpos.FueX[i]<<" ";
		cout<<endl;
	}
	cout<<endl<<endl;

	/////////////////////////////////////////////////

	int numThreads = 256;


	int Grid_Dim_x=MaxNumCuerpos;	//Grid structure values

	int Block_Dim_x=numThreads;	//Block structure values


	dim3 Grid = dim3( Grid_Dim_x*1.0/numThreads );		// ceil(Grid_Dim_y*1.0/numThreads) 

	dim3 Block = dim3(Block_Dim_x);	// Block_Dim_y


	//////////// Memoria en device //////////////////

	size_t size = MaxNumCuerpos*sizeof(float);

	cudaMalloc((void**)&masa_GPU, size);
	cudaMalloc((void**)&PosX_GPU, size);
	cudaMalloc((void**)&PosY_GPU, size);
	cudaMalloc((void**)&PosZ_GPU, size);
	cudaMalloc((void**)&VelX_GPU, size);
	cudaMalloc((void**)&VelY_GPU, size);
	cudaMalloc((void**)&VelZ_GPU, size);
	cudaMalloc((void**)&FueX_GPU, size);
	cudaMalloc((void**)&FueY_GPU, size);
	cudaMalloc((void**)&FueZ_GPU, size);

	//COPIAR A DEVICE

	cudaMemcpy(masa_GPU,cuerpos.masa,size,cudaMemcpyHostToDevice);
	cudaMemcpy(PosX_GPU,cuerpos.PosX,size,cudaMemcpyHostToDevice);
	cudaMemcpy(PosY_GPU,cuerpos.PosY,size,cudaMemcpyHostToDevice);
	cudaMemcpy(PosZ_GPU,cuerpos.PosZ,size,cudaMemcpyHostToDevice);
	cudaMemcpy(VelX_GPU,cuerpos.VelX,size,cudaMemcpyHostToDevice);
	cudaMemcpy(VelY_GPU,cuerpos.VelY,size,cudaMemcpyHostToDevice);
	cudaMemcpy(VelZ_GPU,cuerpos.VelZ,size,cudaMemcpyHostToDevice);
	cudaMemcpy(FueX_GPU,cuerpos.FueX,size,cudaMemcpyHostToDevice);
	cudaMemcpy(FueY_GPU,cuerpos.FueY,size,cudaMemcpyHostToDevice);
	cudaMemcpy(FueZ_GPU,cuerpos.FueZ,size,cudaMemcpyHostToDevice);


	N_Body_kernel_P1<<<Grid,Block>>>(i,MaxNumCuerpos,masa_GPU,PosX_GPU,PosY_GPU,PosZ_GPU,VelX_GPU,VelY_GPU,VelZ_GPU,FueX_GPU,FueY_GPU,FueZ_GPU,Pxi,Pyi,Pzi,Mi);

	cudaMemcpy(cuerpos.masa,masa_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.PosX,PosX_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.PosY,PosY_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.PosZ,PosZ_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.VelX,VelX_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.VelY,VelY_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.VelZ,VelZ_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.FueX,FueX_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.FueY,FueY_GPU,size,cudaMemcpyDeviceToHost);
	cudaMemcpy(cuerpos.FueZ,FueZ_GPU,size,cudaMemcpyDeviceToHost);

	cout<<endl<<endl;
	for(int i=0; i<10; ++i){
		cout<<cuerpos.masa[i]<<" ";
		cout<<cuerpos.PosX[i]<<" ";
		cout<<cuerpos.VelX[i]<<" ";
		cout<<cuerpos.FueX[i]<<" ";
		cout<<endl;
	}
	cout<<endl<<endl;
	
	cudaThreadSynchronize();
}


/*
void Galaxia::N_Body(){

	float G=0.00000000667;//cte gravitacional
	float dt=5; //tiempo por iteracion
	float T=10; //tiempo total
	
	float temp=0;
	float Pxi,Pyi,Pzi,Fx,Fy,Fz,Mi;
	float dx,dy,dz,dist2,dist,Fs,Fsdx,Fsdy,Fsdz,Gdtm;
	float Gdt=G*dt;

	float k=T/dt;

	//cout<<"Algoritmo N body"<<endl;

	int t=0,i;

	while(t<k){

		for(int i=0;i<MaxNumCuerpos;i++){

			Pxi=cuerpos.PosX[i];
			Pyi=cuerpos.PosY[i];
			Pzi=cuerpos.PosZ[i];
			
			Mi=cuerpos.masa[i];
		
			calcN_Body(i,MaxNumCuerpos,Pxi,Pyi,Pzi,Mi);

			cuerpos.FueX[i]+=Fx;
			cuerpos.FueY[i]+=Fy;
			cuerpos.FueZ[i]+=Fz;			
		}

		for(i=0; i<MaxNumCuerpos; ++i){

			Gdtm = Gdt/cuerpos.masa[i];

			cuerpos.VelX[i] = temp = cuerpos.VelX[i] + cuerpos.FueX[i] *Gdtm;
			cuerpos.PosX[i] = cuerpos.PosX[i] + temp*dt;

			cuerpos.VelY[i] = temp = cuerpos.VelY[i] + cuerpos.FueY[i] *Gdtm;
			cuerpos.PosY[i] = cuerpos.PosY[i] + temp*dt;

			cuerpos.VelZ[i] = temp = cuerpos.VelZ[i] + cuerpos.FueZ[i] *Gdtm;
			cuerpos.PosZ[i] = cuerpos.PosZ[i] + temp*dt;

			cuerpos.FueX[i] = cuerpos.FueY[i] = cuerpos.FueZ[i] = 0;
		}

		t++;
	}

}
*/


void Galaxia::N_Body(){

	float G=0.00000000667;//cte gravitacional
	float dt=5; //tiempo por iteracion
	float T=10; //tiempo total
	
	float temp=0;
	float Pxi,Pyi,Pzi,Fx,Fy,Fz,Mi;
	float dx,dy,dz,dist2,dist,Fs,Fsdx,Fsdy,Fsdz,Gdtm;
	float Gdt=G*dt;

	float k=T/dt;

	//cout<<"Algoritmo N body"<<endl;

	int t=0,i;

	MaxNumCuerpos = 8000;

	while(t<k){

		for(int i=0;i<MaxNumCuerpos;i++){

			Pxi=cuerpos.PosX[i];
			Pyi=cuerpos.PosY[i];
			Pzi=cuerpos.PosZ[i];
			
			Mi=cuerpos.masa[i];
		
			//calcN_Body(i,MaxNumCuerpos,Pxi,Pyi,Pzi,Mi);
			
			for (int j=i+1;j<MaxNumCuerpos;j++){
				dx=cuerpos.PosX[j]-Pxi;
				dy=cuerpos.PosY[j]-Pyi;
				dz=cuerpos.PosZ[j]-Pzi;

				dist2=(dx*dx) + (dy*dy) + (dz*dz);
				dist=sqrt(dist2);

				Fs=(cuerpos.masa[j]*Mi)/(dist*dist2);

				Fsdx=Fs*dx;
				Fsdy=Fs*dy;
				Fsdz=Fs*dz;

				cuerpos.FueX[j]=cuerpos.FueX[j]-Fsdx;
				Fx=Fx+Fsdx;
				cuerpos.FueY[j]=cuerpos.FueY[j]-Fsdy;
				Fy=Fy+Fsdy;
				cuerpos.FueZ[j]=cuerpos.FueZ[j]-Fsdz;
				Fz=Fz+Fsdz;
			}

			cuerpos.FueX[i]+=Fx;
			cuerpos.FueY[i]+=Fy;
			cuerpos.FueZ[i]+=Fz;			
		}

		for(i=0; i<MaxNumCuerpos; ++i){

			Gdtm = Gdt/cuerpos.masa[i];

			cuerpos.VelX[i] = temp = cuerpos.VelX[i] + cuerpos.FueX[i] *Gdtm;
			cuerpos.PosX[i] = cuerpos.PosX[i] + temp*dt;

			cuerpos.VelY[i] = temp = cuerpos.VelY[i] + cuerpos.FueY[i] *Gdtm;
			cuerpos.PosY[i] = cuerpos.PosY[i] + temp*dt;

			cuerpos.VelZ[i] = temp = cuerpos.VelZ[i] + cuerpos.FueZ[i] *Gdtm;
			cuerpos.PosZ[i] = cuerpos.PosZ[i] + temp*dt;

			cuerpos.FueX[i] = cuerpos.FueY[i] = cuerpos.FueZ[i] = 0;
		}

		t++;
	}

}



Galaxia::~Galaxia(){
}