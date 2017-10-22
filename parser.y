/*
 Lucas Valandro
 Pietro Degrazia
 */
%{
    #include "main.h"
    #include "cc_dict.h"
    #include "cc_ast.h"
    #include "cc_tree.h"
    #include "cc_gv.h"
    extern int yylineno;
    comp_tree_t* tree;
    comp_tree_t* node;

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
%token<valor_lexico> TK_OC_LE
%token<valor_lexico> TK_OC_GE
%token<valor_lexico> TK_OC_EQ
%token<valor_lexico> TK_OC_NE
%token<valor_lexico> TK_OC_AND
%token<valor_lexico> TK_OC_OR
%token<valor_lexico> TK_OC_SL
%token<valor_lexico> TK_OC_SR
%token<valor_lexico> TK_LIT_INT
%token<valor_lexico> TK_LIT_FLOAT
%token<valor_lexico> TK_LIT_FALSE
%token<valor_lexico> TK_LIT_TRUE
%token<valor_lexico> TK_LIT_CHAR
%token<valor_lexico> TK_LIT_STRING
%token<valor_lexico> TK_IDENTIFICADOR
%token TOKEN_ERRO

%error-verbose
%type <val> program
%type <val> program_body
%type <val> declare_function
%type <valor_lexico> declare
%type <val> body
%type <val> header
%type <val> block
%type <val> params
%type <val> commands

%left TK_OC_OR
%left TK_OC_AND
%left TK_OC_EQ TK_OC_NE
%left '>' TK_OC_GE
%left '<' TK_OC_LE
%left TK_OC_SL TK_OC_SR
%left '+' '-'
%left '*' '/'
%right '['']'
%right '('')'

%union{
    comp_dict_item_t *valor_lexico;
    struct comp_tree* val;
}

%%
/* Regras (e ações) da gramática */


/*
 *
 *    CONSTRUÇÃO DO PROGRAMA
 *
 */
program:
program_body {
    tree = tree_make_node((void*)AST_PROGRAMA);	//cria nodo raíz
    $$ = tree;				//associa o início a  rai­z da árvore

    //Se existir um corpo, adiciona na raíz
    if ($1 != NULL) {
      printf("CORPO\n %d", $1);
      tree_insert_node($$, $1);
      gv_declare(AST_PROGRAMA, $$, NULL);
    }

}
;
program_body:
program_body declare ';' {$$ = $1;}|
program_body declare_new_type ';' {$$ = $1;}|
program_body declare declare_function {
    $$ = $3;
    if($3 != NULL){
      printf("FUNCAO\n");
      node = tree_make_node((void*)AST_FUNCAO);
      tree_debug_print(node);
    }
  // Não existem mais funções, então pode anexar esse ramo na raíz.
    else {
      printf("ACABOU");
      tree_insert_node($$,node);
      gv_connect($$,node);
    }
}|
/* empty */ {$$ = NULL;}
;
declare_new_type:
TK_PR_CLASS TK_IDENTIFICADOR '['fields']'
;
fields:
field |
':' fields
;
field:
TK_PR_PROTECTED type TK_IDENTIFICADOR |
TK_PR_PUBLIC type TK_IDENTIFICADOR |
TK_PR_PRIVATE type TK_IDENTIFICADOR
;
declare:
type TK_IDENTIFICADOR {$$ = $2;}|
type TK_IDENTIFICADOR '['TK_LIT_INT']'{$$ = $2;}|
TK_PR_STATIC type TK_IDENTIFICADOR {$$ = $3;}|
TK_PR_STATIC type TK_IDENTIFICADOR '['TK_LIT_INT']'{$$ = $3;}|
TK_IDENTIFICADOR TK_IDENTIFICADOR {$$ = $2;}
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
/* empty */ {$$ = NULL;}
;
arg:
type TK_IDENTIFICADOR
| TK_IDENTIFICADOR TK_IDENTIFICADOR
| TK_PR_CONST type TK_IDENTIFICADOR
| TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR
;

/* Funções */
declare_function:
header body {
      $$ = $1;
      if ($2 != NULL) {
				tree_insert_node($$, $2);
			}
}
;
header:
params {$$ = $1;}
;
body:
block {$$ = $1;}
;
block:
'{'commands'}' {$$ = $2;}
;
commands:
commands block ';' |
commands declare_var_local ';' |
commands attribution ';'|
commands control ';'|
commands io ';'|
commands return ';' |
commands TK_PR_BREAK ';' |
commands TK_PR_CONTINUE ';' |
commands TK_PR_CASE TK_LIT_INT ':' |
commands shift ';' |
/* empty */ {$$ = NULL;}
;
declare_var_local:
TK_PR_STATIC type TK_IDENTIFICADOR att|
TK_PR_STATIC TK_PR_CONST type TK_IDENTIFICADOR att|
type TK_IDENTIFICADOR att|
TK_PR_CONST type TK_IDENTIFICADOR att
;
att:
TK_OC_LE TK_IDENTIFICADOR |
TK_OC_LE lit |
/* empty */ {$$ = NULL;}
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
TK_IDENTIFICADOR |
lit |
TK_IDENTIFICADOR '['expression']' |
func_call |
/* empty */ {$$ = NULL;}
;

attribution:
TK_IDENTIFICADOR '=' expression
| TK_IDENTIFICADOR '[' expression ']' '=' expression
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
TK_IDENTIFICADOR TK_OC_SL TK_LIT_INT |
TK_IDENTIFICADOR TK_OC_SR TK_LIT_INT
;
/* Declaração de um novo tipo */
/*Bloco de funções*/
/* Declaração variaveis locais */
/* Atribuição */
/* Funções de retorno */
/*Chamada de função*/
func_call:
TK_IDENTIFICADOR '('list_func')'
;
list_func:
expression |
expression ',' list_func
;
/* Expressão */
/* Funções de controle de fluxo */

%%
