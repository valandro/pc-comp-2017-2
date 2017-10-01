#ifndef __MISC_H
#define __MISC_H
#include <stdio.h>
#include <string.h>
#include "cc_dict.h"
#include "parser.h"
#include "main.h"
#include <stdbool.h>

int getLineNumber (void);
void yyerror (char const *mensagem);
void main_init (int argc, char **argv);
void main_finalize (void);

void did_read_string(int line_number);
void did_read_float(int line_number);
void did_read_int(int line_number);
void did_read_identifier(int line_number);
void did_read_char(int line_number);
void did_read_bool(int line_number);

#endif
