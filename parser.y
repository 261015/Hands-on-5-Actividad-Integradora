%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int lineNumber;

int yylex();
void yyerror(const char *s);

typedef struct Symbol {

    char nombre[50];
    char clase[20];
    char tipo[20];
    int ambito;
    int aridad;
    int usado;

} Symbol;

Symbol tabla[100];

int symbolCount = 0;

void insertarSimbolo(
    char *nombre,
    char *clase,
    char *tipo,
    int ambito,
    int aridad
) {

    for(int i=0; i<symbolCount; i++) {

        if(strcmp(tabla[i].nombre, nombre) == 0 &&
           tabla[i].ambito == ambito) {

            printf("Error semántico línea %d: '%s' redeclarado\n",
                   lineNumber, nombre);

            return;
        }
    }

    strcpy(tabla[symbolCount].nombre, nombre);
    strcpy(tabla[symbolCount].clase, clase);
    strcpy(tabla[symbolCount].tipo, tipo);

    tabla[symbolCount].ambito = ambito;
    tabla[symbolCount].aridad = aridad;
    tabla[symbolCount].usado = 0;

    symbolCount++;
}

int buscarSimbolo(char *nombre) {

    for(int i=symbolCount-1; i>=0; i--) {

        if(strcmp(tabla[i].nombre, nombre) == 0) {
            return i;
        }
    }

    return -1;
}

void marcarUsado(char *nombre) {

    int pos = buscarSimbolo(nombre);

    if(pos != -1) {
        tabla[pos].usado = 1;
    }
}

void imprimirTabla() {

    printf("\n===== TABLA DE SIMBOLOS =====\n");

    printf("%-15s %-15s %-10s %-10s %-10s\n",
           "Nombre",
           "Clase",
           "Tipo",
           "Ambito",
           "Aridad");

    for(int i=0; i<symbolCount; i++) {

        printf("%-15s %-15s %-10s %-10d %-10d\n",
               tabla[i].nombre,
               tabla[i].clase,
               tabla[i].tipo,
               tabla[i].ambito,
               tabla[i].aridad);

        if(strcmp(tabla[i].clase, "variable") == 0 &&
           tabla[i].usado == 0) {

            printf("Advertencia: variable '%s' declarada pero no usada\n",
                   tabla[i].nombre);
        }
    }
}

%}

%union {

    int intValue;
    char *stringValue;

}

%token INCLUDE DEFINE
%token INT FUNC RETURN IF

%token PLUS MINUS MULT DIV
%token ASSIGN

%token LPAREN RPAREN
%token LBRACE RBRACE

%token SEMICOLON COMMA

%token <intValue> NUMBER
%token <stringValue> IDENTIFIER

%%

program:
    declarations
    ;

declarations:
    declarations declaration
    |
    ;

declaration:
      variable_decl
    | function_decl
    ;

variable_decl:
    INT IDENTIFIER SEMICOLON
    {
        insertarSimbolo($2, "variable", "int", 0, 0);
    }
    ;

function_decl:
    FUNC IDENTIFIER LPAREN parameters RPAREN block
    {
        insertarSimbolo($2, "funcion", "int", 0, 2);
    }
    ;

parameters:
      IDENTIFIER COMMA IDENTIFIER
    |
    ;

block:
    LBRACE statements RBRACE
    ;

statements:
    statements statement
    |
    ;

statement:
      assignment
    | return_stmt
    | if_stmt
    | variable_decl
    ;

assignment:
    IDENTIFIER ASSIGN expression SEMICOLON
    {
        int pos = buscarSimbolo($1);

        if(pos == -1) {

            printf("Error semántico línea %d: variable '%s' no declarada\n",
                   lineNumber,
                   $1);
        }
        else {
            marcarUsado($1);
        }
    }
    ;

expression:
      IDENTIFIER
      {
          int pos = buscarSimbolo($1);

          if(pos == -1) {

              printf("Error semántico línea %d: variable '%s' no declarada\n",
                     lineNumber,
                     $1);
          }
          else {
              marcarUsado($1);
          }
      }

    | NUMBER

    | IDENTIFIER PLUS IDENTIFIER
    | IDENTIFIER MINUS IDENTIFIER
    | IDENTIFIER MULT IDENTIFIER
    | IDENTIFIER DIV IDENTIFIER
    ;

return_stmt:
    RETURN expression SEMICOLON
    ;

if_stmt:
    IF LPAREN IDENTIFIER RPAREN block
    {
        int pos = buscarSimbolo($3);

        if(pos == -1) {

            printf("Error semántico línea %d: variable '%s' no declarada\n",
                   lineNumber,
                   $3);
        }
    }
    ;

%%

void yyerror(const char *s) {

    printf("Error sintáctico línea %d: %s\n",
           lineNumber,
           s);
}

int main(int argc, char *argv[]) {

    extern FILE *yyin;

    if(argc > 1) {

        yyin = fopen(argv[1], "r");

        if(!yyin) {

            printf("No se pudo abrir archivo\n");
            return 1;
        }
    }

    yyparse();

    imprimirTabla();

    return 0;
}
