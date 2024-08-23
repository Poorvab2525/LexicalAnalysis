%option yylineno

%{
	#include <stdio.h>
	#include <string.h>
	
	// Structure to store information about constants
	struct ConstantTable {
		char constant_name[100];  // Name of the constant
		char constant_type[100];  // Type of the constant (e.g., integer, float, etc.)
		int exist;                // Flag to check if the constant exists (1 if exists, 0 otherwise)
		int line_number;          // Line number where the constant is found
	} CT[1000];
	
	// Structure to store information about symbols (e.g., variables, functions)
	struct SymbolTable {
		char symbol_name[100];   // Name of the symbol
		char symbol_type[100];   // Type of the symbol (e.g., identifier, function, etc.)
		int exist;               // Flag to check if the symbol exists (1 if exists, 0 otherwise)
		int line_number;         // Line number where the symbol is found
	} ST[1000];
	
	// Hash function for hashing strings
	unsigned long hash(unsigned char *str) {
		unsigned long hash = 5381;
		int c;

		// Generate hash value
		while (c = *str++) {
			hash = ((hash << 5) + hash) + c;
		}

		return hash;
	}
	
	// Search for a constant in the constant table
	int search_ConstantTable(char* str) {
		unsigned long temp_val = hash((unsigned char*)str);
		int val = temp_val % 1000;

		// Check if the constant is present at the hashed index
		if (CT[val].exist == 0) {
			return 0;
		} else if (strcmp(CT[val].constant_name, str) == 0) {
			return 1;
		} else {
			// Linear probing for collision resolution
			for (int i = val + 1; i != val; i = (i + 1) % 1000) {
				if (strcmp(CT[i].constant_name, str) == 0) {
					return 1;
				}
			}
			return 0;
		}
	}

	// Search for a symbol in the symbol table
	int search_SymbolTable(char* str) {
		unsigned long temp_val = hash((unsigned char*)str);
		int val = temp_val % 1000;

		// Check if the symbol is present at the hashed index
		if (ST[val].exist == 0) {
			return 0;
		} else if (strcmp(ST[val].symbol_name, str) == 0) {
			return 1;
		} else {
			// Linear probing for collision resolution
			for (int i = val + 1; i != val; i = (i + 1) % 1000) {
				if (strcmp(ST[i].symbol_name, str) == 0) {
					return 1;
				}
			}
			return 0;
		}
	}
	
	// Insert a constant into the constant table
	void insert_ConstantTable(char* name, char* type, int line) {
		int index = 0;
		if (search_ConstantTable(name)) {
			return;  // Constant already exists, no need to insert
		} else {
			unsigned long temp_val = hash((unsigned char*)name);
			int val = temp_val % 1000;

			// Insert at the hashed index if it's free
			if (CT[val].exist == 0) {
				strcpy(CT[val].constant_name, name);
				strcpy(CT[val].constant_type, type);
				CT[val].line_number = line;
				CT[val].exist = 1;
				return;
			}
			
			// Linear probing for collision resolution
			for (int i = val + 1; i != val; i = (i + 1) % 1000) {
				if (CT[i].exist == 0) {
					index = i;
					break;
				}
			}
			strcpy(CT[index].constant_name, name);
			strcpy(CT[index].constant_type, type);
			CT[index].line_number = line;
			CT[index].exist = 1;			
		}
	}
	
	// Insert a symbol into the symbol table
	void insert_SymbolTable(char* name, char* type, int line) {
		int index = 0;
		if (search_SymbolTable(name)) {
			return;  // Symbol already exists, no need to insert
		} else {
			unsigned long temp_val = hash((unsigned char*)name);
			int val = temp_val % 1000;

			// Insert at the hashed index if it's free
			if (ST[val].exist == 0) {
				strcpy(ST[val].symbol_name, name);
				strcpy(ST[val].symbol_type, type);
				ST[val].line_number = line;
				ST[val].exist = 1;
				return;
			}
			
			// Linear probing for collision resolution
			for (int i = val + 1; i != val; i = (i + 1) % 1000) {
				if (ST[i].exist == 0) {
					index = i;
					break;
				}
			}
			strcpy(ST[index].symbol_name, name);
			strcpy(ST[index].symbol_type, type);
			ST[index].line_number = line;
			ST[index].exist = 1;			
		}
	}

	// Print the constant table
	void printConstantTable() {
		printf("CONSTANT TABLE:\n");
		printf("| Value of Constant\t\t| Type of Constant\t\n");

		for (int i = 0; i < 1000; ++i) {
			if (CT[i].exist) {
				printf("%s\t%s\t%d\n", CT[i].constant_name, CT[i].constant_type, CT[i].line_number);
			}
		}
	}

	// Print the symbol table
	void printSymbolTable() {
		printf("SYMBOL TABLE:\n");
		printf("| Symbols\t\t| Type of Symbol\t\n");

		for (int i = 0; i < 1000; ++i) {
			if (ST[i].exist) {
				printf("%s\t%s\t%d\n", ST[i].symbol_name, ST[i].symbol_type, ST[i].line_number);
			}
		}
	}

%}

/* Regular definitions */
num              	[0-9]                         // Matches digits
alpha              	[a-zA-Z]                     // Matches alphabetic characters
alphanum            {alpha}|{num}                 // Matches alphanumeric characters
keyword             char|int|main|float|double|short|long|unsigned|signed|main|while|for|break|if|else|continue|return|void|struct|typedef|enum|static  // Matches C language keywords
escape_sequences    0|a|b|f|n|r|t|v|"\\"|"\""|"\'"  // Matches escape sequences in character literals
ws  				[ \t\r\f\v]+                 // Matches whitespace characters

%x MLCOMMENT          // Start state for multi-line comments

/* Pattern Matching Rules */
%%
	int nested_count = 0;
	int check_nested = 0;

\n                                           {}  // Ignore newlines
" "                                          {}  // Ignore spaces

"#include"[ ]*"<"{alpha}({alphanum})*".h>"   { 
    // Handle #include directives
    printf("Line No. %d PREPROCESSOR DIRECTIVE - %s\n", yylineno, yytext); 
}
"#define"[ ]+(_|{alpha})({alphanum})*[ ]*(.)+   { 
    // Handle #define directives
    printf("Line No. %d PREPROCESSOR DIRECTIVE - %s\n", yylineno, yytext); 
}

"//".*                                       { 
    // Handle single-line comments
    printf("Line No. %d SINGLE LINE COMMENT - %s\n", yylineno, yytext); 
}

"/*"             							 { 
    // Start multi-line comment
    BEGIN MLCOMMENT; 
}
<MLCOMMENT>"/*"							 { 
    // Handle nested multi-line comment start
    ++nested_count; 
    check_nested = 1;
}
<MLCOMMENT>"*"+"/"        					 { 
    // Handle end of multi-line comment
    if (nested_count) --nested_count;
    else { 
        if (check_nested) {
            // Nested comment detected
            printf("Line No. %d NESTED COMMENT\n", yylineno);
            check_nested = 0;
            BEGIN INITIAL;
        } else {
            // End of multi-line comment
            printf("Line No. %d MULTI LINE COMMENT\n", yylineno);
            BEGIN INITIAL;
        }
    } 
}
<MLCOMMENT>"*"+           					 ; 
<MLCOMMENT>[^/*\n]+						 ; 
<MLCOMMENT>[/]    							 ; 
<MLCOMMENT>\n     							 ; 
<MLCOMMENT><<EOF>>							 { 
    // Handle unclosed multi-line comment at EOF
    printf("Line No. %d ERROR: MULTI LINE COMMENT NOT CLOSED\n", yylineno); 
    return 0;
}

 ("\"")[^\n\"]*("\"")                         { 
                                                printf("Line No. %d STRING - %s\n", yylineno, yytext); 
                                                insert_ConstantTable(yytext, "String", yylineno);
                                             }
    // Match an unclosed string literal
    ("\"")[^\n\"]*                               { printf("Line No. %d ERROR: UNCLOSED STRING - %s\n", yylineno, yytext); return 0;}

    // Match a character literal
    ("\')(("\\"({escape_sequences}))|.)("\'")   { 
                                                printf("Line No. %d CHARACTER - %s\n", yylineno, yytext); 
                                                insert_ConstantTable(yytext, "Character", yylineno);
                                             }

    // Match an invalid character literal
    ("\')(("\\)[^0abfnrtv\\\"\'][^\n\']*))|[^\n\''][^\n\'']+)("\'") { 
                                               printf("Line No. %d ERROR: NOT A CHARACTER - %s\n", yylineno, yytext); return 0; }

    // Match a keyword or function declaration
    {keyword}/[ ]*[(]?                           { 
                                                printf("Line No. %d KEYWORD - %s\n", yylineno, yytext); 
                                             }
    
    // Match whitespace
    {ws}										 ;

    // Match header file inclusion
    #include[/"<][ ]*{alpha}+\.h[/">]   {
                                                printf("Line No. %d HEADER - %s\n", yylineno, yytext);                                                 
                                             }

    // Match various operators
    "+"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "-"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "++"										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "--"										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "!"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "~"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "*"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "/"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "%"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    ">>"										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "<<"										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "&"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "^"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    \|											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    \|\|										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "="											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    ">"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "<"											 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    ">="										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "<="										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "=="										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }
    "!="										 { printf("Line No. %d OPERATOR - %s\n", yylineno, yytext); }

    // Match function definitions
    ((_|{alpha})({alphanum}|_)*)[ ]*[(]		 	{	
                                                printf("Line No. %d FUNCTION - %s\n", yylineno, yytext);
                                                insert_SymbolTable(yytext, "Function", yylineno);
                                            }

    // Match identifiers
    (_|{alpha})({alphanum}|_)*                  { 	
                                                if (strlen(yytext) > 32) {
                                                    printf("error ! mre no. of characters...");
                                                    return 0;
                                                }
                                                printf("Line No. %d IDENTIFIER - %s\n", yylineno, yytext);
                                                insert_SymbolTable(yytext, "Identifier", yylineno);
                                            }

    // Match integers
    [+-]?{num}+                                 { 
                                                printf("Line No. %d INTEGER - %s\n", yylineno, yytext);
                                                insert_ConstantTable(yytext, "Integer", yylineno);
                                            }

    // Match floating-point numbers
    [+-]?{num}+\.({num}+)?                    	{ 
                                                printf("Line No. %d FLOATING POINT - %s\n", yylineno, yytext); 
                                                insert_ConstantTable(yytext, "Floating Point", yylineno);
                                            }

    // Match brackets and braces
    "["                                          { printf("Line No. %d LEFT BRACKET - %s\n", yylineno, yytext); }
    "]"                                          { printf("Line No. %d RIGHT BRACKET - %s\n", yylineno, yytext); }
    "("                                          { printf("Line No. %d LEFT PARENTHESIS - %s\n", yylineno, yytext); }
    ")"                                          { printf("Line No. %d RIGHT PARENTHESIS - %s\n", yylineno, yytext); }
    "{"                                          { printf("Line No. %d LEFT BRACE - %s\n", yylineno, yytext); }
    "}"                                          { printf("Line No. %d RIGHT BRACE - %s\n", yylineno, yytext); }
    ","                                          { printf("Line No. %d COMMA - %s\n", yylineno, yytext); }
    ";"       									 { printf("Line No. %d SEMICOLON - %s\n", yylineno, yytext); }

    // Match illegal variable declarations
    [0-9]*[_a-zA-Z0-9]*						 {printf("Line No. %d ERROR ILLEGAL VARIABLE DECLARATION - %s\n", yylineno, yytext);
												return 0;}

    // Match any illegal character
    .											 { 
                                                if(yytext[0] == '#')
                                                    printf("Line No. %d PREPROCESSOR ERROR - %s\n", yylineno, yytext);
                                                else
                                                    printf("Line No. %d ERROR ILLEGAL CHARACTER - %s\n", yylineno, yytext);
                                                return 0;
                                            }

%%

// Define the function that handles the end of the file
int yywrap(){
    return 1;
}

// Main function to start the lexer
int main()
{
    extern FILE *yyin;
    yyin = fopen("test4.c","r");  // Open the input file
    yylex();  // Start lexical analysis
    printf("--------------------------------------------------------------------------------------\n");
    printf("CONSTANT TABLE\n");
    printConstantTable();  // Print the constant table
    printf("--------------------------------------------------------------------------------------\n");
    printf("SYMBOL TABLE\n");
    printSymbolTable();  // Print the symbol table
    return 0;
}
