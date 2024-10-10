/****************************************************/
/* Program ASCII - wyswietla rozszerzone kody ASCII */
/****************************************************/
#include <stdio.h>
#include "test.h"
unsigned char uc; // zmienna sterujaca petli
int fromASCII = 128, toASCII = 255; 
void main( void )
{ 
	printf("\n\n\nRozszerzone kody ASCII\n\n");
	for (uc = fromASCII; uc <= toASCII; uc1++)
	{
		printf("%3d:%2c", uc, uc);
	}
}
int x1 = fromASCII + 2 * ( 20 +  toASCII ); /* te linie /* sluza
* / wylacznie celom testowym ;-) */
double realTest = 12.34 + .56 + 78.;
*/ // nieotwarty komentarz
"Niezamknieta stala tekstowa
/* niezamkniety komentarz
