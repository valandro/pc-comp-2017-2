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
void did_read_token(int token);
#endif
