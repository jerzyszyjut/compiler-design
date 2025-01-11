%{
#include <stdio.h> 
#include <string.h>
#include "defs.h"

int level = 0;

int pos = 0;

const int INDENT_LENGTH = 2, LINE_WIDTH = 78;

void indent(void);

int was_character = 0, endline_inserted = 0;
void add_word(char *dest, char *src);
void yyerror(const char *txt);
int yylex();
%}
%union
{
   char s[MAX_STR_LEN + 1];
}

%token<s> PI_TAG_BEG PI_TAG_END STAG_BEG ETAG_BEG TAG_END ETAG_END CHAR S ATTRIBUTE

%type<s> start_tag end_tag word

%debug
%define parse.error verbose

%%

document: element
   | prolog element
   | error
   ;

prolog: processing_instruction_list;

processing_instruction_list: processing_instruction
   | processing_instruction_list processing_instruction
   ;

processing_instruction: processing_instruction_beg processing_instruction_rest
   ; 

processing_instruction_beg: PI_TAG_BEG {
   indent();
   printf("<?%s", $1);
   was_character = 0;
}

processing_instruction_rest: attribute_list PI_TAG_END {
   indent();
   printf("?>\n");
   was_character = 0;
}
   ;

element: empty_tag
   | tag_pair
   ;

empty_tag: STAG_BEG ETAG_END {
   indent();
   printf("<%s/>\n", $1);
   pos = 0;
   was_character = 0;
}
   ;

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

start_tag: start_tag_beg attribute_list start_tag_end {
   level++;
   pos = 0;
   was_character = 0;
}
   ;

start_tag_beg: STAG_BEG {
   indent();
   printf("<%s", $1);
}
   ;

start_tag_end: TAG_END
{
   printf(">\n");
}

attribute_list: attribute_list ATTRIBUTE { printf(" %s", $2); }
   | %empty
   ;

end_tag: ETAG_BEG TAG_END
   ;

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

