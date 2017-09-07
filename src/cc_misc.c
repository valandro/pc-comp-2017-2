#include "cc_misc.h"

int comp_get_line_number (void)
{
  extern int yylineno;
  //implemente esta função
  return yylineno;
}

void yyerror (char const *mensagem)
{
  extern int yylineno;
  fprintf (stderr, "%s\n Erro na linha %d", mensagem,yylineno); //altere para que apareça a linha
}

void main_init (int argc, char **argv)
{
  //implemente esta função com rotinas de inicialização, se necessário
}

void main_finalize (void)
{
  //implemente esta função com rotinas de inicialização, se necessário
}

void comp_print_table (void)
{
  //para cada entrada na tabela de símbolos
  //Etapa 1: chame a função cc_dict_etapa_1_print_entrada
  //implemente esta função
}
