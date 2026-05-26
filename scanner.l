%{
#include <stdio.h>
#include <string.h>

int lineNumber = 1;

%}

DIGIT      [0-9]
LETTER     [a-zA-Z_]
ID         {LETTER}({LETTER}|{DIGIT})*

%%

"//".*                 { /* Ignorar comentarios */ }

"#include"             { return INCLUDE; }
"#define"              { return DEFINE; }

"int"                  { return INT; }
"func"                 { return FUNC; }
"return"               { return RETURN; }
"if"                   { return IF; }

"+"                    { return PLUS; }
"-"                    { return MINUS; }
"*"                    { return MULT; }
"/"                    { return DIV; }

"("                    { return LPAREN; }
")"                    { return RPAREN; }

"{"                    { return LBRACE; }
"}"                    { return RBRACE; }

";"                    { return SEMICOLON; }
","                    { return COMMA; }

"="                    { return ASSIGN; }

{DIGIT}+               {
                            yylval.intValue = atoi(yytext);
                            return NUMBER;
                       }

{ID}                   {
                            yylval.stringValue = strdup(yytext);
                            return IDENTIFIER;
                       }

[ \t\r]+               { }

\n                     { lineNumber++; }

.                      {
                            printf("Error léxico línea %d: %s\n", lineNumber, yytext);
                       }

%%

int yywrap() {
    return 1;
}
