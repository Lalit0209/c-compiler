yacc -d sym.y
lex sym.l
gcc -g y.tab.c lex.yy.c -ll -o SymbolTable
clear
yacc -d AST.y
lex AST.l
gcc -g y.tab.c lex.yy.c -ll -o AST
clear
yacc -d icg.y
lex icg.l
gcc -g y.tab.c lex.yy.c -ll -o ICG
clear
yacc -d Grammar.y
lex Grammar.l
gcc -g y.tab.c lex.yy.c -ll -o Grammar
clear

echo "---------------"
echo "MINI C COMPILER"
echo "---------------"
echo "Supported constructs : For loop, Ternary Operators and Switch Case"

echo "Use ./Grammar to parse the Grammar"
echo "Use ./SymbolTable to generate the Symbol Table and Show Errors"
echo "Use ./AST to generate Abstract the Syntax Tree"
echo "Use ./ICG to generate the Intermediate Code"


