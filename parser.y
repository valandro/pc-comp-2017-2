/*
 Lucas Valandro
 Pietro Degrazia
 */
%{
    #include "main.h"
    extern int yylineno;
    %}

/* Declaração dos tokens da linguagem */
%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO
%error-verbose

%%
/* Regras (e ações) da gramática */


/*
 *
 *    CONSTRUÇÃO DO PROGRAMA
 *
 */
program:
declare_global_var program |
declare_class      program |
declare_function   program |
/* empty */                ;

declare_global_var:
storage_specifier_static declare_var ';' ;

declare_var:
primitive_types TK_IDENTIFICADOR |
declare_array             ;

declare_array:
primitive_types TK_IDENTIFICADOR '[' TK_LIT_INT ']';
/* Fim da Seção */


/*
 *
 *    MODIFICADORES DE ACESSO E DE ARMAZENAMENTO
 *
 */
access_modifier:
TK_PR_PROTECTED |
TK_PR_PRIVATE   |
TK_PR_PUBLIC    ;

storage_specifier_static_const:
TK_PR_STATIC            |
TK_PR_CONST             |
TK_PR_STATIC TK_PR_CONST|
/* empty */;

storage_specifier_static:
TK_PR_STATIC |
/* empty */  ;

storage_specifier_const:
TK_PR_CONST |
/* empty */ ;
/* Fim da Seção */


/*
 *
 *    CONJUNTOS DE VARIÁVEIS E TIPOS
 *
 */

/* Falta suporte ao tipo criado pelo usuário */

/* Tipos primitivos, usados no escopo local, podem ser inicializados com valor. */
primitive_types:
TK_PR_INT   |
TK_PR_FLOAT |
TK_PR_BOOL  |
TK_PR_CHAR  |
TK_PR_STRING;

primitive_literals:
TK_LIT_INT    |
TK_LIT_FLOAT  |
TK_LIT_FALSE  |
TK_LIT_TRUE   |
TK_LIT_CHAR   |
TK_LIT_STRING ;

logic_arithmetic_operators:
logic_operators     |
arithmetic_operators;

logic_operators:
'<'         |
'>'         |
TK_OC_LE    |
TK_OC_GE    |
TK_OC_EQ    |
TK_OC_NE    |
TK_OC_AND   |
TK_OC_OR    ;

arithmetic_operators:
'+' |
'-' |
'/' |
'*' ;
/* Fim da Seção */

/* TIPO DE USUÁRIO
 class foo {
 protected int bar:
 private float car:
 public string dice
 };
 */
declare_class:
class_header class_body class_tail ;

class_header:
TK_PR_CLASS TK_IDENTIFICADOR '{' ;

class_tail:
'}' ';' ;

class_body:
class_property ':' class_body |
class_property                ;

class_property:
access_modifier primitive_types TK_IDENTIFICADOR                  |
access_modifier primitive_types TK_IDENTIFICADOR '['TK_LIT_INT']' ;
/* Fim da Seção */


/* DECLARAÇÃO DE FUNÇÃO
 int sum (const int a, int b) {
 static const int baseNumber <= 0;
 static char operatorChar;
 const string description <= "Função que soma";
 int result;
 foo fooInstance;
 
 result = a + b;
 fooInstance$bar = result
 }
 static float getPi (){}
 */
declare_function:
function_header command_block ;

function_header:
storage_specifier_static primitive_types TK_IDENTIFICADOR '('parameter_list')';

parameter_list:
parameter ',' parameter_list |
parameter                   |
/* empty */                 ;

parameter:
storage_specifier_const primitive_types TK_IDENTIFICADOR ;
/* Fim da Seção */



/*
 *
 *    BLOCO DE COMANDOS E COMANDO
 *
 */
command_block:
'{' command_list '}';

command_list:
command command_list  |
command               |
/* empty */           ;

command:
command_block           |
declare_local_var   ';' |
assignment          ';' |
control_flow            |
output              ';' |
/* entrada */

function_invocation  ';'|
shift                ';'|
return               ';';
/* Fim da Seção */


declare_local_var:
storage_specifier_static_const primitive_types TK_IDENTIFICADOR                          |
storage_specifier_static_const primitive_types TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR    |
storage_specifier_static_const primitive_types TK_IDENTIFICADOR TK_OC_LE primitive_literals  ;

assignment:
TK_IDENTIFICADOR '=' expression                     |
TK_IDENTIFICADOR'['expression']' '=' expression     |
TK_IDENTIFICADOR'$'TK_IDENTIFICADOR '=' expression  ;

function_invocation:
TK_IDENTIFICADOR'('argument_list')';

argument_list:
argument ',' argument_list |
argument                   |
/* empty */                ;

argument:
expression          |
primitive_literals  ;

shift:
TK_IDENTIFICADOR TK_OC_SL TK_LIT_INT    |
TK_IDENTIFICADOR TK_OC_SR TK_LIT_INT    ;

output:
TK_PR_OUTPUT expression;

control_flow:
if_then         |
if_then_else    |
switch          |
while           |
do_while        |
for_each        ;
/*for ;*/

if_then:
TK_PR_IF '(' expression ')' TK_PR_THEN command_block;

if_then_else:
if_then TK_PR_ELSE command_block;

switch:
TK_PR_SWITCH '(' expression ')' command_block;

while:
TK_PR_WHILE '(' expression ')' TK_PR_DO command_block ;

do_while:
TK_PR_DO command_block TK_PR_WHILE '(' expression ')' ;

for_each:
TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' expression_list ')' command_block ;

/* Que diabos é uma lista de comandos separados por ',', eu não posso usar a mesma sequencia de comandos separados por ';' que eu tenho de antes????
 for:
 TK_PR_FOR '(' lista ':' expression ':' lista ')' command_block ;
 */

expression_list:
expression ',' expression_list |
expression ;

expression:
TK_IDENTIFICADOR                                    |
TK_IDENTIFICADOR '[' expression ']'                 |
primitive_literals                                  |
function_invocation                                 |
expression logic_arithmetic_operators expression    |
'(' expression ')'                                  ;


return:
TK_PR_RETURN expression ';' |
TK_PR_CASE TK_LIT_INT ':'   |
TK_PR_BREAK ';'             |
TK_PR_CONTINUE ';'          ;

%%
/*
 TESTE
 */

