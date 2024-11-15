// Jorge Garcia, 30547460, jorgegarciag2004@gmail.com
import 'dart:io';

void main(List<String> args) async {
  // Ruta por defecto donde se buscará el archivo .pse
  String defaultFolder = "../pseudocode/";
  // Determina la ruta completa del archivo, usando el nombre en args o 'pseudo.pse' por defecto
  String filePath = "$defaultFolder${args.isNotEmpty ? args[0] : 'pseudo.pse'}";
  
  try {
    // Lee todas las líneas del archivo y las almacena en una lista de strings
    List<String> lines = await File(filePath).readAsLines();
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      // Tokeniza cada línea
      List<Token> tokens = tokenize(line);
      try {
        // Inicializa el índice de tokens para el análisis
        currentIndex = 0;
        // Intenta parsear una expresión completa en la línea
        parseExpression(tokens);
        // Verifica que no queden tokens adicionales después de la expresión
        if (currentIndex < tokens.length) {
          throw "Se esperaba el fin de la expresión pero se encontraron tokens adicionales.";
        }
        print("Línea ${i + 1}: OK"); // La línea es válida
      } catch (e) {
        // Si hay un error, muestra el mensaje y termina la ejecución
        print("Error en línea ${i + 1}: $e");
        return;
      }
    }
    print("Corrida en frío completada sin errores.");
  } catch (e) {
    // Muestra un error si no se pudo leer el archivo
    print("No se pudo leer el archivo: $e");
  }
}

// Clase para representar un token con su tipo y valor
class Token {
  final String type;
  final String value;

  Token(this.type, this.value);

  @override
  String toString() => 'Token($type, $value)';
}

// Función que verifica si un nombre corresponde a una función conocida que requiere paréntesis
bool isFunctionName(String name) {
  return ['sen', 'cos', 'tan', 'sqrt', 'ln', 'f', 'arcsen', 'arccos', 'arctan'].contains(name);
}

// Función que convierte una línea de texto en una lista de tokens
List<Token> tokenize(String line) {
  List<Token> tokens = [];
  // Patrón de expresiones regulares para identificar tokens
  RegExp tokenPatterns = RegExp(r'[a-zA-Z_][a-zA-Z_0-9]*|\d+(\.\d+)?|[\+\-\*/\^\=\(\)]');
  Iterable<Match> matches = tokenPatterns.allMatches(line);

  for (var match in matches) {
    String tokenValue = match.group(0)!;

    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(tokenValue)) {
      tokens.add(Token('NUMBER', tokenValue)); // Número
    } 
    else if (isFunctionName(tokenValue)) {
      tokens.add(Token('FUNCTION', tokenValue)); // Nombre de función
    } 
    else if (RegExp(r'^[a-zA-Z_][a-zA-Z_0-9]*$').hasMatch(tokenValue)) {
      tokens.add(Token('IDENTIFIER', tokenValue)); // Identificador
    } 
    else if (['+', '-', '*', '/', '^', '=', '(', ')'].contains(tokenValue)) {
      tokens.add(Token(tokenValue, tokenValue)); // Operador o paréntesis
    } else {
      throw "Token desconocido: $tokenValue"; // Error si el token no es reconocido
    }
  }
  return tokens;
}

// Índice global que rastrea la posición actual del token en la lista
int currentIndex = 0;

// Obtiene el token actual en la posición de currentIndex
Token? currentToken(List<Token> tokens) {
  if (currentIndex < tokens.length) {
    return tokens[currentIndex];
  }
  return null;
}

// Verifica y consume un token si coincide con el tipo esperado
bool match(List<Token> tokens, String expectedType) {
  if (currentToken(tokens)?.type == expectedType) {
    currentIndex++;
    return true;
  }
  return false;
}

// Parseo de una expresión siguiendo la regla EBNF especificada
void parseExpression(List<Token> tokens) {
  parseTerm(tokens);
  // Lee operadores +, - o = que puedan seguir al término
  while (currentToken(tokens) != null &&
      (currentToken(tokens)!.type == '+' || currentToken(tokens)!.type == '-' || currentToken(tokens)!.type == '=')) {
    currentIndex++;
    parseTerm(tokens);
  }
}

// Parseo de un término que incluye factores y operaciones *, /, o ^
void parseTerm(List<Token> tokens) {
  parseFactor(tokens);
  // Lee operadores *, / o ^ que puedan seguir al factor
  while (currentToken(tokens) != null &&
      (currentToken(tokens)!.type == '*' || currentToken(tokens)!.type == '/' || currentToken(tokens)!.type == '^')) {
    currentIndex++;
    parseFactor(tokens);
  }
}

// Parseo de un factor, que puede ser un número, variable, función o expresión entre paréntesis
void parseFactor(List<Token> tokens) {
  if (match(tokens, '-')) {
    parseFactor(tokens); // Factor negativo
  } 
  else if (match(tokens, 'NUMBER') || match(tokens, 'IDENTIFIER')) {
    // Número o variable válidos, no se requiere acción adicional
  } 
  else if (currentToken(tokens)?.type == 'FUNCTION') {
    parseFunction(tokens); // Parseo de una función
  } 
  else if (match(tokens, '(')) {
    parseExpression(tokens); // Parseo de una expresión entre paréntesis
    if (!match(tokens, ')')) {
      throw "Se esperaba ')' al final de la expresión."; // Error si no se encuentra ')'
    }
  } 
  else {
    throw "Token inesperado: ${currentToken(tokens)?.value ?? 'fin de la expresión'}."; // Error de token inesperado
  }
}

// Parseo de una función, verifica paréntesis y parsea la expresión interna
void parseFunction(List<Token> tokens) {
  String functionName = currentToken(tokens)?.value ?? "función desconocida";
  currentIndex++; // Avanza el token de la función
  if (!match(tokens, '(')) {
    throw "Se esperaba '(' después de la función '$functionName'."; // Error si falta '('
  }
  parseExpression(tokens); // Parseo de la expresión dentro de la función
  if (!match(tokens, ')')) {
    throw "Se esperaba ')' al final de la función '$functionName'."; // Error si falta ')'
  }
}
