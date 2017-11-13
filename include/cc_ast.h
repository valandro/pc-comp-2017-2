/*
  cc_ast.h

  Este arquivo contém as constantes para os tipos dos nós da AST.
*/
#ifndef __CC_AST_H
#define __CC_AST_H

#include "cc_dict.h"

#define AST_COMMANDS_BOTTOM      2
#define AST_COMMANDS_TOP         9

#define AST_PROGRAMA             0
#define AST_FUNCAO               1
//Comandos
#define AST_IF_ELSE              2
#define AST_DO_WHILE             3
#define AST_WHILE_DO             4
#define AST_INPUT                5
#define AST_OUTPUT               6
#define AST_ATRIBUICAO           7
#define AST_RETURN               8
#define AST_BLOCO                9
//Condição, Saída, Expressão
#define AST_IDENTIFICADOR       10
#define AST_LITERAL             11
#define AST_ARIM_SOMA           12
#define AST_ARIM_SUBTRACAO      13
#define AST_ARIM_MULTIPLICACAO  14
#define AST_ARIM_DIVISAO        15
#define AST_ARIM_INVERSAO       16 // - (operador unário -)
#define AST_LOGICO_E            17 // &&
#define AST_LOGICO_OU           18 // ||
#define AST_LOGICO_COMP_DIF     19 // !=
#define AST_LOGICO_COMP_IGUAL   20 // ==
#define AST_LOGICO_COMP_LE      21 // <=
#define AST_LOGICO_COMP_GE      22 // >=
#define AST_LOGICO_COMP_L       23 // <
#define AST_LOGICO_COMP_G       24 // >
#define AST_LOGICO_COMP_NEGACAO 25 // !
#define AST_VETOR_INDEXADO      26 // para var[exp] quando o índice exp é acessado no vetor var
#define AST_CHAMADA_DE_FUNCAO   27
#define AST_SHIFT_RIGHT         28
#define AST_SHIFT_LEFT          29


#define IKS_UNDECLARED -1
#define IKS_INT        1
#define IKS_FLOAT      2
#define IKS_CHAR       3
#define IKS_STRING     4
#define IKS_BOOL       5

#define IKS_SUCCESS            0 //caso não houver nenhum tipo de erro

/* Verificação de declarações */
#define IKS_ERROR_UNDECLARED  1 //identificador não declarado
#define IKS_ERROR_DECLARED    2 //identificador já declarado

/* Uso correto de identificadores */
#define IKS_ERROR_VARIABLE    3 //identificador deve ser utilizado como variável
#define IKS_ERROR_VECTOR      4 //identificador deve ser utilizado como vetor
#define IKS_ERROR_FUNCTION    5 //identificador deve ser utilizado como função

/* Tipos e tamanho de dados */
#define IKS_ERROR_WRONG_TYPE  6 //tipos incompatíveis
#define IKS_ERROR_STRING_TO_X 7 //coerção impossível do tipo string
#define IKS_ERROR_CHAR_TO_X   8 //coerção impossível do tipo char

/* Argumentos e parâmetros */
#define IKS_ERROR_MISSING_ARGS    9  //faltam argumentos
#define IKS_ERROR_EXCESS_ARGS     10 //sobram argumentos
#define IKS_ERROR_WRONG_TYPE_ARGS 11 //argumentos incompatíveis

/* Verificação de tipos em comandos */
#define IKS_ERROR_WRONG_PAR_INPUT  12 //parâmetro não é identificador
#define IKS_ERROR_WRONG_PAR_OUTPUT 13 //parâmetro não é literal string ou expressão
#define IKS_ERROR_WRONG_PAR_RETURN 14 //parâmetro não é expressão compatível com tipo do retorno

/*
 * Tipo: ast_node
 */
typedef struct ast_node
{
	int variable_type;
    int type;
    union
    {
        comp_dict_data_t* data;
    } value;
} ast_node_t;
typedef struct comp_scope
{
  comp_dict_t *symbols; //caso seja do tipo bloco, vai ter tabela de simbolos
} comp_scope_t;

#endif
