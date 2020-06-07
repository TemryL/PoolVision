/*******************************************************
Name of c-file ......... : Pix2Pos.c
Name of executable ..... : Pix2Pos.exe

Authors...... : MERY Tom, LELIEVRE Maxime
Version ..... : 05/06/2020

Role ........ : Open and read Pixmap.bin (on current folder) to find coordinates of the three balls. 
                Create Pos.txt (on current folder) containing Top-Left coordinates of each balls.

Built and compiled on Visual Studio Code
Compilation : gcc -Wall Pix2Pos.c -o Pix2Pos -lm
********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

struct Pixel{           // contains all the information of a pixel 
    unsigned int RR;    // take value in range [0,255] for Red
    unsigned int GG;    // take value in range [0,255] for Green
    unsigned int BB;    // take value in range [0,255] for Blue
    int Red;            // =1 if Pixel (0x00RRGGBB) is in range of colors of the Red ball, else =0
    int Yellow;         // =1 if Pixel (0x00RRGGBB) is in range of colors of the Yellow ball, else =0
    int White;          // =1 if Pixel (0x00RRGGBB) is in range of colors of the White ball, else =0
    int BlueBG;         // =1 if Pixel (0x00RRGGBB) is in range of colors of the Blue Background, else =0
};

struct Balls{           // contains coordinates of three balls
    int RedBall[2];     // Top-Left coordinates of Red ball ===> [0]=Left coordinate, [1]=Top coordinate
    int YellowBall[2];  // Top-Left coordinates of Yellow ball ===> [0]=Left coordinate, [1]=Top coordinate
    int WhiteBall[2];   // Top-Left coordinates of White ball ===> [0]=Left coordinate, [1]=Top coordinate
};

/**
Command_Check
Test the validity of the parameters passed on the command line.
Input :     -argc : number of parameters
            -arg[] : parameters
Return :    -Command_check()=1 if everything is ok
            -Command_Check()=0 if there is a problem in the parameters, stderr contains the error
*/
int Command_Check(int argc, int arg[]){
    if (argc<30){
        fprintf(stderr,"Error : Not enough parameters on command line");
        return 0;
    }
    if (argc>30){
        fprintf(stderr,"Error : Too many parameters on command line");
        return 0;
    }
    if((arg[29]<5)||(arg[29]>20)){
        fprintf(stderr,"Error : Diameter of balls outside range [5..20]");
        return 0;
        }
    return 1;
}

/**
Range_Test
Test if a Pixel is in a given range of colors
Input :     -(Rmin, Rmax, Gmin, Gmax, Bmin, Bmax) : given range of colors
            -x : variable of type struct Pixel containing the informations of the pixel
Return :    -Range_Test()=1 if the Pixel x is in the given range of colors
            -Range_Test()=0 if not
*/
int Range_Test(int Rmin,int Rmax,int Gmin,int Gmax,int Bmin,int Bmax,struct Pixel x){
    return (Rmin<=x.RR)&&(x.RR<=Rmax)&&(Gmin<=x.GG)&&(x.GG<=Gmax)&&(Bmin<=x.BB)&&(x.BB<=Bmax);
}

/**
Data_Access
Separates the RGB components of each pixels and fulfilled an array of struct Pixel as described above 
(see definition of struct Pixel) 
Input :     -W : width of the image coded in Pixmap.bin
            -H : height of the image coded in Pixmap.bin
            -PM[] : array of unsigned int (format 0x00RRGGBB)  
Output :    -x[] :  array of variables of type struct Pixel containing the informations of each pixels
                    as described above (see definition of struct Pixel)
*/
void Data_Access(unsigned int W, unsigned int H, unsigned int *PM,int arg[],struct Pixel *x){

    for(int i=0;i<W*H;i++){
        x[i].RR=(PM[i]&0xFF0000)>>16;
        x[i].GG=(PM[i]&0x00FF00)>>8;
        x[i].BB=(PM[i]&0x0000FF);
        x[i].Red=0;
        x[i].Yellow=0;
        x[i].White=0;
        x[i].BlueBG=0;
        if(Range_Test(arg[5],arg[6],arg[7],arg[8],arg[9],arg[10],x[i])) x[i].Red=1; 
        if(Range_Test(arg[11],arg[12],arg[13],arg[14],arg[15],arg[16],x[i])) x[i].Yellow=1;
        if(Range_Test(arg[17],arg[18],arg[19],arg[20],arg[21],arg[22],x[i])) x[i].White=1;
        if(Range_Test(arg[23],arg[24],arg[25],arg[26],arg[27],arg[28],x[i])) x[i].BlueBG=1;
    }
    free(PM);
}

/**
Superposition_Check
Test if the balls are superposed
Input :     -b : coordinates of balls (see definition of struct Balls above)
Return :    -Superposition_Check()=0 if any balls are superposed
            -Superposition_Check()=1 if Red Ball and Yellow Ball are superposed
            -Superposition_Check()=2 if Red Ball and White Ball are superposed
            -Superposition_Check()=3 if White Ball and Yellow Ball are superposed
Comments :  In case where the three balls are superposed, Superposition_Check return 1. 
            The superposition error is managed in the same way for the different cases.
*/
int Superposition_Check(struct Balls b){
    if((abs(b.RedBall[0]-b.YellowBall[0])<11)&&(abs(b.RedBall[1]-b.YellowBall[1])<11)) return 1;
    if((abs(b.RedBall[0]-b.WhiteBall[0])<11)&&(abs(b.RedBall[1]-b.WhiteBall[1])<11)) return 2;
    if((abs(b.WhiteBall[0]-b.YellowBall[0])<11)&&(abs(b.WhiteBall[1]-b.YellowBall[1])<11)) return 3;
    return 0;
}

/**
Ball_Search
Search the coordinates of balls, stocks them in local variable b (type struct Balls), check if some balls are missing,
open or create Pos.txt and print the coordinates into Pos.txt and finally check if some balls are superposed.
Input :     -W : width of the image coded in Pixmap.bin
            -H : height of the image coded in Pixmap.bin
            -arg[] : 29 parameters 
            -x[] :  array of variables of type struct Pixel containing the informations of each pixels
                    as described above (see definition of struct Pixel)
Output :    - Create Pos.txt (on current folder) containing Top-Left coordinates of each balls
Comments :  A more detailed description of the search algorithm is available in the pdf documentation.
            The exit values and associated errors are specified in the pdf documentation.
*/
void Ball_Search(unsigned int W,unsigned int H,int arg[],struct Pixel x[]){

    int score_Red=0;
    int score_Yellow=0;
    int score_White=0;
    int Red, Yellow, White;
    struct Balls b;

// Search algorithm
    for(int i=arg[1];i<=arg[2]-11;i++){
        for(int j=arg[3];j<=arg[4]-11;j++){
            Red=0;
            Yellow=0;
            White=0;
            if(x[W*(i+5)+j+5].BlueBG) continue; //optimisation
            for(int k=0;k<=10;k++){
                for(int l=0;l<=10;l++){
                    Red += x[W*(i+l)+j+k].Red;
                    Yellow += x[W*(i+l)+j+k].Yellow;
                    White += x[W*(i+l)+j+k].White;
                }   
            }
            if(score_Red<Red){
                score_Red=Red;
                b.RedBall[0]=j;
                b.RedBall[1]=i;
            }
            if(score_Yellow<Yellow){
                score_Yellow=Yellow;
                b.YellowBall[0]=j;
                b.YellowBall[1]=i;
            }
            if(score_White<White){
                score_White=White;
                b.WhiteBall[0]=j;
                b.WhiteBall[1]=i;
            }
        }
    }
    
    // Check if a ball is missing
    if(score_Red==0||score_Yellow==0||score_White==0){
        fprintf(stderr,"Error : Not enough balls :\n");
        if(score_Red==0) fprintf(stderr,"-Missing Red Ball\n");
        if(score_Yellow==0) fprintf(stderr,"-Missing Yellow Ball\n");
        if(score_White==0) fprintf(stderr,"-Missing White Ball\n");
        free(arg);free(x);
        exit(5001);
    }

    // Create (or open if it already exists) Pos.txt and write the coordinates of balls inside 
    FILE* Pos=fopen("Pos.txt","w+");
    if(Pos==NULL){
        perror("Error when open Pos.txt in writting ");
        free(arg);free(x);
        exit(5002);
    }
    size_t print_check=fprintf(Pos,"Red: %d, %d, %d\nYellow: %d, %d, %d\nWhite: %d, %d, %d\n",b.RedBall[0],b.RedBall[1],score_Red,b.YellowBall[0],b.YellowBall[1],score_Yellow,b.WhiteBall[0],b.WhiteBall[1],score_White);
    if(print_check<0){
        perror("Error when write in Pos.txt ");
        free(arg);free(x);
        exit(5003);
    }
    if(fclose(Pos)){
        perror("Error when close Pos.txt "); 
        exit(5013);
    }
    
    // Call Superposition_Check and print the error associated with the return values of Superpostion_Check in stderr
    if(Superposition_Check(b)){
        switch(Superposition_Check(b)){
            case 1:
            fprintf(stderr,"Error : Red ball and Yellow ball superposed ");
            break;
            case 2:
            fprintf(stderr,"Error : Red ball and White ball superposed ");
            break;
            case 3:
            fprintf(stderr,"Error : White ball and Yellow ball superposed ");
            break;
        }
        free(arg);free(x);
        exit(5004);
    }
}

/**
Main
Allocate all necessary memory, call Command_Check, open and read in Pixmap.bin to obtain the width, the height and 
information of each pixel (format 0x00RRGGBB) of the image, call Data_Access and call Ball_Search
Input :     -argc : width of the image coded in Pixmap.bin
            -*argv[] : height of the image coded in Pixmap.bin
Return :    -main()=0 if everything is ok
            -main()!=0 if there is an error, stderr contains the error
Comments :  All return values and associated errors are specified in the pdf documentation.
*/
int main (int argc, char *argv[]){
    
    // Memory allocation of the array containing all parameters passed on command line and stock them in arg[]
    int *arg=malloc(argc*sizeof(int));           
    if(arg==NULL){
        perror("Memory allocation error ");
        return 5005;
    }
    for(int i=1;i<argc;i++){
        arg[i]=atoi(argv[i]);
    }

    // Call Command_Check
    if(!(Command_Check(argc,arg))){
        free(arg);
        return 5006;
    }

    // Initialisation of W and H
    unsigned int W = 0;
    unsigned int H = 0;

    // Open Pixmap.bin
    FILE* Pixmap=fopen("Pixmap.bin","rb");  
    if(Pixmap==NULL){
        perror("Error when open Pixmap.bin in reading ");
        free(arg);
        return 5007;
    }

    // Read and stock the width of image in W 
    size_t read_check_W=fread(&W,sizeof(unsigned int),1,Pixmap);
    if(read_check_W!=1){
        perror("Error when read width in Pixmap.bin ");
        free(arg);
        if(fclose(Pixmap)){
            perror("Error when close Pixmap.bin "); 
            return 5012;
            }
        return 5008;
    }

    // Read and stock the height of image in H 
    size_t read_check_H=fread(&H,sizeof(unsigned int),1,Pixmap);
    if(read_check_H!=1){
        perror("Error when read height in Pixmap.bin ");
        free(arg);
        if(fclose(Pixmap)){
            perror("Error when close Pixmap.bin "); 
            return 5012;
            }
        return 5008;
    }

    // Check the validity of width and height of the image
    if(W<10||W>1000||H<10||H>1000){
        fprintf(stderr,"Error : Width and/or height outside range [10..1000] : ");
        if(W<10) fprintf(stderr,"Not enough wide");
        if(H<10) fprintf(stderr,"Not enough high");
        if(W>1000) fprintf(stderr,"Too wide");
        if(H>1000) fprintf(stderr,"Too high");
        free(arg);
        if(fclose(Pixmap)){
            perror("Error when close Pixmap.bin "); 
            return 5012;
            }
        return 5009;
    }

    // Memory allocation of the array containing the informations of each pixel (format 0x00RRGGBB)
    unsigned int *PM=malloc(W*H*sizeof(unsigned int));
    if(PM==NULL){
        perror("Memory allocation error ");
        free(arg);
        if(fclose(Pixmap)){
            perror("Error when close Pixmap.bin "); 
            return 5012;
            }
        return 5005;
    }

    // Read and stock the informations of each pixel (format 0x00RRGGBB) in array of unsigned int PM[]
    unsigned int number_of_pixel=fread(PM,sizeof(unsigned int),W*H+1,Pixmap);

    // Check if there are too much or not enough pixel
    if(number_of_pixel<W*H){
        fprintf(stderr,"Error : Not enough pixels (%d missing pixels)",W*H-number_of_pixel);
        free(arg);free(PM);
        if(fclose(Pixmap)){
            perror("Error when close Pixmap.bin "); 
            return 5012;
            }
        return 5010;
    };
    if(number_of_pixel>W*H){
        fprintf(stderr,"Warning : Too many pixels : END OF PROGRAM");
        free(arg);free(PM);
        if(fclose(Pixmap)){
            perror("Error when close Pixmap.bin "); 
            return 5012;
            }
        return 5011;
    };

    if(fclose(Pixmap)){
        perror("Error when close Pixmap.bin "); 
        return 5012;
        }

    // Memory allocation of an array of variables of type struct Pixel 
    struct Pixel *Pixel=malloc(W*H*sizeof(struct Pixel));
    if(Pixel==NULL){
        perror("Memory allocation error ");
        free(arg);free(PM);
        return 5005;
    }

    // Call Data_Access and Ball_Search
    Data_Access(W,H,PM,arg,Pixel);
    Ball_Search(W,H,arg,Pixel);

    free(arg);free(Pixel);
    return 0;
}

