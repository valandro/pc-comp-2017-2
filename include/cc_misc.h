#ifndef __MISC_H
#define __MISC_H
#include <stdio.h>
#include <string.h>
#include "cc_dict.h"
#include "parser.h"
#include "main.h"

int getLineNumber (void);
void yyerror (char const *mensagem);
void main_init (int argc, char **argv);
void main_finalize (void);

char* suffix_for_token(int token);
comp_dict_item_t* get_entry_with_key(comp_dict_t *dict, char *key);
#endif

