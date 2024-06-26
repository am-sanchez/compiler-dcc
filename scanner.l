/* File:  scanner.l
 * ----------------
 * Lex input file to generate the scanner for the compiler.
 */

%{

/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function. Add other header file inclusions
 * or C++ variable declarations/prototypes that are needed by your code here.
 */

#include <string>
#include <iomanip>
#include <cmath>
#include <string_view>
#include <iostream>
#include <sstream>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"

/* Global variable: yylval
 * -----------------------
 * This global variable is how we get attribute information about the token
 * just scanned to the client. The scanner sets the global variable
 * appropriately and since it's global the client can just read it.  In the
 * future, this variable will be declared for us in the y.tab.c file
 * produced by Yacc, but for now, we declare it manually.
 */
YYSTYPE yylval;  // manually declared for pp1, later Yacc provides

/* Global variable: yylloc
 * -----------------------
 * This global variable is how we get position information about the token
 * just scanned to the client. (Operates similarly to yylval above)
 */
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

/* Macro: YY_USER_ACTION
 * ---------------------
 * This flex built-in macro can be defined to provide an action which is
 * always executed prior to any matched rule's action. Basically, it is
 * a way of having a piece of code common to all actions factored out to
 * this routine.  We already defined it for you and left the empty
 * function DoBeforeEachAction ready for your use as needed. It will
 * be called once for each pattern scanned from the file, before
 * executing its action.
 */
static void DoBeforeEachAction();
#define YY_USER_ACTION DoBeforeEachAction();

/* Number of columns per tab, i.e. '\t' */
static const int TAB_SIZE = 8;

int numLines = 0, col = 0;
std::stringstream stream;

/*
 * Not sure what to allow for max string constant size_t
 * since MAX_SIZE produces bad malloc warnings when
 * used to instantiate char array.
 */
static const size_t BUFF_SIZE {static_cast<size_t>(pow(2,16))};
auto copiedString {std::make_unique<char[]>(BUFF_SIZE)};

%}

 /* The section before the first %% is the Definitions section of the lex
  * input file. Here is where you set options for the scanner, define lex
  * states, and can set up definitions to give names to regular expressions
  * as a simple substitution mechanism that allows for more readable
  * entries in the Rules section later.
  */

/* Disable yywrap to prevent the need for linking the Flex library */
%option noyywrap

IDENT    [[:alpha:]][[:alnum:]_]*
KEYWORD  void|int|double|bool|string|class|interface|null|this|extends|implements|for|while|if|else|return|break|new|NewArray|Print|ReadInteger|ReadLine
SINGLEOP [+\-*/%<>=!;,\.\[\]\(\)\{\}]
DOUBLECONST [[:digit:]]+\.[[:digit:]]+
EXPONENT [[:digit:]]+\.[[:digit:]]*[Ee][\+\-]?[[:digit:]]+

/*
 * For unterminated string, match a starting double quote, then
 * as few non-double quote, non-newlines as possible.
 */
UNTERMSTRING \"[^"^\n]*?

/*
 * Exclusive <start condition> for active comments
 */
%x activeComment

%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section.
  */

<activeComment><<EOF>>  {
                            ReportError::UntermComment();
                            yyterminate();
                        }
\/\*        {
                // Begin Multiline comment
                // If starting a multi-line comment, increment line number.
                BEGIN activeComment;
            }

<activeComment>\*\/ {
                        // End Multiline comment, return to normal matching mode
                        BEGIN INITIAL;
                    }
<activeComment>\t
<activeComment>\n
<activeComment>.  /* consume characters while multiline comment is active */

\/\/.*$       /* consume single line comments */
\"[^\n"]*?\"  {
                // Handle String Constants
                /*
                 * Regex match description:
                 * Match quote, then optionally, as few non-newline,
                 * non-quotes until next quote is encountered
                 */
                // Clear instantiated char array
                memset(copiedString.get(), 0, BUFF_SIZE);
                memcpy(copiedString.get(), yytext, yyleng);
                yylval.stringConstant = copiedString.get();

                return T_StringConstant;
            }
{UNTERMSTRING}  {
                    ReportError::UntermString(&yylloc, yytext);
                }
0[xX][[:xdigit:]]+ { stream >> hex >> yylval.integerConstant; return T_IntConstant; }
"<="            { return T_LessEqual; }
">="            { return T_GreaterEqual; }
"=="            { return T_Equal; }
"!="            { return T_NotEqual; }
"&&"            { return T_And; }
"||"            { return T_Or; }
"[]"            { return T_Dims; }
{SINGLEOP}      { return static_cast<int>(*yytext); }
[[:digit:]]+    { stream >> yylval.integerConstant; return T_IntConstant; }
{EXPONENT}  {
                std::string number;
                std::string suffix;
                bool positiveExp {true};
                bool foundE {false};
                for (auto item : std::string_view(yytext))
                {
                    const bool chIsDigit {item != '.' && item != '+' && item != '-' && item != 'E' && item != 'e'};
                    if (chIsDigit || item == '.')
                    {
                        if (!foundE)
                        {
                            number += item;
                        }
                        else
                        {
                            suffix += item;
                        }
                    }
                    else if (item == '+') { positiveExp = true; }
                    else if (item == '-') { positiveExp = false; }
                    else if (item == 'E' || item == 'e') { foundE = true; }
                    else { std::cout << "Unrecognized EXPONENT character" << item; }
                }
                /* Convert decimal and exponent value to double for pow() */
                const double dec {std::stod(number)};
                const double exp {std::stod(suffix)};

                /* Caluclate value with exponent */
                double finalVal {dec * std::pow(10,exp)};

                /* For negative exponents, take reciprocal */
                if (!positiveExp) {finalVal = 1.0/finalVal; }

                yylval.doubleConstant = finalVal;
                return T_DoubleConstant;
            }

{DOUBLECONST}   {
                    yylval.doubleConstant = stod(yytext);
                    return T_DoubleConstant;
                }
"if"            { return T_If; }
"int"           { return T_Int; }
"for"           { return T_For; }
"new"           { return T_New; }
"bool"          { return T_Bool; }
"else"          { return T_Else; }
"null"          { return T_Null; }
"this"          { return T_This; }
"true"          { yylval.boolConstant = true; return T_BoolConstant;}
"void"          { return T_Void; }
"break"         { return T_Break; }
"class"         { return T_Class; }
"false"         { yylval.boolConstant = false; return T_BoolConstant;}
"while"         { return T_While; }
"Print"         { return T_Print; }
"double"        { return T_Double; }
"return"        { return T_Return; }
"string"        { return T_String; }
"extends"       { return T_Extends; }
"NewArray"      { return T_NewArray; }
"ReadLine"      { return T_ReadLine; }
"interface"     { return T_Interface; }
"implements"    { return T_Implements; }
"ReadInteger"   { return T_ReadInteger; }
{IDENT}     {
                // Clear dynamic string buffer
                memset(copiedString.get(), 0, BUFF_SIZE);

                // Copy lexeme to dynamic string buffer
                memcpy(copiedString.get(), yytext, yyleng);

                // Copy contents of dynamic string buffer into Union, up to max length (31)
                memcpy(yylval.identifier, copiedString.get(), MaxIdentLen);

                // Append null character to CString in Union
                yylval.identifier[MaxIdentLen] = '\0';

                if (yyleng > MaxIdentLen)
                {
                    ReportError::LongIdentifier(&yylloc, yytext);
                }

                return T_Identifier;
            }
[\t]        /* consume tabs */
[\r]        /* consume carriage return */
[\n]        /* consume newlines (line feed)*/
[ ]+        /* consume spaces */
.           {
                ReportError::UnrecogChar(&yylloc, yytext[0]);
            }
%%
/* The closing %% above marks the end of the Rules section and the beginning
 * of the User Subroutines section. All text from here to the end of the
 * file is copied verbatim to the end of the generated lex.yy.c file.
 * This section is where you put definitions of helper functions.
 */

/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yy_flex_debug that controls whether flex prints debugging information
 * about each token and what rule was matched. If set to false, no information
 * is printed. Setting it to true will give you a running trail that might
 * be helpful when debugging your scanner. Please be sure the variable is
 * set to false when submitting your final version.
 */
void InitScanner()
{
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = false;
    numLines = 1;
}

/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
    // Clear yylval's buffer for each token
    memset(&yylval,0, sizeof(yylval));

    /*
     * Swap used stream with default constructed sstream.
     * This clears the stream and any error state.
     * Equivalent to stream.str("") && stream.clear();
     */
    std::stringstream().swap(stream);
    stream << yytext;

    // Update line number
    yylloc.first_line = numLines;

    // Handle column position
    yylloc.first_column = col + 1;

    if (yyleng >= 0 && yytext[yyleng-1] == '\n')
    {
        /*
         * Reset column number and increment line number if
         * the last character in input is a newline character
         */
        col = 0; ++numLines;
    }
    else if (yyleng >= 1 && yytext[0] == '\t')
    {
        // Increment column number by preset tab size
        col += TAB_SIZE;
    }
    else
    {
        // Update current column by input length
        col += yyleng;
    }
    yylloc.last_column = col;
}
