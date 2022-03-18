#include <stdint.h>
#include "printf.h"
#include <stdlib.h>
#include <math.h>

// #define printf whisperPrintf

void print_float(double num) {

    int int_part;
    int fract_part;

    int_part = (int)num;
    fract_part = (int)((num - int_part)*1000);

    printf("float_num: %d.%02d \n", int_part, fract_part);
    // printf("float_num: %lf \n", num);
}

int main() {

    float frs1_s, frs2_s, frs3_s, frd_s;
    double frs1_d, frs2_d, frs3_d, frd_d;

    a = 1.57;
    b = 6.22;
    c = a + b;

    d = sin(a);
    
    printf("add result :");
    print_float(c); 

    printf("sin result :");
    print_float(d); 

    return 0;
}


