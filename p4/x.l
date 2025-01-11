%{
#include <stdio.h>
#include "defs.h"
#include "x.tab.h"

int instruction_beg = 0;
int comm_beg = 0;
%}

%option yylineno

identifier [a-zA-Z_][a-zA-Z0-9_]*

%x ST_COMMENT ST_PI ST_TAG
%%

"<!--" {comm_beg = yylineno; BEGIN(ST_COMMENT);};
<ST_COMMENT>[^-]"-->" BEGIN(INITIAL);
<ST_COMMENT>.|\n ;

"-->" {printf("Unexpected end of comment in line %d\n", comm_beg);};

"<?"{identifier} { instruction_beg = yylineno; strncpy(yylval.s, yytext + 2, MAX_STR_LEN); BEGIN(ST_PI); return PI_TAG_BEG; };

<ST_PI>.|\n ;

<ST_PI>"?>" {BEGIN(INITIAL); return PI_TAG_END;};

"<"{identifier} { instruction_beg = yylineno; strncpy(yylval.s, yytext + 1, MAX_STR_LEN); BEGIN(ST_TAG); return STAG_BEG; };

"</"{identifier} { instruction_beg = yylineno; strncpy(yylval.s, yytext + 2, MAX_STR_LEN); BEGIN(ST_TAG); return ETAG_BEG; };

<ST_TAG>">" {BEGIN(INITIAL); return TAG_END;};

<ST_TAG>. ;

<ST_TAG>"/>" {BEGIN(INITIAL); return ETAG_END;};

"&lt;" { strncpy(yylval.s, "<", MAX_STR_LEN); return CHAR; };
"&gt;" { strncpy(yylval.s, ">", MAX_STR_LEN); return CHAR; };
"&amp;" { strncpy(yylval.s, "&", MAX_STR_LEN); return CHAR; };
"&apos;" { strncpy(yylval.s, "'", MAX_STR_LEN); return CHAR; };
"&quot;" { strncpy(yylval.s, "\"", MAX_STR_LEN); return CHAR; };

^[ \t]+ ;
[ \t]+$ ;

[ \r\t]*\n[ \r\t] { return '\n'; };

\r ;

[ \t]+ { strncpy(yylval.s, yytext, MAX_STR_LEN); return S; };

. { strncpy(yylval.s, yytext, MAX_STR_LEN); return CHAR; };

[ \r\n\t] ; 

%%
int yywrap( void )
{
  if (YY_START == ST_COMMENT) {
    printf("Unfinished comment opened in line %d\n", comm_beg);
  }
  else if (YY_START == ST_PI) {
    printf("Unfinished processing instruction opened in line %d\n", comm_beg);
  }
  else if (YY_START == ST_TAG) {
    printf("Unfinished tag opened in line %d\n", comm_beg);
  }
  return 1;
}
