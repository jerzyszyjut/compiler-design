%{
#include <stdio.h> 
#include <string.h>
#include "defs.h"

const int INDENT_LENGTH = 2, LINE_WIDTH = 78;

int level = 0;
int pos = 0;
int was_character = 0, endline_inserted = 0;
char current_word[MAX_STR_LEN + 1];

void indent(void);
void add_char(char *dest, char *src);
void put_word();
void yyerror(const char *txt);
int yylex();
%}
%union
{
   char s[MAX_STR_LEN + 1];
}

%token<s> PI_TAG_BEG PI_TAG_END STAG_BEG ETAG_BEG TAG_END ETAG_END CHAR S ATTRIBUTE_NAME EQUAL_SIGN ATTRIBUTE_VALUE

%type<s> start_tag end_tag word attribute_list

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

processing_instruction: PI_TAG_BEG attribute_list PI_TAG_END {
   indent();
   printf("<?%s%s?>\n", $1, $2);
   was_character = 0;
}
   ; 

element: empty_tag
   | tag_pair
   ;

empty_tag: STAG_BEG attribute_list ETAG_END {
   indent();
   printf("<%s%s/>\n", $1, $2);
   pos = 0;
   was_character = 0;
}
   ;

tag_pair: start_tag content end_tag {
   if (strcmp($1, $3) != 0) {
      yyerror("Start and end tags do not match");
   }

   if (strlen(current_word) > 0) {
      put_word();
   }

   level--;
   indent();
   printf("</%s>\n", $3);
   pos = 0;
   was_character = 0;
}
   ;

start_tag: STAG_BEG attribute_list TAG_END {
   indent();
   printf("<%s%s>\n", $1, $2);
   level++;
   pos = 0;
   was_character = 0;
}
   ;

attribute_list: attribute_list ATTRIBUTE_NAME EQUAL_SIGN ATTRIBUTE_VALUE { 
   strncat($$, " ", MAX_STR_LEN);
   strncat($$, $2, MAX_STR_LEN);
   strncat($$, "=", MAX_STR_LEN);
   strncat($$, $4, MAX_STR_LEN);
}
   | %empty { $$[0] = '\0'; }
   ;

end_tag: ETAG_BEG TAG_END
   ;

content: content element
   | word
   | %empty
   ;

word: CHAR { add_char($$, $1); }
   | S { add_char($$, $1); }
   | word CHAR { add_char($$, $2); }
   | word S { add_char($$, $2); }
   | word '\n'{ add_char($$, "\n"); }
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
   for (int i = 0; i < level * INDENT_LENGTH; i++) {
      printf(" ");
      pos++;
   }
}

void add_char(char *dest, char *src)
{
   if (strlen(current_word) + strlen(src) >= LINE_WIDTH) {
      put_word();
      indent();
   }
   strncat(current_word, src, MAX_STR_LEN);
   was_character = 1;
   pos += strlen(src);
   if (pos >= LINE_WIDTH) {
      put_word();
      indent();
   }	
}

void put_word()
{
   printf("%s", current_word);
   current_word[0] = '\0';
}

void yyerror( const char *txt )
{
	printf( "\nSyntax error %s\n", txt );
}

