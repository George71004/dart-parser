<expresion> ::= <termino> { ('+' | '-' | '=') <termino> } 
 <termino> ::= <factor> { ('*' | '/' | '^') <factor> } 
 <factor> ::= ['-'] (<numero> | <variable> | <funcion> | '(' <expresion> ')' ) 
 <numero> ::= <digito> {<digito>} ['.' {<digito>}] 
 <digito> ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' 
 <variable> ::= <letra> {<letra>} 
 <letra> ::= 'a' | 'b' | ... | 'z' | 'A' | 'B' | ... | 'Z' 
 <funcion> ::= 'sen(' <expresion> ')' | 'cos(' <expresion> ')' | 'tan(' <expresion> ')' | 'sqrt(' <expresion> ')' | 'ln(' <expresion> ')'  
| 'f(' <expresion> ')' | 'arcsen(' <expresion> ')' | 'arccos(' <expresion> ')' | 'arctan(' <expresion> ')'