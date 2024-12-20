// Jorge Garcia, 30547460, jorgegarciag2004@gmail.com
import 'dart:io';

void main(List<String> args) async {
  // Ruta por defecto
  String defaultFolder = "../pseudocode/";
  String filePath = "$defaultFolder${args.isNotEmpty ? args[0] : 'pseudo.pse'}";

  try {
    List<String> lines = await File(filePath).readAsLines();
    String currentSection = "";
    int lineNumber = 0;

    for (String line in lines) {
      lineNumber++;
      line = line.trim();

      if (line.isEmpty) {
        print("Línea $lineNumber: OK (Línea vacía ignorada)");
        continue;
      }

      try {
        if (line.startsWith("Algoritmo")) {
          // Validar que se define un nombre de algoritmo.
          if (!RegExp(r"^Algoritmo\s+\w+$").hasMatch(line)) {
            throw "Se esperaba un identificador al inicio de la expresión.";
          }
          currentSection = "Algoritmo";
          print("Línea $lineNumber: OK (Definición del algoritmo)");
        } else if (['Declaración', 'Constantes', 'Tipos', 'Variables', 'Inicio', 'Fin']
            .contains(line)) {
          if (currentSection == "Inicio" && line == "Variables") {
            // Permitir "Variables" como parte del bloque de inicio
            print("Línea $lineNumber: OK (Sección 'Variables' dentro de 'Inicio')");
          } else {
            currentSection = line;
            print("Línea $lineNumber: OK (Sección '$currentSection' reconocida)");
          }
        } else if (line.startsWith("{") && line.endsWith("}")) {
          // Validar bloques genéricos {contenido}
          if (!RegExp(r"^\{[^{}]*\}$").hasMatch(line)) {
            throw "Formato incorrecto para bloque '{...}'.";
          }
          print("Línea $lineNumber: OK (Bloque válido)");
        } else {
          // Validar expresiones normales
          List<Token> tokens = tokenize(line);
          currentIndex = 0;
          parseExpression(tokens);
          if (currentIndex < tokens.length) {
            throw "Se esperaba el fin de la expresión pero se encontraron tokens adicionales.";
          }
          print("Línea $lineNumber: OK (Expresión válida)");
        }
      } catch (e) {
        print("Error en línea $lineNumber: $e");
        return;
      }
    }

    if (currentSection != "Fin") {
      throw "Se esperaba 'Fin' al final del algoritmo.";
    }

    print("Corrida en frío completada sin errores.");
  } catch (e) {
    print("No se pudo leer el archivo: $e");
  }
}

// Resto del código de tokenización y análisis permanece igual
class Token {
  final String type;
  final String value;

  Token(this.type, this.value);

  @override
  String toString() => 'Token($type, $value)';
}

bool isFunctionName(String name) {
  return ['sen', 'cos', 'tan', 'sqrt', 'ln', 'f', 'arcsen', 'arccos', 'arctan'].contains(name);
}

List<Token> tokenize(String line) {
  List<Token> tokens = [];
  RegExp tokenPatterns = RegExp(r'[a-zA-Z_][a-zA-Z_0-9]*|\d+(\.\d+)?|[\+\-\*/\^\=\(\)]');
  Iterable<Match> matches = tokenPatterns.allMatches(line);

  for (var match in matches) {
    String tokenValue = match.group(0)!;

    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(tokenValue)) {
      tokens.add(Token('NUMBER', tokenValue));
    } else if (isFunctionName(tokenValue)) {
      tokens.add(Token('FUNCTION', tokenValue));
    } else if (RegExp(r'^[a-zA-Z_][a-zA-Z_0-9]*$').hasMatch(tokenValue)) {
      tokens.add(Token('IDENTIFIER', tokenValue));
    } else if (['+', '-', '*', '/', '^', '=', '(', ')'].contains(tokenValue)) {
      tokens.add(Token(tokenValue, tokenValue));
    } else {
      throw "Token desconocido: $tokenValue";
    }
  }
  return tokens;
}

int currentIndex = 0;

Token? currentToken(List<Token> tokens) {
  if (currentIndex < tokens.length) {
    return tokens[currentIndex];
  }
  return null;
}

bool match(List<Token> tokens, String expectedType) {
  if (currentToken(tokens)?.type == expectedType) {
    currentIndex++;
    return true;
  }
  return false;
}

void parseExpression(List<Token> tokens) {
  parseTerm(tokens);
  while (currentToken(tokens) != null &&
      (currentToken(tokens)!.type == '+' || currentToken(tokens)!.type == '-' || currentToken(tokens)!.type == '=')) {
    currentIndex++;
    parseTerm(tokens);
  }
}

void parseTerm(List<Token> tokens) {
  parseFactor(tokens);
  while (currentToken(tokens) != null &&
      (currentToken(tokens)!.type == '*' || currentToken(tokens)!.type == '/' || currentToken(tokens)!.type == '^')) {
    currentIndex++;
    parseFactor(tokens);
  }
}

void parseFactor(List<Token> tokens) {
  if (match(tokens, '-')) {
    parseFactor(tokens);
  } else if (match(tokens, 'NUMBER') || match(tokens, 'IDENTIFIER')) {
    // Número o variable válidos
  } else if (currentToken(tokens)?.type == 'FUNCTION') {
    parseFunction(tokens);
  } else if (match(tokens, '(')) {
    parseExpression(tokens);
    if (!match(tokens, ')')) {
      throw "Se esperaba ')' al final de la expresión.";
    }
  } else {
    throw "Token inesperado: ${currentToken(tokens)?.value ?? 'fin de la expresión'}.";
  }
}

void parseFunction(List<Token> tokens) {
  String functionName = currentToken(tokens)?.value ?? "función desconocida";
  currentIndex++; // Avanza el token de la función.
  if (!match(tokens, '(')) {
    throw "Se esperaba '(' después de la función '$functionName'.";
  }
  parseExpression(tokens); // Analiza la expresión dentro de la función.
  if (!match(tokens, ')')) {
    throw "Se esperaba ')' al final de la función '$functionName'.";
  }
}
