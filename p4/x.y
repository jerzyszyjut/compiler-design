%{
// 3.1.1
#include <stdio.h> 
#include <string.h>
#include "defs.h"

// 3.1.2
int level = 0;

// 3.1.3
int pos = 0;

// 3.1.4
const int INDENT_LENGTH = 2, LINE_WIDTH = 78;

// 3.1.5
void indent(void);

int was_character = 0, endline_inserted = 0;
void add_word(char *dest, char *src);
void yyerror(const char *txt);
int yylex();
%}
// 3.1.6
%union
{
   char s[MAX_STR_LEN + 1];
}

// 3.1.7
%token<s> PI_TAG_BEG PI_TAG_END STAG_BEG ETAG_BEG TAG_END ETAG_END CHAR S

// 3.1.8
%type<s> start_tag end_tag word

%debug
%define parse.error verbose

%%

// 3.2.1
document: element
   | prolog element
   | error
   ;

// 3.2.2
prolog: processing_instruction_list;

processing_instruction_list: processing_instruction
   | processing_instruction_list processing_instruction
   ;

// 3.2.3
processing_instruction: PI_TAG_BEG PI_TAG_END {
   indent();
   printf("<?%s?>\n", $1);
   was_character = 0;
}
   ;

// 3.2.4
element: empty_tag
   | tag_pair
   ;

// 3.2.5
empty_tag: STAG_BEG ETAG_END {
   indent();
   printf("<%s/>\n", $1);
   pos = 0;
   was_character = 0;
}
   ;

// 3.2.6
tag_pair: start_tag content end_tag {
   if (strcmp($1, $3) != 0) {
      yyerror("Start and end tags do not match");
   }

   level--;
   indent();
   printf("</%s>\n", $3);
   pos = 0;
   was_character = 0;
}
   ;

// 3.2.7
start_tag: STAG_BEG TAG_END {
   indent();
   printf("<%s>\n", $1);
   level++;
   pos = 0;
   was_character = 0;
}
   ;

// 3.2.8
end_tag: ETAG_BEG TAG_END
   ;

// 3.2.9
content: element
   | word
   | content element
   | content word
   | content '\n' 
   | %empty
   ;

word: CHAR { add_word($$, $1); }
   | S { add_word($$, $1); }
   | word CHAR { add_word($$, $2); }
   | word S { add_word($$, $2); }
   | word '\n'{ add_word($$, "\n"); }
   ;

%%


int main( void )
{
	return yyparse();
}

void indent(void)
{
   if (was_character) {
      printf("\n");
      pos = 0;
   }
   int i;
   for (i = 0; i < level * INDENT_LENGTH; i++) {
      printf(" ");
      pos++;
   }
}

void add_word(char *dest, char *src)
{
   if ( pos == 0 ) {
		indent();
	}

	printf("%s", src);
	pos++;

   was_character = 1;
   
   if (pos == LINE_WIDTH) {
		pos = 0;
	}
   else if (src[0] == '\n') {
		pos = 0;
      was_character = 0;
	}	
}

void yyerror( const char *txt )
{
	printf( "\nSyntax error %s\n", txt );
}

