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

%left '+' '-' TK_OC_LE  TK_OC_GE TK_OC_EQ TK_OC_NE TK_OC_AND TK_OC_OR TK_OC_SL TK_OC_SR '<' '>'
%left '*' '/'
%right '^'
%%
/* Regras (e ações) da gramática */


/*
 *
 *    CONSTRUÇÃO DO PROGRAMA
 *
 */

program:
  program_body
;
program_body:
  program_body declare declare_var_global ';' |
  program_body declare declare_function |
declare:
  type TK_IDENTIFICADOR |
  TK_PR_STATIC TK_IDENTIFICADOR |
;
/* Estrutura da declaração de uma variavel */
/* Tipos das variaveis */
type:
TK_PR_INT |
TK_PR_FLOAT |
TK_PR_CHAR |
TK_PR_BOOL |
TK_PR_STRING
;
lit:
TK_LIT_INT |
TK_LIT_FLOAT |
TK_LIT_CHAR |
TK_LIT_TRUE |
TK_LIT_FALSE |
TK_LIT_STRING
;
params:
'(' args ')'
;
args:
  args ',' arg |
  arg |
;
arg:
  type TK_IDENTIFICADOR
  | TK_IDENTIFICADOR TK_IDENTIFICADOR
  | TK_PR_CONST type	TK_IDENTIFICADOR
  | TK_PR_CONST TK_IDENTIFICADOR	TK_IDENTIFICADOR
;
array:
  '['TK_LIT_INT']' |
;
declare_var_global:
  array
;

/* Funções */
declare_function:
  header body
;
header:
  params
;
body:
  block
;
block:
  '{'commands'}'
;
commands:
  commands block  ';' |
  commands declare_var_local ';' |
  commands attribution ';'|
  commands control |
  commands io ';'|
  commands return ';' |
  commands TK_PR_BREAK ';' |
  commands TK_PR_CONTINUE ';' |
  commands TK_PR_CASE TK_LIT_INT ':' |
  commands shift ';' |

;
declare_var_local:
  declare |
  declare TK_OC_LE TK_IDENTIFICADOR |
  declare TK_OC_LE lit
;
attribution:
  TK_IDENTIFICADOR '=' expression
  | TK_IDENTIFICADOR '[' expression ']' '=' expression
;
expression:
  '('expression')' |
  expression '*' expression |
  expression '+' expression |
  expression '-' expression |
  expression '/' expression |
  expression '>' expression |
  expression '<' expression |
  expression TK_OC_LE expression |
  expression TK_OC_GE expression |
  expression TK_OC_EQ expression |
  expression TK_OC_NE expression |
  expression TK_OC_AND expression |
  expression TK_OC_OR expression |
  expression TK_OC_SL expression |
  expression TK_OC_SR expression |
  lit |
  TK_IDENTIFICADOR |
  TK_IDENTIFICADOR '['expression']' |
  TK_IDENTIFICADOR params
;
control:
  TK_PR_IF '('expression')' TK_PR_THEN block |
  TK_PR_IF '('expression')' TK_PR_THEN block TK_PR_ELSE block |
  TK_PR_FOREACH '('TK_IDENTIFICADOR ':' list_exp')' block |
  TK_PR_FOR '(' list_cmd ':' expression ':' list_cmd ')' block |
  TK_PR_SWITCH '('expression')' block |
  TK_PR_WHILE '('expression')' TK_PR_DO block |
  TK_PR_DO block TK_PR_WHILE '('expression')'
;
list_cmd:
  commands |
  commands ',' list_cmd
;
io:
  TK_PR_INPUT expression  |
  TK_PR_OUTPUT list_exp
;
list_exp:
  expression |
  expression ',' list_exp
;
return:
  TK_PR_RETURN expression
;
shift:
  TK_IDENTIFICADOR ">>" TK_LIT_INT |
  TK_IDENTIFICADOR "<<" TK_LIT_INT
;
/* Declaração de um novo tipo */
/*Bloco de funções*/
/* Declaração variaveis locais */
/* Atribuição */
/* Funções de retorno */
/*Chamada de função*/
/* Expressão */
/* Funções de controle de fluxo */

%%
