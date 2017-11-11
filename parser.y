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
    comp_tree_t* last_function;
    int cont = 0;
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
%type <val> declare
%type <val> body
%type <val> header
%type <val> block
%type <val> attribution
%type <val> control
%type <val> return
%type <val> params
%type <val> args
%type <val> commands
%type <val> expression
%type <val> func_call
%type <val> list_func
%type <val> declare_var_local
%type <val> att
%type <valor_lexico> lit

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
    comp_dict_data_t *valor_lexico;
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
    ast_node_t *node = malloc(sizeof(ast_node_t));
    node->type = AST_PROGRAMA;

    tree = tree_make_node((void*)node);	//cria nodo raíz
    $$ = tree;				//associa o início a  rai­z da árvore
    //Se existir um corpo, adiciona na raíz
    if ($1 != NULL) {
      tree_insert_node($$, $1);
    }
}
;
program_body:
program_body declare ';' {$$ = $1;}|
program_body declare_new_type ';' {$$ = $1;}|
program_body declare declare_function {
    comp_tree_t* first;

    $$ = first;
    if(cont > 0) {//se não for a primeira função/já existir last_function
      tree_insert_node(last_function,$2);
    }

    last_function = $2;
    cont++;

    if($3 != NULL){ //a função tem corpo, tem comandos
      tree_insert_node($2,$3);
    }

    if(cont == 1){
      first = $2;
      $$ = $2;
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
type TK_IDENTIFICADOR {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $2;
  $$ = tree_make_node((void*)node);
}|
type TK_IDENTIFICADOR '['TK_LIT_INT']'{
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $2;
  $$ = tree_make_node((void*)node);
}|
TK_PR_STATIC type TK_IDENTIFICADOR {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $3;
  $$ = tree_make_node((void*)node);
}|
TK_PR_STATIC type TK_IDENTIFICADOR '['TK_LIT_INT']'{
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $3;
  $$ = tree_make_node((void*)node);
}|
TK_IDENTIFICADOR TK_IDENTIFICADOR {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $2;
  $$ = tree_make_node((void*)node);
}
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
| TK_PR_CONST type TK_IDENTIFICADOR
| TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR
;

/* Funções */
declare_function:
header body {
      $$ = $2;
}
;
header:
params
;
body:
block {
  $$ = $1;
}
;
block:
'{'commands'}' {
    ast_node_t *node = malloc(sizeof(ast_node_t));
    node->type = AST_BLOCO;
    $$ = tree_make_node((void*)node);
    if($2 != NULL) {
      tree_insert_node($$,$2);
    }
  }
;
commands:
commands block ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
commands declare_var_local ';' {
  printf("\ncomands declare var\n");
  if ($2 != NULL) {
    if($$ == NULL){
     $$ = $2;
     $$->last = $2;
    }
    else {
     tree_insert_node($$->last,$2);
     $$->last = $2;
    }
  }
}|
commands attribution ';' {
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
commands control ';'{
  if($$ == NULL){
   $$ = $2;
   $$->last = $2;
  }
  else {
   tree_insert_node($$->last,$2);
   $$->last = $2;
  }
}|
commands io ';'|
commands return ';' {
  if($$ == NULL){
    $$ = $2;
    $$->last = $2;
  }
  else {
    tree_insert_node($$->last,$2);
    $$->last = $2;
  }
}|
commands TK_PR_BREAK ';' |
commands TK_PR_CONTINUE ';' |
commands TK_PR_CASE TK_LIT_INT ':' |
commands shift ';' |
/* empty */ {$$ = NULL;}
;

declare_var_local:
TK_PR_STATIC type TK_IDENTIFICADOR att {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $3;
  comp_tree_t *ident_tree = tree_make_node((void*)ident);
  if ($4 != NULL) {
    $$ = tree_make_binary_node((void*)node, ident_tree, $4);
  } else {
    $$ = NULL;
  }
}|
TK_PR_STATIC TK_PR_CONST type TK_IDENTIFICADOR att {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $4;
  comp_tree_t *ident_tree = tree_make_node((void*)ident);
  if ($5 != NULL) {
    $$ = tree_make_binary_node((void*)node, ident_tree, $5);
  } else {
    $$ = NULL;
  }
}|
type TK_IDENTIFICADOR att {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $2;
  comp_tree_t *ident_tree = tree_make_node((void*)ident);
  if ($3 != NULL) {
    $$ = tree_make_binary_node((void*)node, ident_tree, $3);
  } else {
    $$ = NULL;
  }
}|
TK_PR_CONST type TK_IDENTIFICADOR att {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $3;
  comp_tree_t *ident_tree = tree_make_node((void*)ident);
  if ($4 != NULL) {
    $$ = tree_make_binary_node((void*)node, ident_tree, $4);
  } else {
    $$ = NULL;
  }
}
;

att:
TK_OC_LE TK_IDENTIFICADOR {
  printf("\n=> ident\n");
  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $2;
  $$ = tree_make_node((void*)ident);
}|
TK_OC_LE lit {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LITERAL;
  node->value.data = $2;
  $$ = tree_make_node((void*)node);
}|
  {$$ = NULL;}
;

expression:
'('expression')' {
  $$ = $2;
}|
expression '*' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ARIM_MULTIPLICACAO;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '+' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ARIM_SOMA;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '-' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ARIM_SUBTRACAO;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '/' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ARIM_DIVISAO;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '>' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_G;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression '<' expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_L;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_LE expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_LE;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_GE expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_GE;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_EQ expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_IGUAL;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_NE expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_COMP_DIF;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_AND expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_E;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_OR expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LOGICO_OU;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_SL expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_SHIFT_LEFT;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
expression TK_OC_SR expression {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_SHIFT_RIGHT;
  $$ = tree_make_binary_node((void*)node, $1, $3);
}|
TK_IDENTIFICADOR {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_IDENTIFICADOR;
  node->value.data = $1;
  $$ = tree_make_node((void*)node);
} |
lit {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LITERAL;
  node->value.data = $1;
  $$ = tree_make_node((void*)node);
}|
TK_IDENTIFICADOR '['expression']' {
    ast_node_t *ident = malloc(sizeof(ast_node_t));
    ident->type = AST_IDENTIFICADOR;
    ident->value.data = $1;
    comp_tree_t* ident_tree = tree_make_node((void*)ident);

    ast_node_t *node = malloc(sizeof(ast_node_t));
    node->type = AST_VETOR_INDEXADO;
    $$ = tree_make_binary_node((void*)node, ident_tree, $3);
}|

'!' expression {
    ast_node_t *node = malloc(sizeof(ast_node_t));
    node->type = AST_LOGICO_COMP_NEGACAO;

    $$ = tree_make_unary_node((void*)node, $2);
}|

func_call {$$ = $1;}|

;

attribution:
TK_IDENTIFICADOR '=' expression {
  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;
  comp_tree_t* ident_node = tree_make_node((void*)ident);

  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  $$ = tree_make_binary_node((void*)node, ident_node, $3);
}
| TK_IDENTIFICADOR '[' expression ']' '=' expression {
ast_node_t *vetor = malloc(sizeof(ast_node_t));
  vetor->type = AST_VETOR_INDEXADO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;
  comp_tree_t* ident_node = tree_make_node((void*)ident);

  comp_tree_t* vetor_tree_node = tree_make_binary_node((void*)vetor, ident_node, $3);

  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  $$ = tree_make_binary_node((void*)node, vetor_tree_node, $6);
}
| TK_IDENTIFICADOR '!' TK_IDENTIFICADOR '=' expression {
  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;
  comp_tree_t* ident_node = tree_make_node((void*)ident);

  ast_node_t *ident2 = malloc(sizeof(ast_node_t));
  ident2->type = AST_IDENTIFICADOR;
  ident2->value.data = $3;
  comp_tree_t* ident2_node = tree_make_node((void*)ident2);

  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_ATRIBUICAO;

  $$ = tree_make_ternary_node((void*)node, ident_node,ident2_node, $5);
}
;

control:
TK_PR_IF '('expression')' TK_PR_THEN block {
  ast_node_t *if_then_value = malloc(sizeof(ast_node_t));
  if_then_value->type = AST_IF_ELSE;

  comp_tree_t* if_then_tree_node = tree_make_node((void*)if_then_value);

  ast_node_t *t = $3->value;
  tree_insert_node(if_then_tree_node, $3);
  if ($6 != NULL) {
    ast_node_t *p = $6->value;
    tree_insert_node(if_then_tree_node, $6);
  }
  $$ = if_then_tree_node;
}|
TK_PR_IF '('expression')' TK_PR_THEN block TK_PR_ELSE block {
  ast_node_t *if_then_value = malloc(sizeof(ast_node_t));
  if_then_value->type = AST_IF_ELSE;

  comp_tree_t* if_then_tree_node = tree_make_node((void*)if_then_value);
  tree_insert_node(if_then_tree_node, $3);
  if ($6 != NULL) {
    tree_insert_node(if_then_tree_node, $6);
  }
  if ($8 != NULL) {
    tree_insert_node(if_then_tree_node, $8);
  }
  $$ = if_then_tree_node;
}|
TK_PR_FOREACH '('TK_IDENTIFICADOR ':' list_exp')' block |
TK_PR_FOR '(' list_cmd ':' expression ':' list_cmd ')' block |
TK_PR_SWITCH '('expression')' block |
TK_PR_WHILE '('expression')' TK_PR_DO block {
  ast_node_t *while_value = malloc(sizeof(ast_node_t));
  while_value->type = AST_WHILE_DO;

  comp_tree_t* while_tree_node = tree_make_node((void*)while_value);
  tree_insert_node(while_tree_node, $3);
  tree_insert_node(while_tree_node, $6);

  $$ = while_tree_node;
}|
TK_PR_DO block TK_PR_WHILE '('expression')' {
  ast_node_t *while_value = malloc(sizeof(ast_node_t));
  while_value->type = AST_DO_WHILE;

  comp_tree_t* while_tree_node = tree_make_node((void*)while_value);
  tree_insert_node(while_tree_node, $5);
  tree_insert_node(while_tree_node, $2);

  $$ = while_tree_node;
}
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
TK_PR_RETURN expression {
  ast_node_t *ast_return = malloc(sizeof(ast_node_t));
  ast_return->type = AST_RETURN;
  $$ = tree_make_unary_node((void*)ast_return, $2);
}
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
TK_IDENTIFICADOR '('list_func')' {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_CHAMADA_DE_FUNCAO;

  ast_node_t *ident = malloc(sizeof(ast_node_t));
  ident->type = AST_IDENTIFICADOR;
  ident->value.data = $1;

  comp_tree_t* ident_tree = tree_make_node((void*)ident);

  if ($3 == NULL) {
      $$ = tree_make_unary_node((void*)node,ident_tree);
  } else {
      $$ = tree_make_binary_node((void*)node,ident_tree,$3);
  }

}
;
list_func:
expression {
  $$ = $1;
}|
expression ',' list_func {
  tree_insert_node($$,$3);
}
;
/* Expressão */
/* Funções de controle de fluxo */

%%
