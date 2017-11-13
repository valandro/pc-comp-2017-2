#include "cc_misc.h"
#include "cc_dict.h"

extern struct comp_dict *dict;

bool ast_is_command(ast_node_t *node) {
    if(node == NULL) {
        return false;
    }
    if(node->type < AST_COMMANDS_BOTTOM){
        return false;
    }
    if(node->type > AST_COMMANDS_TOP){
        return false;
    }
    return true;
}

int comp_get_line_number (void)
{
    extern int yylineno; // Usando yylineno para contar as linhas
    return yylineno;
}

char* dict_key_from_text_and_token(char* text, int token)
{
    char *key = strdup(text);
    char token_string[20];
    sprintf(token_string, "*%d", token);
    key = strcat(key, token_string);
    free(key);
    return key;
}

char* suffix_for_token(int token)
{
    char *token_string = malloc(16);
    snprintf(token_string, 16, "*%d", token);
    return token_string;
}

void yyerror (char const *mensagem)
{
    extern int yylineno;
    fprintf (stderr, "%s\n Erro na linha %d", mensagem,yylineno);
}

void main_init (int argc, char **argv)
{
    extern comp_scope_t* stack[255];

    dict = dict_new(); // Criação de uma nova tabela

    comp_scope_t * global = malloc(sizeof(comp_scope_t));
    comp_dict_t *scope = dict_new();
    global->symbols = scope;
    stack[0] = global;
}

void comp_print_table (void)
{
    printf("comp_print_table");
    extern comp_dict_t *dict;
    int i, l;
    for (i = 0, l = dict->size; i < l; ++i) {
        if (dict->data[i]) {
            comp_dict_data_t *data = (comp_dict_data_t*)dict->data[i]->value;
            cc_dict_etapa_2_print_entrada(dict->data[i]->key, data->line_number, data->token_type);
        }
    }
}

comp_dict_item_t* get_entry_with_key(comp_dict_t *dict, char *key)
{
    int i, l;
    for (i = 0, l = dict->size; i < l; ++i) {
        if (strcmp(dict->data[i]->key, key) == 0) {
            return dict->data[i];
        }
    }
    comp_dict_item_t *item = malloc(sizeof(comp_dict_item_t));
    return item;
}

void main_finalize (void)
{
    extern comp_dict_t *dict;
}


int infere(ast_node_t *left_node, ast_node_t *right_node) {
  int left = left_node->variable_type;
  int right = right_node->variable_type;

  if (left != right) {
    if (left == IKS_BOOL) {
      return right;
    }
    if (right == IKS_BOOL) {
      return left; 
    }
    if (left == IKS_FLOAT) {
      return left;
    }
    if (right == IKS_FLOAT) {
      return right; 
    }
  } else {
    return left;
  }

}
