#include "cc_misc.h"
comp_dict_t *dict;

int comp_get_line_number (void)
{
  extern int yylineno; // Usando yylineno para contar as linhas
  return yylineno;
}

void did_read_token(int token)
{
  extern char *yytext;
  extern int yylineno;
  int line_number = yylineno;
  char *text = strdup(yytext);
  if (token == TK_LIT_CHAR || token == TK_LIT_STRING) {
    text++; // Retirando primeira " ou '
    text[strlen(text) - 1] = 0; // Retirando última " ou '
  }
  dict_remove(dict, text);
  dict_put(dict, text, (void*)(line_number));
}

void yyerror (char const *mensagem)
{
  extern int yylineno;
  fprintf (stderr, "%s\n Erro na linha %d", mensagem,yylineno);
}

void main_init (int argc, char **argv)
{
  dict = dict_new(); // Criação de uma nova tabela
}

void comp_print_table (void)
{
  int i, l;
  for (i = 0, l = dict->size; i < l; ++i) {
    if (dict->data[i]) {
      cc_dict_etapa_1_print_entrada (dict->data[i]->key, (int)dict->data[i]->value);
    }
  }
}

void main_finalize (void)
{
  // comp_print_table();
}
