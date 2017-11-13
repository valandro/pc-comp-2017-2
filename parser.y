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

    comp_scope_t* stack[255];
    int stack_length = 0;
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
%type <type> type

%left TK_OC_OR
%left TK_OC_AND
%left '!' TK_OC_EQ TK_OC_NE
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
    int type;
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
    //printf("\nprogram_body\n");
    dict_debug_print(stack[stack_length]->symbols);
    ast_node_t *node = malloc(sizeof(ast_node_t));
    node->type = AST_PROGRAMA;

    tree = tree_make_node((void*)node); //cria nodo raíz
    $$ = tree;        //associa o início a  rai­z da árvore
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

  comp_scope_t *scope = stack[stack_length];

  $2->variable_type = $1; // Salvando o tipo (INT, FLOAT,...)
  dict_put(scope->symbols, $2->value.stringValue, $2);
}|
type TK_IDENTIFICADOR '['TK_LIT_INT']'{
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $2;
  $$ = tree_make_node((void*)node);
  $2->vector_size = atoi($4->value.stringValue);

  comp_scope_t *scope = stack[stack_length];

  $2->variable_type = $1; // Salvando o tipo (INT, FLOAT,...)
  dict_put(scope->symbols, $2->value.stringValue, $2);
}|
TK_PR_STATIC type TK_IDENTIFICADOR {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $3;
  $$ = tree_make_node((void*)node);

  comp_scope_t *scope = stack[stack_length];

  $3->variable_type = $2; // Salvando o tipo (INT, FLOAT,...)
  dict_put(scope->symbols, $3->value.stringValue, $3);
}|
TK_PR_STATIC type TK_IDENTIFICADOR '['TK_LIT_INT']'{
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_FUNCAO;
  node->value.data = $3;
  $$ = tree_make_node((void*)node);

  $3->vector_size = atoi($5->value.stringValue);

  comp_scope_t *scope = stack[stack_length];

  $3->variable_type = $2; // Salvando o tipo (INT, FLOAT,...)
  dict_put(scope->symbols, $3->value.stringValue, $3);

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
TK_PR_INT    {$$ = IKS_INT;}  |
TK_PR_FLOAT  {$$ = IKS_FLOAT;}|
TK_PR_CHAR   {$$ = IKS_CHAR;} |
TK_PR_BOOL   {$$ = IKS_BOOL;} |
TK_PR_STRING {$$ = IKS_STRING;}
;

lit:
TK_LIT_INT    {$$ = $1;}|
TK_LIT_FLOAT  {$$ = $1;}|
TK_LIT_CHAR   {$$ = $1;}|
TK_LIT_TRUE   {$$ = $1;}|
TK_LIT_FALSE  {$$ = $1;}|
TK_LIT_STRING {$$ = $1;}
;
params:
'(' args ')'
;
args:
args ',' arg {

}|
arg |
;

arg:
type TK_IDENTIFICADOR {
  //$$ = $1;
}
| TK_IDENTIFICADOR TK_IDENTIFICADOR {
  //$$ = $1->value.stringValue;
}
| TK_PR_CONST type TK_IDENTIFICADOR{
  //$$ = $2;
}
| TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR{
  //$$ = $2->value.stringValue;
}
;

/* Funções */
declare_function:
header body {
      $$ = $2;
}
;
header:
params {
  $$ = $1;
}
;
body:
block {
  $$ = $1;
}
;
block:
{

  comp_scope_t * scope = malloc(sizeof(comp_scope_t));
  comp_dict_t *symbols = dict_new();
  scope->symbols = symbols;
  stack_length++;
  stack[stack_length] = scope;
}
'{'commands'}' {


    comp_scope_t *scope = stack[stack_length];
    dict_debug_print(scope->symbols);
    stack_length--;


    ast_node_t *node = malloc(sizeof(ast_node_t));
    node->type = AST_BLOCO;
    $$ = tree_make_node((void*)node);
    if($3 != NULL) {
      tree_insert_node($$,$3);
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

  comp_scope_t *scope = stack[stack_length];

  $3->variable_type = $2; // Salvando o tipo (INT, FLOAT,...)
  dict_put(scope->symbols, $3->value.stringValue, $3);

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

  comp_scope_t *scope = stack[stack_length];

  $2->variable_type = $1; // Salvando o tipo (INT, FLOAT,...)
  dict_put(scope->symbols, $2->value.stringValue, $2);
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


  comp_scope_t *scope;
  comp_dict_t *dict;
  int ident_type;
  int current_scope_depth = stack_length;
  do {
    printf("\nescopo atual %d buscando %s\n", current_scope_depth,$1->value.stringValue);
    scope = stack[current_scope_depth];
    dict = scope->symbols;
    ident_type = returnType(dict, $1);
    current_scope_depth--;
  } while (ident_type == IKS_UNDECLARED && current_scope_depth >= 0);

  if (ident_type == IKS_UNDECLARED) {
    printf("\nidentificador %s não foi declarado\n", $1->value.stringValue);
    exit(IKS_ERROR_UNDECLARED);
  }

  node->variable_type = ident_type;


} |
lit {
  ast_node_t *node = malloc(sizeof(ast_node_t));
  node->type = AST_LITERAL;
  node->value.data = $1;
  $$ = tree_make_node((void*)node);
  
  comp_dict_data_t *data = $1;

  printf("\nlit: %d\n", data->token_type);

  switch(data->token_type) {
    case POA_LIT_INT: {
      node->variable_type = IKS_INT;
      break;
    }
    case POA_LIT_FLOAT: {
      node->variable_type = IKS_FLOAT;
      break;
    }
    case POA_LIT_CHAR: {
      node->variable_type = IKS_CHAR;
      break;
    }
    case POA_LIT_STRING: {
      node->variable_type = IKS_STRING;
      break;
    }
    case POA_LIT_BOOL: {
      node->variable_type = IKS_BOOL;
      break;
    }
    default: break;
  }

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

func_call {
  $$ = $1;
}|

{$$ = NULL;}

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

  comp_scope_t *scope;
  comp_dict_t *dict;
  int ident_type;
  int current_scope_depth = stack_length;
  do {
    printf("\nescopo atual %d buscando %s\n", current_scope_depth,$1->value.stringValue);
    scope = stack[current_scope_depth];
    dict = scope->symbols;
    ident_type = returnType(dict, $1);
    current_scope_depth--;
  } while (ident_type == IKS_UNDECLARED && current_scope_depth >= 0);

  if (ident_type == IKS_UNDECLARED) {
    printf("\nidentificador %s não foi declarado\n", $1->value.stringValue);
    exit(IKS_ERROR_UNDECLARED);
  }
  else {
    printf("%s foi achado no escopo %d\n",$1->value.stringValue,current_scope_depth+1);
  }

  comp_tree_t *expression = $3;
  ast_node_t *operation = expression->value;
  
  int op_type = operation->variable_type;

  if (ident_type != op_type) {
    if(ident_type == IKS_STRING || ident_type == IKS_CHAR || op_type == IKS_STRING || op_type == IKS_CHAR) {
      printf("\nERRO 6: identificador %s é do tipo %d, mas o outro valor é do tipo %d\n", $1->value.stringValue, ident_type, op_type);
      exit(IKS_ERROR_WRONG_TYPE);  
    }
  }

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
TK_PR_INPUT  list_exp|
TK_PR_OUTPUT expression
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


  comp_scope_t *scope;
  comp_dict_t *dict;
  comp_dict_data_t *func_data;
  int current_scope_depth = stack_length;
  do {
    printf("\nescopo atual %d buscando %s\n", current_scope_depth,$1->value.stringValue);
    scope = stack[current_scope_depth];
    dict = scope->symbols;
    func_data = returnData(dict, $1);
    current_scope_depth--;
  } while (func_data == NULL || current_scope_depth > 0);
  
  if (func_data == NULL) {
    printf("\nERRO 1:função %s não foi declarada\n", $1->value.stringValue);
    exit(IKS_UNDECLARED);
    break;
  }
  node->variable_type = func_data->variable_type;
  printf("\nident = exp -> funcao %s retorna tipo %d\n", func_data->value.stringValue, func_data->variable_type);
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
