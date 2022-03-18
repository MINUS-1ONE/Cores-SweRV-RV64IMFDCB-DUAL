#include <stdint.h>
#include <stdlib.h>
// #include <stdio.h>
#include "printf.h"
#include <string.h>
#include <math.h>

// #define printf whisperPrintf

/* map the FORTRAN math functions, etc. to the C versions */
#define DSIN    sinf
#define DCOS    cosf
#define DATAN   atanf
#define DLOG    logf
#define DEXP    expf
#define DSQRT   sqrtf
#define IF      if

#define CORE_FREQ_IN_MHZ (50)
#define USECS_PER_SEC (1000000)
#define EE_TICKS_PER_SEC (CORE_FREQ_IN_MHZ*USECS_PER_SEC)

#define ITERATIONS 1

/* function prototypes */
void POUT(float X4);
void PA(float E[]);
void P0(void);
void P3(float X, float Y, float *Z);
#define USAGE   "usage: whetdc [-c] [loops]\n"

// #define PRINTOUT 1

uint32_t time_in_secs(uint64_t ticks);

uint64_t get_timer_value(void) {
    uint64_t cycles;
    asm volatile ("csrr %0,mcycle"   : "=r" (cycles)  );

    return cycles;
}

/*
    COMMON T,T1,T2,E1(4),J,K,L
*/
float T,T1,T2,E1[5];
int J,K,L;
int argc = 0;   //Mod for nucleo. Change in code below if you want non-default loop count

//************************************
//**    Whetstone    32b-SP         **
//**        SUB                     **
//************************************
int Whetstone() // ------------ Metoda -----------
{
    printf("Beginning Whetstone benchmark at : \n");
    
    /* used in the FORTRAN version */
    long I;
    long N1, N2, N3, N4, N6, N7, N8, N9, N10, N11;
    float X1,X2,X3,X4,X,Y,Z;
    long LOOP;
    int II, JJ;

    /* added for this version */
    long loopstart = 0;
    uint64_t startsec,finisec = 0;

    uint64_t total_ticks;

    float KIPS;
    int continuous;

    loopstart = ITERATIONS;       /* 1000 see the note about LOOP below */
    continuous = 0;

    II = 1;     /* start at the first arg (temp use of II here) */
 
LCONT:
/*
********************************************
*   Start benchmark timing at this point.
********************************************
*/
    startsec = 0;
    finisec = 0;
    startsec = get_timer_value();

/*
********************************************
*   The actual benchmark starts here.
********************************************
*/
    T  = .499975;
    T1 = 0.50025;
    T2 = 2.0;
/*
********************************************
*   With loopcount LOOP=10, one million Whetstone instructions
*   will be executed in EACH MAJOR LOOP..A MAJOR LOOP IS EXECUTED
*   'II' TIMES TO INCREASE WALL-CLOCK TIMING ACCURACY.
*
*   LOOP = 1000;
*/
    LOOP = loopstart;
    II   = 1;
    JJ = 1;

IILOOP:
    N1  = 0;
    N2  = 12 * LOOP;
    N3  = 14 * LOOP;
    N4  = 345 * LOOP;
    N6  = 210 * LOOP;
    N7  = 32 * LOOP;
    N8  = 899 * LOOP;
    N9  = 616 * LOOP;
    N10 = 0;
    N11 = 93 * LOOP;
/*
********************************************
*   Module 1: Simple identifiers  OMMIT
********************************************
*/
    X1  =  1.0;
    X2  = -1.0;
    X3  = -1.0;
    X4  = -1.0;

    for (I = 1; I <= N1; I++)
    {
        X1 = (X1 + X2 + X3 - X4) * T;
        X2 = (X1 + X2 - X3 + X4) * T;
        X3 = (X1 - X2 + X3 + X4) * T;
        X4 = (-X1+ X2 + X3 + X4) * T;
    }

/*
********************************************
*   Module 2: Array elements
********************************************
*/
    E1[1] =  1.0;
    E1[2] = -1.0;
    E1[3] = -1.0;
    E1[4] = -1.0;

    for (I = 1; I <= N2; I++)
    {
        E1[1] = ( E1[1] + E1[2] + E1[3] - E1[4]) * T;
        E1[2] = ( E1[1] + E1[2] - E1[3] + E1[4]) * T;
        E1[3] = ( E1[1] - E1[2] + E1[3] + E1[4]) * T;
        E1[4] = (-E1[1] + E1[2] + E1[3] + E1[4]) * T;
    }

#ifdef PRINTOUT
    IF (JJ==II) POUT(E1[4]);
#endif

/*
********************************************
*  Module 3: Array as parameter
********************************************
*/
    for (I = 1; I <= N3; I++)
    {
        PA(E1);
    }
#ifdef PRINTOUT
    IF (JJ==II) POUT(E1[4]);
#endif

/*
********************************************
*   Module 4: Conditional jumps
********************************************
*/
    J = 1;
    for (I = 1; I <= N4; I++)
    {
        if (J == 1)
            J = 2;
        else
            J = 3;

        if (J > 2)
            J = 0;
        else
            J = 1;

        if (J < 1)
            J = 1;
        else
            J = 0;
    }

#ifdef PRINTOUT
    IF (JJ==II) POUT(J);
#endif

/*
********************************************
*   Module 5: Omitted
*   Module 6: Integer arithmetic
********************************************
*/

    J = 1;
    K = 2;
    L = 3;

    for (I = 1; I <= N6; I++)
    {
        J = J * (K-J) * (L-K);
        K = L * K - (L-J) * K;
        L = (L-K) * (K+J);
        E1[L-1] = J + K + L;
        E1[K-1] = J * K * L;
    }

    // only for result print
    float sum;
    sum = E1[1]+E1[2];

#ifdef PRINTOUT
    IF (JJ==II) POUT(sum);
#endif

/*
********************************************
*   Module 7: Trigonometric functions
********************************************
*/
    X = 0.5;
    Y = 0.5;

    for (I = 1; I <= N7; I++)
    {
        X = T * DATAN(T2*DSIN(X)*DCOS(X)/(DCOS(X+Y)+DCOS(X-Y)-1.0));
        Y = T * DATAN(T2*DSIN(Y)*DCOS(Y)/(DCOS(X+Y)+DCOS(X-Y)-1.0));
    }

#ifdef PRINTOUT
    IF (JJ==II)POUT(Y);
#endif

/*
********************************************
*   Module 8: Procedure calls
********************************************
*/
    X = 1.0;
    Y = 1.0;
    Z = 1.0;

    for (I = 1; I <= N8; I++)
    {
        P3(X,Y,&Z);
    }
#ifdef PRINTOUT
    IF (JJ==II)POUT(Z);
#endif

/*
********************************************
*   Module 9: Array references
********************************************
*/
    J = 1;
    K = 2;
    L = 3;
    E1[1] = 1.0;
    E1[2] = 2.0;
    E1[3] = 3.0;

    for (I = 1; I <= N9; I++)
    {
        P0();
    }
#ifdef PRINTOUT
    IF (JJ==II) POUT(E1[3]);
#endif

/*
********************************************
*   Module 10: Integer arithmetic
********************************************
*/
    J = 2;
    K = 3;

    for (I = 1; I <= N10; I++)
    {
        J = J + K;
        K = J + K;
        J = K - J;
        K = K - J - J;
    }
/*
********************************************
*   Module 11: Standard functions
********************************************
*/
    X = 0.75;

    for (I = 1; I <= N11; I++)
    {
        X = DSQRT(DEXP(DLOG(X)/T1));
    }
#ifdef PRINTOUT
    IF (JJ==II) POUT(X);
#endif

/*
********************************************
*      THIS IS THE END OF THE MAJOR LOOP.
********************************************
*/
    if (++JJ <= II)
        goto IILOOP;

/*
********************************************
*      Stop benchmark timing at this point.
********************************************
*/
   // finisec = time(0);
    finisec = get_timer_value();
    //timer.reset();

    printf(" start cycle: %llu \n", startsec);
    printf(" finish cycle : %llu \n", finisec);

    total_ticks = finisec - startsec;

    printf(" total_ticks : %llu \n", total_ticks);

/*
*--------------------------------------------------------------------
*      Performance in Whetstone KIP's per second is given by
*
*   (100*LOOP*II)/TIME
*
*      where TIME is in seconds.
*--------------------------------------------------------------------
*/
    // printf(" kraj \n");

    uint32_t vreme;
    // vreme = time_in_secs(finisec - startsec);
    vreme = time_in_secs(total_ticks);
    
    if (vreme <= 0)
     {
        printf("Insufficient duration- Increase the LOOP count \n");
        finisec = 0; 
        startsec = 0;
        return 1;
     }

    printf("Loops: %d , \t Iterations: %d, \t Duration: %d sec. \n",
            LOOP, II, vreme);

    KIPS = (100.0 * LOOP * II) / vreme ;
   
  //  if (KIPS >= 1000.0)
  //      printf("C Converted float Precision Whetstones: %.3f MIPS \n\n", KIPS / 1000);
  //  else
  //      printf("C Converted float Precision Whetstones: %.3f KIPS \n\n", KIPS);
    
    // print float result
    float res;
    int int_part;
    int fract_part;

    res = KIPS / 1000;

    int_part = (int)res;
    fract_part = (int)((res - int_part)*1000);
        
    printf("C Converted float Precision Whetstones: %d.%03d MIPS \n", int_part, fract_part);

    if (continuous)
        goto LCONT;

    finisec = 0; 
    startsec = 0;
    return 1;
}

void PA(float E[])
{
    J = 0;

L10:
    E[1] = ( E[1] + E[2] + E[3] - E[4]) * T;
    E[2] = ( E[1] + E[2] - E[3] + E[4]) * T;
    E[3] = ( E[1] - E[2] + E[3] + E[4]) * T;
    E[4] = (-E[1] + E[2] + E[3] + E[4]) / T2;
    J += 1;

    if (J < 6)
        goto L10;
}

void P0(void)
{
    E1[J] = E1[K];
    E1[K] = E1[L];
    E1[L] = E1[J];
}

void P3(float X, float Y, float *Z)
{
    float X1, Y1;

    X1 = X;
    Y1 = Y;
    X1 = T * (X1 + Y1);
    Y1 = T * (X1 + Y1);
    *Z  = (X1 + Y1) / T2;
}

uint32_t time_in_secs(uint64_t ticks)
{
  return (uint32_t)(ticks / EE_TICKS_PER_SEC);
}


#ifdef PRINTOUT
void POUT(float X4)
{
    printf("%12.5f\n",X4);
}
#endif   


//*********************************
//**         MAIN block          **
//*********************************
int main()
{
    printf("\n My Benchmark example for Whetstones \n");

    Whetstone(); //Call of Whetstone banchmark methode

}