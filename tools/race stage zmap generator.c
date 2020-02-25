/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

#include <stdio.h>
#include <stdlib.h>

int main()
{
// create list    
    const float H_RESOLUTION = 192;
    const float Y_WORLD   =   -256;
   
    float Z[256];
    float Y_screen = 96;

    for ( int i = 0; i < (H_RESOLUTION * 2) ; i ++)
        {
            
            float a = Y_screen - (H_RESOLUTION / 2);
            if (a == 0) { a = 1; }    // prevent divide by 0
            Z[i] = 0 - ( Y_WORLD / a )*16;
            Y_screen ++;
        }
// print list   
    const int NUM_PER_ROW   =   16;   
    const int NUM_ROWS      =   sizeof(Z) / NUM_PER_ROW;


    int arraypos = 1;    

        printf("Z_map:\n");
   
        for (int j = 0; j < NUM_ROWS; j++)
            {
                printf("    dc.w    ");
            
                for (int k = 0; k < NUM_PER_ROW; k++)
                    {
                        printf("%.0f", Z[arraypos]);
                        arraypos ++;
                        if (k < (NUM_PER_ROW - 1)) printf(", ");
                    }
                    
                printf("\n");   
            
            }

/*          
// write file
    FILE * fptr;                           // file pointer
    fptr = fopen(".\\zmap.bin","wb");     // open file in write binary mode

    if (fptr == NULL)
    {
        printf("Error opening file");
        exit(1);
    }

    fwrite(Z, sizeof(Z), 1, fptr);      // write array to file
    fclose(fptr);                       // close file
*/
    return 0;
}


