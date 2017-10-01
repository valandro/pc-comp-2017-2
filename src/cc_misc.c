#include "cc_misc.h"
comp_dict_t *dict;

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
    return key;
}

char* suffix_for_token(int token)
{
    char *token_string = malloc(2);
    sprintf(token_string, "*%d", token);
    return token_string;
}

void did_read_bool(int line_number)
{
    char *bool_as_string = malloc(20);
    sprintf(bool_as_string, yylval.intValue ? "true" : "false");
    char *key = strcat(bool_as_string, suffix_for_token(POA_LIT_BOOL));
    dict_remove(dict, key);
    
    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_BOOL;
    data->value.boolValue = yylval.intValue ? true : false;
    
    dict_put(dict, key, (void*)(data));
    
//    printf("DICT KEY: %s\nDICT DATA: %d\n", key, line_number);
}

void did_read_identifier(int line_number)
{
    char *string = yylval.stringValue;
    char *key = strcat(string, suffix_for_token(POA_IDENT));
    dict_remove(dict, key);
    
    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_IDENT;
    data->value.stringValue = string;
    
    dict_put(dict, key, (void*)(data));
    
//    printf("DICT KEY: %s\nDICT DATA: %d\n", key, line_number);
}

void did_read_float(int line_number)
{
    char *float_as_string = malloc(20);
    sprintf(float_as_string, "%f", yylval.floatValue);
    char *key = strcat(float_as_string, suffix_for_token(POA_LIT_FLOAT));
    dict_remove(dict, key);
    
    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_FLOAT;
    data->value.floatValue = yylval.floatValue;
    
    dict_put(dict, key, (void*)(data));

//    printf("DICT KEY: %s\nDICT DATA: %d\n", key, line_number);
}

void did_read_string(int line_number)
{
    char *string = yylval.stringValue;
    char *key = strcat(string, suffix_for_token(POA_LIT_STRING));
    dict_remove(dict, key);
    
    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_STRING;
    data->value.stringValue = string;
    
    dict_put(dict, key, (void*)(data));


//    printf("DICT KEY: %s\nDICT DATA: %d\n", key, line_number);
}

void did_read_char(int line_number)
{
    char *character = malloc(2);
    sprintf(character, "%c", yylval.charValue);
    char *key = strcat(character, suffix_for_token(POA_LIT_CHAR));
    dict_remove(dict, key);
    
    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_CHAR;
    data->value.charValue = yylval.charValue;
    
    dict_put(dict, key, (void*)(data));
    
//    printf("DICT KEY: %s\nDICT DATA: %d\n", key, line_number);
}

void did_read_int(int line_number)
{
    char *int_as_string = malloc(20);
    sprintf(int_as_string, "%d", yylval.intValue);
    char *key = strcat(int_as_string, suffix_for_token(POA_LIT_INT));
    dict_remove(dict, key);
    
    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_INT;
    data->value.intValue = yylval.intValue;
    
    dict_put(dict, key, (void*)(data));
    
//    printf("DICT KEY: %s\nDICT DATA: %d\n", key, line_number);
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
        comp_dict_data_t *data = (comp_dict_data_t*)dict->data[i]->value;
        cc_dict_etapa_2_print_entrada(dict->data[i]->key, data->line_number, data->token_type);
    }
  }
}

void main_finalize (void)
{
  // comp_print_table();
}
