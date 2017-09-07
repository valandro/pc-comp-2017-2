/*
  Coloque aqui o identificador do grupo e dos seus membros
*/
%{
#include "parser.h" //arquivo automaticamente gerado pelo bison
%}
%option yylineno
%%
int return TK_PR_INT;
float return TK_PR_FLOAT;
bool
char
string
if return TK_PR_IF;
then return TK_PR_THEN;
else return TK_PR_ELSE;
while
do
input
output
return
const
static
foreach
for
switch
case
break
continue
class
private
public
protected
\n
%%
