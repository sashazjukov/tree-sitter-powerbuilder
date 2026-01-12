
// scanner.c
#include <tree_sitter/parser.h>
#include <stdbool.h>

// Define token types corresponding to externals in grammar.js
enum TokenType {
  BLOCK_COMMENT,
};

// Minimal lifecycle hooks (no state to keep)
void *tree_sitter_powerbuilder_external_scanner_create() { return NULL; }
void tree_sitter_powerbuilder_external_scanner_destroy(void *payload) {}
unsigned tree_sitter_powerbuilder_external_scanner_serialize(void *payload, char *buffer) { return 0; }
void tree_sitter_powerbuilder_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {}

static inline void advance(TSLexer *lexer) { lexer->advance(lexer, false); }
static inline void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

bool tree_sitter_powerbuilder_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
  // Only produce BLOCK_COMMENT when the parser requests it
  if (!valid_symbols[BLOCK_COMMENT]) return false;

  // We only start if the stream begins with '/*'
  if (lexer->lookahead != '/') return false;
  advance(lexer);
  if (lexer->lookahead != '*') return false;
  advance(lexer);

  unsigned depth = 1;

  // Consume until matching closing '*/', supporting nesting like /* ... /* ... */ ... */
  for (;;) {
    if (lexer->eof(lexer)) {
      // Unterminated block comment: fail so parser can report/handle gracefully
      return false;
    }

    switch (lexer->lookahead) {
      case '/': {
        advance(lexer);
        if (lexer->lookahead == '*') {
          // Nested opening
          advance(lexer);
          depth++;
          continue;
        }
        // Otherwise, just a '/', continue
        continue;
      }
      case '*': {
        advance(lexer);
        if (lexer->lookahead == '/') {
          advance(lexer);
          if (--depth == 0) {
            // Successfully consumed the entire comment as one token
            lexer->result_symbol = BLOCK_COMMENT;
            return true;
          }
          // Closed an inner nested comment; continue scanning
          continue;
        }
        // Run of '*' not followed by '/', continue
        continue;
      }
      default:
        // Any other char
        advance(lexer);
        continue;
    }
  }
}

