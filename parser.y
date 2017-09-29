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

%left '<' '>' TK_OC_LE TK_OC_GE TK_OC_EQ TK_OC_NE
%left TK_OC_AND TK_OC_OR
%left '+' '-'
%left '*' '/'
%left '='
%left '[' ']'
%left '(' ')'
%%
/* Regras (e ações) da gramática */


/*
 *
 *    CONSTRUÇÃO DO PROGRAMA
 *
 */

program:
declare_global_var program |
declare_new_type program |
functions program |
;

/* Estrutura da declaração de uma variavel */
declare_global_var:
var_type TK_IDENTIFICADOR ';' |
TK_PR_STATIC var_type TK_IDENTIFICADOR |
var_type TK_IDENTIFICADOR '[' TK_LIT_INT ']' ';'
;

/* Tipos das variaveis */
var_type:
TK_PR_INT |
TK_PR_FLOAT |
TK_PR_CHAR |
TK_PR_BOOL |
TK_PR_STRING
;

lit_type:
TK_LIT_INT |
TK_LIT_FLOAT |
TK_LIT_FALSE |
TK_LIT_TRUE |
TK_LIT_CHAR |
TK_LIT_STRING
;
/* Declaração de um novo tipo */
declare_new_type: ;

/* Funções */
functions:
var_type TK_IDENTIFICADOR '(' params ')' body |
TK_PR_STATIC var_type TK_IDENTIFICADOR '(' params ')' body | /*empty*/
;

params:
var_type TK_IDENTIFICADOR more_params |
TK_PR_CONST var_type TK_IDENTIFICADOR more_params | /*empty*/
;

more_params:
',' var_type TK_IDENTIFICADOR more_params |
',' TK_PR_CONST var_type TK_IDENTIFICADOR more_params |/*empty*/
;
/*Bloco de funções*/
body: block
;
block: '{' commands '}'
;
commands: command';' commands| /*empty*/
;
command: local_var | block | attributed | return | input | output | callback | /*empty*/
;
local_var:
declare_local_var '<=' TK_IDENTIFICADOR |
declare_local_var '<=' lit_type |
declare_local_var
;
declare_local_var:
var_type TK_IDENTIFICADOR |
TK_PR_STATIC var_type TK_IDENTIFICADOR |
TK_PR_STATIC TK_PR_CONST var_type TK_IDENTIFICADOR
;
attributed:
TK_IDENTIFICADOR '=' expression |
TK_IDENTIFICADOR '[' expression ']' '=' expression
;
return: TK_PR_RETURN TK_IDENTIFICADOR ;
input: TK_PR_INPUT;
output: TK_PR_OUTPUT;
callback:

;

expression:
TK_IDENTIFICADOR |
TK_IDENTIFICADOR '[' expression ']' |
TK_LIT_INT |
TK_LIT_FLOAT |
callback |
'(' expression ')' |
expression '+' expression |
expression '-' expression |
expression '*' expression |
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
;
%%
