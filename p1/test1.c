/****************************************************/
/* Program ASCII - wyswietla rozszerzone kody ASCII */
/****************************************************/
#include <stdio.h>
#include "test.h"
unsigned char uc; // zmienna sterujaca petli typu char
int fromASCII = 128, toASCII = 255;
long int x[10];
void main( void )
{
  struct data {
    int	rok;
    int miesiac;
    int dzien;
  };
  data poczatek, koniec;
  int i;
  printf( "Rozszerzone kody ASCII\n\n");
  for ( uc = fromASCII; uc <= toASCII; uc1++ ) {
    printf( "%3d:%2c", uc, uc ); printf("\n");
  }
  int x1 = fromASCII + 2 * ( 20 +  toASCII );  /* int */
  double realTest = 12.34e-12 + .56 + 78.; /* double */
  x[0] = 1;
  for (i = 1; i < 10; i++) {
    x[i] = x[i-1] * i * i;
  }
  poczatek.rok = 2018;
  poczatek.miesiac = 10;
  poczatek.dzien = 1;
}
