%option yylineno

%{
	#include<stdio.h>
	#include<string.h>
	
	struct ConstantTable{
		char constant_name[100];
		char constant_type[100];
		int exist;
		int line_number;
	}CT[1000];
	
	struct SymbolTable{
		char symbol_name[100];
		char symbol_type[100];
		int exist;
		int line_number;
	}ST[1000];
	
	unsigned long hash(unsigned char *str)
	{
		unsigned long hash = 5381;
		int c;

		while (c = *str++)
			hash = ((hash << 5) + hash) + c;

		return hash;
	}
	
	int search_ConstantTable(char* str){
		unsigned long temp_val = hash(str);
		int val = temp_val%1000;
		
		if(CT[val].exist == 0){
			return 0;
		}
		
		else if(strcmp(CT[val].constant_name, str) == 0)
		{
			return 1;
		}
		else
		{
			for(int i = val+1 ; i!=val ; i = (i+1)%1000)
			{
				if(strcmp(CT[i].constant_name,str)==0)
				{
					return 1;
				}
			}
			return 0;
		}
	}

	
	int search_SymbolTable(char* str){
		unsigned long temp_val = hash(str);
		int val = temp_val%1000;
		
		if(ST[val].exist == 0){
			return 0;
		}
		
		else if(strcmp(ST[val].symbol_name, str) == 0)
		{
			return 1;
		}
		else
		{
			for(int i = val+1 ; i!=val ; i = (i+1)%1000)
			{
				if(strcmp(ST[i].symbol_name,str)==0)
				{
					return 1;
				}
			}
			return 0;
		}
	}
	
	
	void insert_ConstantTable(char* name, char* type, int line){
		int index = 0;
		 if(search_ConstantTable(name)){
			return;
		}
		else{
			unsigned long temp_val = hash(name);
			int val = temp_val%1000;
			if(CT[val].exist == 0){
				strcpy(CT[val].constant_name, name);
				strcpy(CT[val].constant_type, type);
				CT[val].line_number = line;
				CT[val].exist = 1;
				return;
			}
			
			for(int i = val+1; i != val; i = (i+1)%1000){
				if(CT[i].exist == 0){
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
	
	void insert_SymbolTable(char* name, char* type, int line){
		int index = 0;
		//printf("BBBB");
		 if(search_SymbolTable(name)){
			
			return;
		}
		else{
			unsigned long temp_val = hash(name);
			int val = temp_val%1000;
			if(ST[val].exist == 0){
				strcpy(ST[val].symbol_name, name);
				strcpy(ST[val].symbol_type, type);
				ST[val].exist = 1;
				ST[val].line_number = line;
				return;
			}
			
			for(int i = val+1; i != val; i = (i+1)%1000){
				if(ST[i].exist == 0){
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

	// Printing Tables
	void printConstantTable(){
		printf("CONSTANT TABLE:\n");

		printf("| Value of Constant\t\t| Type of Constant\t\n");
		for(int i = 0; i < 1000; ++i){
			if(CT[i].exist){
				printf("%s\t%s\t%d\n", CT[i].constant_name, CT[i].constant_type, CT[i].line_number);
			}
		}
	}

	void printSymbolTable(){
		printf("SYMBOL TABLE:\n");
		printf("| Symbols\t\t| Type of Symbol\t\n");
		for(int i = 0; i < 1000; ++i){
			if(ST[i].exist){
				printf("%s\t%s\t%d\n", ST[i].symbol_name, ST[i].symbol_type, ST[i].line_number);
			}
		}
	}

	
%}

/* Regular definitions */
num              	[0-9]
alpha              	[a-zA-Z]
alphanum            {alpha}|{num}
keyword             char|int|main|float|double|short|long|unsigned|signed|main|while|for|break|if|else|continue|return|void|struct|typedef|enum|static
escape_sequences    0|a|b|f|n|r|t|v|"\\"|"\""|"\'"
ws  				[ \t\r\f\v]+

%x MLCOMMENT





/* Pattern Matching Rules */
%%
	int nested_count = 0;
	int check_nested = 0;
\n                                           {}
" "                                          {}
"#include"[ ]*"<"{alpha}({alphanum})*".h>"   { printf("Line No. %d PREPROCESSOR DIRECTIVE - %s\n", yylineno, yytext); }
"#define"[ ]+(_|{alpha})({alphanum})*[ ]*(.)+   { printf("Line No. %d PREPROCESSOR DIRECTIVE - %s\n", yylineno, yytext); }

"//".*                                       { printf("Line No. %d SINGLE LINE COMMENT - %s\n", yylineno, yytext); }

"/*"             							 { BEGIN MLCOMMENT; }
<MLCOMMENT>"/*"							 { ++nested_count; 
												check_nested = 1;
											 }	
<MLCOMMENT>"*"+"/"        					 { if (nested_count) --nested_count;
											   else{ if(check_nested){
														printf("Line No. %d NESTED COMMENT\n", yylineno);
														check_nested = 0;
														BEGIN INITIAL;
														}
													 else{
														printf("Line No. %d MULTI LINE COMMENT\n", yylineno);
														BEGIN INITIAL;
													}
											    } 
											 }
<MLCOMMENT>"*"+           					 ; 
<MLCOMMENT>[^/*\n]+						 ;
<MLCOMMENT>[/]    							 ;
<MLCOMMENT>\n     							 ;
<MLCOMMENT><<EOF>>							 { printf("Line No. %d ERROR: MULTI LINE COMMENT NOT CLOSED\n", yylineno); return 0;}


("\"")[^\n\"]*("\"")                         { 
                                                printf("Line No. %d STRING - %s\n", yylineno, yytext); 
                                                insert_ConstantTable(yytext, "String", yylineno);
                                             }
("\"")[^\n\"]*                               { printf("Line No. %d ERROR: UNCLOSED STRING - %s\n", yylineno, yytext); return 0;}

("\'")(("\\"({escape_sequences}))|.)("\'")   { 
                                                printf("Line No. %d CHARACTER - %s\n", yylineno, yytext); 
                                                insert_ConstantTable(yytext, "Character", yylineno);
                                             }

("\'")(((("\\")[^0abfnrtv\\\"\'][^\n\']*))|[^\n\''][^\n\'']+)("\'") { 
                                               printf("Line No. %d ERROR: NOT A CHARACTER - %s\n", yylineno, yytext); return 0; }

{keyword}/[ ]*[(]?                           { 
                                                printf("Line No. %d KEYWORD - %s\n", yylineno, yytext); 
                                             }
											 
{ws}										 ;

#include[/"<][ ]*{alpha}+\.h[/">]   {
                                                printf("Line No. %d HEADER - %s\n", yylineno, yytext);                                                 
                                             }


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


((_|{alpha})({alphanum}|_)*)[ ]*[(]		 	{	printf("Line No. %d FUNCTION - %s\n", yylineno, yytext);
												insert_SymbolTable(yytext, "Function", yylineno);
											}


(_|{alpha})({alphanum}|_)*                  { printf("Line No. %d IDENTIFIER - %s\n", yylineno, yytext);
                                              insert_SymbolTable(yytext, "Identfier", yylineno);
                                            }
[+-]?{num}+                                 { printf("Line No. %d INTEGER - %s\n", yylineno, yytext);
                                              insert_ConstantTable(yytext, "Integer", yylineno);
                                            }
[+-]?{num}+\.({num}+)?                    	{ printf("Line No. %d FLOATING POINT - %s\n", yylineno, yytext); 
                                              insert_ConstantTable(yytext, "Floating Point", yylineno);
                                            }

"["                                          { printf("Line No. %d LEFT BRACKET - %s\n", yylineno, yytext); }
"]"                                          { printf("Line No. %d RIGHT BRACKET - %s\n", yylineno, yytext); }
"("                                          { printf("Line No. %d LEFT PARENTHESIS - %s\n", yylineno, yytext); }
")"                                          { printf("Line No. %d RIGHT PARENTHESIS - %s\n", yylineno, yytext); }
"{"                                          { printf("Line No. %d LEFT BRACE - %s\n", yylineno, yytext); }
"}"                                          { printf("Line No. %d RIGHT BRACE - %s\n", yylineno, yytext); }
","                                          { printf("Line No. %d COMMA - %s\n", yylineno, yytext); }
";"       										{ printf("Line No. %d SEMICOLON - %s\n", yylineno, yytext); }
[0-9]*[_a-zA-Z0-9]*							 {printf("Line No. %d ERROR ILLEGAL VARIABLE DECLARATION - %s\n", yylineno, yytext);
												return 0;}
.											 { if(yytext[0] == '#')
													printf("Line No. %d PREPROCESSOR ERROR - %s\n", yylineno, yytext);
											   else
													printf("Line No. %d ERROR ILLEGAL CHARACTER - %s\n", yylineno, yytext);
											  return 0;}

%%

int yywrap(){
	return 1;
}

int main()
{
	extern FILE *yyin;
	yyin = fopen("test4.c","r");
	yylex();
	printf("--------------------------------------------------------------------------------------\n");
	printf("CONSTANT TABLE\n");
	printConstantTable();
	printf("--------------------------------------------------------------------------------------\n");
	printf("SYMBOL TABLE\n");
	printSymbolTable();
	return 0;
}
		
