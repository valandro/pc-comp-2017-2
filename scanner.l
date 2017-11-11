/*
 Lucas Valandro
 Pietro Degrazia
 */
%{

    #include "cc_misc.h"
    #include "cc_dict.h"
    #include "main.h"
    #include <stdbool.h>
    #include "parser.h" //arquivo automaticamente gerado pelo bison
    struct comp_dict *dict;
%}

%option yylineno

DIGIT [0-9]
SPACE [\ \t\r]
LETTER [a-zA-Z]
UNDERSCORE [_]
OP [+-]
QUODOB [\"]
QUOSIM [\']
CHARACTERS [^ "\n]
CHARS [^ \n]
PUNCTUATION [,;:()\[\]{}+\-\*\/<>=!&$%#\^]
SIGN [+-]
%%
int return TK_PR_INT;
float return TK_PR_FLOAT;
bool return TK_PR_BOOL;
char return TK_PR_CHAR;
string return TK_PR_STRING;
if return TK_PR_IF;
then return TK_PR_THEN;
else return TK_PR_ELSE;
while return TK_PR_WHILE;
do return TK_PR_DO;
input return TK_PR_INPUT;
output return TK_PR_OUTPUT;
return return TK_PR_RETURN;
const return TK_PR_CONST;
static return TK_PR_STATIC;
foreach return TK_PR_FOREACH;
for return TK_PR_FOR;
switch return TK_PR_SWITCH;
case return TK_PR_CASE;
break return TK_PR_BREAK;
continue return TK_PR_CONTINUE;
class return TK_PR_CLASS;
private return TK_PR_PRIVATE;
public return TK_PR_PUBLIC;
protected return TK_PR_PROTECTED;
"<=" return TK_OC_LE;
">=" return TK_OC_GE;
"==" return TK_OC_EQ;
"!=" return TK_OC_NE;
"&&" return TK_OC_AND;
"||" return TK_OC_OR;
"<<" return TK_OC_SL;
">>" return TK_OC_SR;
\n {};
{SPACE}* {};
"//".*  {};
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/] {};
{DIGIT}+ {
    char *text = strdup(yytext);
    int intValue = atoi(text);
    int line_number = yylineno;

    char *suffix = suffix_for_token(POA_LIT_INT);
    char *key = calloc(strlen(text)+20,sizeof(char));
    strcat(key,text);
    strcat(key,suffix);

    dict_remove(dict, key);
    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));

    data->line_number = line_number;
    data->token_type = POA_LIT_INT;
    data->value.intValue = intValue;
    data->value.stringValue = text;

    yylval.valor_lexico = dict_put(dict, key, (void*)(data));

    free(suffix);
    return TK_LIT_INT;
}

{DIGIT}+"."{DIGIT}* {
    char *text = strdup(yytext);
    float floatValue = atof(text);
    int line_number = yylineno;

    char *suffix = suffix_for_token(POA_LIT_FLOAT);
    char *key = calloc(strlen(text)+20,sizeof(char));
    strcat(key,text);
    strcat(key,suffix);

    dict_remove(dict, key);

    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_FLOAT;
    data->value.floatValue = floatValue;
    data->value.stringValue = text;

    yylval.valor_lexico = dict_put(dict, key, (void*)(data));
    free(suffix);
    return TK_LIT_FLOAT;
}

false {
    char *text = strdup(yytext);
    int line_number = yylineno;
    bool boolValue = false;

    char *suffix = suffix_for_token(POA_LIT_BOOL);
    char *key = calloc(26,sizeof(char));
    strcat(key,"false");
    strcat(key,suffix);

    dict_remove(dict, key);

    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_BOOL;
    data->value.boolValue = boolValue;
    data->value.stringValue = text;

    yylval.valor_lexico = dict_put(dict, key, (void*)(data));
    free(suffix);
    return TK_LIT_FALSE;
}

true {
    char *text = strdup(yytext);
    int line_number = yylineno;
    bool boolValue = true;

    char *suffix = suffix_for_token(POA_LIT_BOOL);
    char *key = calloc(25,sizeof(char));
    strcat(key,"true");
    strcat(key,suffix);


    dict_remove(dict, key);

    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_BOOL;
    data->value.boolValue = boolValue;
    data->value.stringValue = text;


    yylval.valor_lexico = dict_put(dict, key, (void*)(data));
    free(suffix);
    return TK_LIT_TRUE;
}

{QUOSIM}{CHARACTERS}?{QUOSIM} {
    char *text = strdup(yytext);
    text++; // Retirando primeira " ou '
    text[strlen(text) - 1] = 0; // Retirando última " ou '

    int line_number = yylineno;

    char *suffix = suffix_for_token(POA_LIT_CHAR);
    char *key = calloc(strlen(text)+20,sizeof(char));
    strcat(key,text);
    strcat(key,suffix);

    dict_remove(dict, key);

    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_CHAR;
    data->value.charValue = text[0];
    data->value.stringValue = text;

    yylval.valor_lexico = dict_put(dict, key, (void*)(data));
    free(suffix);
    return TK_LIT_CHAR;
}

{QUODOB}({LETTER}|{SPACE}|{DIGIT}|{PUNCTUATION}|{UNDERSCORE}|{CHARACTERS})*{QUODOB} {
    int line_number = yylineno;
    char *text = strdup(yytext);
    text++; // Retirando primeira " ou '
    text[strlen(text) - 1] = 0; // Retirando última " ou '

    char *suffix = suffix_for_token(POA_LIT_STRING);
    char *key = calloc(strlen(text)+20,sizeof(char));
    strcat(key,text);
    strcat(key,suffix);

    dict_remove(dict, key);

    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_LIT_STRING;
    data->value.stringValue = text;

    yylval.valor_lexico = dict_put(dict, key, (void*)(data));
    free(suffix);
    return TK_LIT_STRING;
}

({LETTER}|{UNDERSCORE})+(({LETTER}|{DIGIT}|{UNDERSCORE})*) {
    char *text = strdup(yytext);
    int line_number = yylineno;

    char *suffix = suffix_for_token(POA_IDENT);
    char *key = calloc(strlen(text)+20,sizeof(char));
    strcat(key,text);
    strcat(key,suffix);
    dict_remove(dict, key);

    comp_dict_data_t *data = malloc(sizeof(comp_dict_data_t));
    data->line_number = line_number;
    data->token_type = POA_IDENT;
    data->value.stringValue = text;

    yylval.valor_lexico = dict_put(dict, key, (void*)(data));

    free(suffix);

    return TK_IDENTIFICADOR;
}

{PUNCTUATION} return yytext[0];

. return TOKEN_ERRO;

%%
