/*
 * @file a parser for Power Builder script language
 * @author Aliaxander Zhukau <sashazjukov@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

const PREC = {
  END_EVENT: 21,
  LOCAL_DECLARATION: 0,
  SQL_BLOCK: 20,
  CHOOSE_CASE_ELSE: 20,
  UNARY: 40,
  FUNCTION_NAME: 10,
  EVENT_NAME: 10,
  CODE_BLOCK: 2,
  CODE_BLOCK_CHOICE: 1,
  LOCAL_VAR: 3,
  RETURN: 40,
  BUILTIN_CONST: 9,
  STRING_LITERAL: 1,
  STRING_ESCAPE: 2,
  ASSIGNMENT: 3,
  BINNARY_ESPRESSION: 3,
};

module.exports = grammar({
  name: "powerbuilder",

  // externals: $ => [
  //   $.block_comment,     // produced by scanner.c
  // ],

  extras: ($) => [$.comment, /\s/, $.line_carry],
  // conflicts: ($) => [[$.assignment, $.variable_list]],
  // supertypes: ($) => [$.statement, $.expression, $.declaration, $.variable],
  rules: {
    // Top-level structure
    source_file: ($) =>
      seq(
        optional($.pb_header_calss_name),
        optional($.pb_header_comment),
        choice(
          repeat1(
            choice(
              $.forward_types,
              $.structur_prototypes,
              $.shared_variables,
              $.global_type_block,
              $.forward_type_implemetation,
            ),
          ),
          seq(
            seq(
              token(caseInsensitive("release")),
              choice($.decimal, $.integer),
              ";",
            ),
            repeat1($.dw_def),
          ),
        ),
      ),
    dw_def: ($) => seq($.dw_band, $.dw_def_properties),
    dw_def_properties: ($) =>
      seq(
        "(",
        repeat(choice($.dw_assign_prop, $.dw_sel_rgion, $.dw_sel_argumentes)),
        ")",
      ),
    dw_band: ($) => $.idt,

    dw_value: ($) =>
      choice(
        seq(choice($.value, /\w+/), optional(seq("(", $.integer, ")"))),
        /\w+/,
      ),
    dw_operator_assignment: ($) => "=",

    dw_identifier: ($) => $.idt,
    dw_assign_prop: ($) =>
      choice(
        seq($.dw_prop_name, $.dw_operator_assignment, $.dw_value),
        seq(
          $.dw_prop_db_name,
          $.dw_operator_assignment,
          seq('"', $.dw_pro_db_value, '"'),
        ),
        seq(
          $.dw_prop,
          $.dw_operator_assignment,
          choice($.dw_value, $.dw_def_properties),
        ),
      ),
    dw_prop_name: ($) => token("name"),
    dw_prop_db_name: ($) => token("dbname"),
    dw_pro_db_value: ($) =>
      choice(
        seq($.dw_table_column_name),
        seq($.dw_table_name, ".", $.dw_table_column_name),
      ),

    dw_table_name: ($) => $.dw_identifier,
    dw_table_column_name: ($) => $.dw_identifier,
    dw_sql_arg: ($) => seq(token(":"), $.local_variable),
    dw_prop: ($) =>
      choice(seq($.dw_identifier, repeat(seq(".", $.dw_identifier)))),
    dw_sql: ($) => repeat1(choice($.dw_sql_arg, /[^"]+/)),
    dw_any: ($) => /.+/,
    dw_sel_rgion: ($) =>
      seq(
        choice(
          token(caseInsensitive("retrieve=")),
          token(caseInsensitive("procedure=")),
        ),
        alias(token('"'), $.dw_sql_start),
        $.dw_sql,
        alias(token('"'), $.dw_sql_end),
      ),
    dw_sel_argumentes: ($) =>
      seq(
        token(caseInsensitive("arguments=")),
        seq(
          "(",
          commaSep1(
            seq(
              "(",
              '"',
              $.sql_argument_name,
              '"',
              ",",
              $.sql_argument_type,
              ")",
            ),
          ),
          ")",
        ),
      ),
    sql_argument_name: ($) => $.idt,
    sql_argument_type: ($) => $.type,
    //------------------------------------------

    shared_variables: ($) =>
      seq(
        token("shared variables"),
        optional($.type_variables_and_events_list),
        token("end variables"),
      ),
    line_carry: ($) => "&",
    point_comma: ($) => ";",

    operator_not: ($) => token(caseInsensitive("NOT")),

    unary_expression: ($) =>
      prec.left(
        PREC.UNARY,
        seq(
          choice(
            seq(
              prec(100, $.operator_not),
              field("argument", $.expression),
            ),
            seq("-", field("argument", $.expression)),
          ),
        ),
      ),

    // on tab_1.create
    pb_inner_on_event_header: ($) =>
      seq(
        token(caseInsensitive("on")),
        $.type_name,
        ".",
        alias($.idt, $.pb_inner_event_name),
        $.newline,
      ),

    pb_inner_on_event: ($) =>
      seq(
        $.pb_inner_on_event_header,
        optional(repeat1($.statement)),
        alias(token(caseInsensitive("end on")), $.dummy_keyword),
      ),

    end_of_function: ($) =>
      choice(token("end function"), token("end subroutine")),

    keyword_return: ($) => token(caseInsensitive("return")),

    return_statement: ($) =>
      choice(
        prec.left(
          PREC.RETURN,
          seq(
            $.keyword_return,
            $.expression,
            $.newline,
          ),
        ),
        prec(41, seq($.keyword_return, $.newline))
      ),

    type_prototypes: ($) =>
      seq(
        token("type prototypes"),
        repeat(
          seq(
            $.function_prototype,
            optional(seq(token(caseInsensitive("LIBRARY")), $.string_literal)),
            optional(
              seq(token(caseInsensitive("alias for")), $.string_literal),
            ),
            $.newline,
          ),
        ),
        token("end prototypes"),
      ),

    pb_file_mame: ($) => seq($.type_name, ".", $.class_type),
    pb_header_calss_name: ($) =>
      seq(token("HA$PBExportHeader$"), $.pb_file_mame),
    pb_header_comment: ($) =>
      seq(token("$PBExportComments$"), /[^\n]+/, $.newline),

    structur_prototypes: ($) =>
      seq(
        token("type"),
        $.type_name,
        token("from"),
        token("structure"),
        repeat1($.local_declaration),
        token("end type"),
      ),

    // optional($.event_prototype_protptypes),
    // Class structure
    type_name: ($) => field("classname", $.idt),
    class_type: ($) => $.idt,
    global_type_block: ($) =>
      seq(
        field("dummy", token("global type")),
        $.type_name,
        token("from"),
        $.type_name,
        $.newline,
        optional($.type_variables_and_events_list),
        token("end type"),
        optional($.global_class_dummy),
        optional($.type_prototypes),
        optional($.type_variables),
        optional($.forward_prototypes),
        optional(
          repeat1(
            choice(
              $.event_implementation,
              $.function_implementation,
              $.pb_inner_on_event,
            ),
          ),
        ),
      ),

    class_inherit_from: ($) =>
      seq(
        token("global type"),
        $.type_name,
        token("from"),
        $.type_name,
        $.newline,
        repeat($.local_declaration),
        token("end type"),
      ),

    // Forward declarations
    forward_types: ($) =>
      seq(
        token("forward"),
        repeat(
          choice(
            $.class_inherit_from,
            $.forward_type
          )
        ),
        token("end forward"),
      ),

    forward_type: ($) =>
      seq(
        token("type"),
        field("InstanceControlName", $.type_name),
        token("from"),
        commaSepUp1($.type_name),
        token("within"),
        $.type_name,
        $.newline,
        repeat($.local_declaration),
        token("end type"),
      ),

    forward_type_implemetation: ($) =>
      seq(
        token("type"),
        field("InstanceControlName", $.type_name),
        token("from"),
        commaSepUp1($.type_name),
        token("within"),
        $.type_name,
        $.newline,
        optional($.type_variables_and_events_list),
        token("end type"),
        optional(repeat1(choice($.event_implementation, $.pb_inner_on_event))),
      ),

    // Variables and properties
    type_variables: ($) =>
      seq(
        "type variables",
        optional($.type_variables_and_events_list),
        "end variables",
      ),

    type_variables_and_events_list: ($) =>
      repeat1(
        choice(
          seq($.visibility, ":", $.newline),
          $.class_variable,
          $.event_prototype_protptype,
        ),
      ),

    class_variable: ($) => seq(optional($.visibility), $.local_declaration),
    // class_variable: ($) =>
    //   seq(
    //     $.type,
    //     seq($.local_variable, optional("[]"), optional(seq("=", $.value))),
    //   ),
    variable_list: ($) =>
      seq(
        commaSep1(
          seq(
            $.local_variable,
            optional("[]"),
            optional(seq($.operator_assignment, $.expression)),
          ),
        ),
      ),

    // Function prototypes
    forward_prototypes: ($) =>
      seq(
        token("forward prototypes"),
        repeat(seq($.function_prototype, $.newline)),
        token("end prototypes"),
      ),
    function_prototype: ($) =>
      seq(
        $.visibility,
        choice(
          seq(
            alias(token(caseInsensitive("function")), $.function_keyword),
            $.type,
          ),
          token("subroutine"),
        ),
        $.function_name,
        $.function_parameters,
      ),

    function_parameters: ($) =>
      seq("(", repeat(seq($.function_parameter, optional(","))), ")"),

    function_parameter: ($) =>
      seq(
        optional(choice($.readonly_keyword, $.ref_keyword)),
        $.type,
        $.local_variable,
        optional(seq("[", "]")),
      ),
    readonly_keyword: ($) => token(caseInsensitive("readonly")),
    ref_keyword: ($) => token(caseInsensitive("ref")),

    // Function implementations
    // function_implementations: ($) => repeat1($.function_implementation),
    function_implementation: ($) =>
      seq(
        $.function_prototype,
        ";",
        optional($.function_body),
        $.end_of_function,
      ),

    function_name: ($) => prec(PREC.FUNCTION_NAME, $.idt),
    function_body: ($) => $.code_block,

    // Event handling
    event_prototype_protptypes: ($) => repeat1($.event_prototype_protptype),
    event_prototype_protptype: ($) => seq($.event_prototype, $.newline),

    event_prototype: ($) =>
      seq(
        token("event"),
        optional(seq(token("type"), $.type)),
        $.event_name,
        optional($.event_parameters),
        optional($.event_builtin_type),
      ),

    event_prototype_implementation: ($) =>
      seq(
        token("event"),
        optional(seq(token("type"), $.type)),
        optional(seq($.type, token("::"))),
        $.event_name,
        optional($.event_parameters),
        optional($.event_builtin_type),
        token(";"),
      ),
    event_builtin_type: ($) => $.idt,

    // event_implementations: ($) => repeat1($.event_implementation),
    event_implementation: ($) =>
      seq(
        $.event_prototype_implementation,
        optional($.event_call_supper),
        // optional($.call_supper_statement),
        // optional(token(";")),
        optional($.event_body),
        $.end_of_event,
      ),

    //event clicked;call super::clicked;LONG		ll_row, ll_case_id
    event_call_supper: ($) =>
      seq(token("call super::"), $.event_name, token(";")),

    event_name: ($) => prec(PREC.EVENT_NAME, $.idt),
    event_parameters: ($) => $.function_parameters,
    event_body: ($) => $.code_block,
    end_of_event: ($) =>
      prec(PREC.END_EVENT, seq(token("end event"), $.newline)),

    sql_into_params: ($) => commaSep1(seq(":", $.local_variable)),

    sql_block_statement: ($) =>
      prec(PREC.SQL_BLOCK, seq($.sql_block_content, $.end_of_sql, token(";"))),

    sql_block_content: ($) =>
      seq(
        choice($.sql_start_keywords),
        // optional(
        //   repeat1(
        //     seq(
        //       $.sql_keywords,
        //       optional($.sql_into_params),
        //       optional($.sql_statments),
        //     ),
        //   ),
        // ),

        // repeat1(choice($.dw_sql_arg, prec(-1, /[^;:]/))),
      ),

    sql_into_block: ($) =>
      seq(alias(token(caseInsensitive("INTO")), $.keyword), $.sql_into_params),

    sql_select_keywords: ($) =>
      choice(
        token(caseInsensitive("SELECT")),
        token(caseInsensitive("SELECTBLOB")),
      ),

    sql_commitRollback_keywords: ($) =>
      choice(
        token(caseInsensitive("COMMIT")),
        token(caseInsensitive("ROLLBACK")),
      ),

    sql_update_keywords: ($) =>
      choice(
        token(caseInsensitive("DECLARE")),
        token(caseInsensitive("DROP")),
        seq(
          token(caseInsensitive("EXECUTE")),
          optional(token(caseInsensitive("IMMEDIATE"))),
          // optional($.idt),
        ),
        seq(token(caseInsensitive("PREPARE"))),
        token(caseInsensitive("DELETE")),
        token(caseInsensitive("UPDATE")),
        token(caseInsensitive("UPDATEBLOB")),
        seq(
          token(caseInsensitive("INSERT")),
          optional(token(caseInsensitive("INTO"))),
        ),
      ),

    sql_pb_keywords: ($) =>
      choice(
        token(caseInsensitive("PREPARE")),
        // token(caseInsensitive("EXECUTE")),
      ),

    sql_start_keywords: ($) =>
      choice(
        seq(
          $.sql_select_keywords,
          repeat1(choice($.dw_sql_arg, $.sql_into_block, prec(-1, /[^;:]/))),
        ),

        seq(
          $.sql_update_keywords,
          repeat1(choice($.dw_sql_arg, prec(-1, /[^;:]/))),
        ),
        seq($.sql_commitRollback_keywords),
        //
        // caseInsensitive("FETCH"),
        // caseInsensitive("OPEN"),
        // 	OPEN designatable_cur;
        // 	FETCH designatable_cur INTO :ls_return_state_id;
        // 	CLOSE designatable_cur;
      ),

    sql_keywords: ($) =>
      choice(
        token(caseInsensitive("DECLARE")),
        token(caseInsensitive("ADD")),
        token(caseInsensitive("DROP")),
        token(caseInsensitive("GO")),
        token(caseInsensitive("EXECUTE")),
        token(caseInsensitive("IMMEDIATE")),
        token(caseInsensitive("SELECT")),
        token(caseInsensitive("SELECTBLOB")),
        // token(caseInsensitive("INTO")),
        token(caseInsensitive("WHERE")),
        token(caseInsensitive("GROUP")),
        token(caseInsensitive("BY")),
        token(caseInsensitive("HAVING")),
        token(caseInsensitive("WITH")),
        token(caseInsensitive("ORDER")),
        token(caseInsensitive("FROM")),
        token(caseInsensitive("AS")),
        token(caseInsensitive("DELETE")),
        token(caseInsensitive("UPDATE")),
        token(caseInsensitive("COMMIT")),
        token(caseInsensitive("ROLLBACK")),
        token(caseInsensitive("INSERT")),
        token(caseInsensitive("SET")),
        token(caseInsensitive("CREATE")),
        token(caseInsensitive("TABLE")),
        token(caseInsensitive("INDEX")),
        token(caseInsensitive("ALTER")),
        token(caseInsensitive("VIEW")),
        token(caseInsensitive("FUNCTION")),
        token(caseInsensitive("CREATE OR REPLACE")),
        token(caseInsensitive("COLUMN")),
        token(caseInsensitive("TRIGGER")),
      ),
    // Add explicit tokenized SQL keywords
    // update_keyword: ($) => prec.right($.sql_keywords),
    // delete_keyword: ($) => prec.right($.sql_keywords),
    // insert_keyword: ($) => prec.right($.sql_keywords),

    // Keep existing SQL rules but add explicit tokenization

    sql_statments: ($) =>
      repeat1(
        choice(
          $.idt,
          $.operator_compare,
          ".",
          "(",
          ")",
          ",",
          // seq(optional(":"), $.local_variable),
        ),
      ),
    end_of_sql: ($) =>
      seq(
        alias(token(caseInsensitive("USING")), $.using_keyword),
        choice(
          commaSep1($.dw_sql_arg),
          seq(optional("("), $.local_variable, optional(")"))
        )
      ),
    choose_block_start: ($) => token(caseInsensitive("choose case")),
    choose_case: ($) => token(caseInsensitive("case")),

    choose_case_else: ($) =>
      prec(
        PREC.CHOOSE_CASE_ELSE,
        seq(token(caseInsensitive("case else")), $.newline),
      ),
    choose_end: ($) => seq(token(caseInsensitive("end choose")), $.newline),

    choose_block: ($) =>
      seq(
        $.choose_block_start,
        $.expression,
        $.newline,
        repeat1(
          seq(
            choice(
              seq(
                $.choose_case,
                repeat1(seq($.expression, optional(","))),
                // $.newline,
              ),
              $.choose_case_else,
            ),
            optional($.code_block),
          ),
        ),
        $.choose_end,
      ),

    statement: ($) =>
      prec(
        PREC.CODE_BLOCK_CHOICE,
        seq(
          choice(
            $.return_statement,
            $.local_declaration,
            prec(PREC.ASSIGNMENT, $.assignment),
            $.function_call,
            $.if_statment,
            $.object_method_call,
            $.sql_block_statement,
            $.choose_block,
            $.goto_def,
            $.goto_use,
            $.do_untill_loop,
            $.for_statment,
            $.continue_statemnt,
            $.exit_statemnt,
            $.update_expression,
            $.call_supper_statement,
            $.try_catch_statement,
            $.halt_statement,
            $.destry_statement,
          ),
        ),
      ),
    destry_statement: ($) =>
      seq(
        alias(token(caseInsensitive("Destroy")), $.keyword),
        optional("("),
        choice($.local_variable, $.object_method_call),
        optional(")"),
      ),
    create_expression: ($) =>
      seq(alias(token(caseInsensitive("Create")), $.keyword), $.type_name),

    halt_statement: ($) =>
      choice(
        token(caseInsensitive("HALT")),
        token(caseInsensitive("HALT CLOSE")),
      ),
    try_catch_statement: ($) =>
      seq(
        alias(token(caseInsensitive("try")), $.try_keyword),
        $.code_block,
        repeat1(
          seq(
            alias(token(caseInsensitive("catch")), $.try_keyword),
            seq("(", $.local_declaration, ")"),
            $.code_block,
          ),
        ),
        alias(token(caseInsensitive("end try")), $.try_keyword),
      ),

    // event resize;call super::resize;

    // event constructor;
    // this.setredraw(FALSE)
    // super::event constructor()

    // call uo_flexreport_area_ppf::destroy
    call_supper_statement: ($) =>
      seq(
        choice(
          token(caseInsensitive("super::")),
          token(caseInsensitive("call super::")),
        ),
        optional(token(caseInsensitive("event"))),
        $.event_name,
        optional($.function_call_parameters),
      ),

    continue_statemnt: ($) =>
      seq(token(caseInsensitive("continue")), $.newline),
    exit_statemnt: ($) => seq(token(caseInsensitive("exit")), $.newline),

    for_statment: ($) =>
      seq(
        alias(token(caseInsensitive("FOR")), $.for_next),
        $.expression,
        alias(token(caseInsensitive("TO")), $.keyword),
        $.expression,
        optional(
          seq(alias(token(caseInsensitive("STEP")), $.keyword), $.expression),
        ),
        $.newline,
        $.code_block,
        seq(alias(token(caseInsensitive("NEXT")), $.for_next), $.newline),
      ),

    do_untill_loop: ($) =>
      choice(
        seq(
          alias(
            choice(
              seq(
                token(caseInsensitive("DO")),
                token(caseInsensitive("UNTIL")),
              ),
              seq(
                token(caseInsensitive("DO")),
                token(caseInsensitive("WHILE")),
              ),
            ),
            $.do_until_alias,
          ),
          $.expression,
          $.newline,
          $.code_block,
          alias(
            seq(token(caseInsensitive("LOOP")), $.newline),
            $.do_until_alias,
          ),
        ),
        seq(
          alias(token(caseInsensitive("DO")), $.do_until_alias),
          $.newline,
          $.code_block,
          alias(
            choice(
              seq(
                token(caseInsensitive("LOOP")),
                token(caseInsensitive("WHILE")),
              ),
              seq(
                token(caseInsensitive("LOOP")),
                token(caseInsensitive("UNTIL")),
              ),
            ),
            $.do_until_alias,
          ),
          $.expression,
          $.newline,
        ),
      ),

    // Code blocks and control structures
    code_block: ($) => prec.right(repeat1($.statement)),

    goto_use_keyword: ($) => token(caseInsensitive("goto")),
    goto_def: ($) => seq($.idt, ":"),
    goto_use: ($) => seq($.goto_use_keyword, $.idt, $.newline),

    if_keyword: ($) => token(caseInsensitive("IF")),
    elseif_keyword: ($) => token(caseInsensitive("ELSEIF")),
    then_keyword: ($) => token(caseInsensitive("THEN")),
    else_keyword: ($) => token(caseInsensitive("ELSE")),
    endif_keyword: ($) =>
      seq(token(caseInsensitive("END")), token(caseInsensitive("IF"))),

    // pb_constructions: ($) => choice($.if_statment),
    if_statment: ($) =>
      choice(
        seq(
          choice($.if_keyword),
          $.expression,
          $.then_keyword,
          $.newline,
          optional(
            prec.right(
              repeat1(
                seq(
                  choice(
                    $.code_block,
                    seq(
                      $.elseif_keyword,
                      $.expression,
                      $.then_keyword,
                      $.newline,
                    ),
                    seq(seq($.else_keyword, $.newline)),
                  ),
                ),
              ),
            ),
          ),
          $.endif_keyword,
          $.newline,
        ),
        seq($.if_keyword, $.expression, $.then_keyword, $.statement, $.newline),
      ),

    // repeat_statement: ($) =>
    //   seq(
    //     alias("repeat", $.repeat_start),
    //     optional($._block),
    //     alias("until", $.repeat_until),
    //     $._expression,
    //   ),
    update_expression: ($) =>
      prec.left(
        50,
        choice(
          seq(
            field("argument", $.local_variable),
            field("operator", choice(token("++"), token("--"))),
          ),
          seq(
            field("operator", choice(token("++"), token("--"))),
            field("argument", $.local_variable),
          ),
        ),
      ),
    // Expressions
    expression: ($) =>
      prec.left(
        seq(
          choice(
            $.update_expression,
            $.unary_expression,
            $.binary_expression,
            $.parenthesized_expression,
            $.value,
            $.local_variable,
            $.builtin_const,
            $.function_call,
            $.object_method_call,
            $.array_expression,
            $.create_expression,
            // seq("&", $.newline),
          ),
          // optional($.line_carry),
        ),
      ),

    binary_expression: ($) =>
      prec.left(
        PREC.BINNARY_ESPRESSION,
        choice(seq($.expression, $.operator_compare, $.expression)),
      ),
    parenthesized_expression: ($) => seq("(", $.expression, ")"),
    array_expression: ($) => seq("{", repeat(commaSep1($.expression)), "}"),
    assignment: ($) =>
      prec.left(
        seq(
          // $.object_method_call,
          seq(
            choice($.local_variable, $.object_method_call),
            // optional($.array_construction),
          ),
          $.operator_assignment,
          repeat1($.expression),
          // $.newline,
        ),
      ),
    operator_assignment: ($) => choice("=", "+=", "-="),

    // Literals and values
    value: ($) =>
      choice(
        $.string_literal,
        $.integer,
        $.decimal,
        $.boolean_literal,
        // $.local_variable,
      ),
    string_literal: ($) =>
      choice(
        seq("'", repeat($.string_literal_content_single), "'"),
        seq('"', repeat($.string_literal_content), '"'),
      ),
    integer: ($) => /\d+/,
    decimal: ($) => /\d*\.\d+/,
    boolean_literal: ($) =>
      choice(token(caseInsensitive("TRUE")), token(caseInsensitive("FALSE"))),
    operator_compare: ($) =>
      choice(
        "+",
        "-",
        "*",
        "/",
        ">",
        "<",
        "=",
        "<>",
        ">=",
        "<=",
        $.operator_logical,
      ),
    operator_logical: ($) =>
      choice(caseInsensitive("AND"), caseInsensitive("OR")),
    // Common components
    visibility: ($) =>
      choice(
        token(caseInsensitive("public")),
        token(caseInsensitive("private")),
        token(caseInsensitive("protected")),
      ),
    type: ($) =>
      choice(
        seq($.builtin_type, optional($.type_size_precision)),
        $.idt_with_underscore,
        $.idt,
      ),

    builtin_type: ($) =>
      choice(
        alias(token(caseInsensitive("integer")), $.type_integer),
        alias(token(caseInsensitive("string")), $.type_string),
        alias(token(caseInsensitive("boolean")), $.type_boolean),
        token(caseInsensitive("decimal")),
        token(caseInsensitive("date")),
        token(caseInsensitive("datetime")),
        token(caseInsensitive("time")),
        token(caseInsensitive("blob")),
        alias(token(caseInsensitive("long")), $.type_long),
        token(caseInsensitive("double")),
        token(caseInsensitive("char")),
        token(caseInsensitive("byte")),
        token(caseInsensitive("any")),
        token(caseInsensitive("treeviewitem")),
      ),

    type_size_precision: ($) => seq("{", $.integer, "}"),

    local_variable: ($) =>
      prec.left(PREC.LOCAL_VAR, seq($.idt, optional($.array_construction))),

    builtin_const: ($) =>
      prec(
        PREC.BUILTIN_CONST,
        choice(seq($.idt, "!"), caseInsensitive("null")),
      ),
    object_method_call: ($) =>
      seq(
        field("left", $.object_name),
        ".",
        optional(
          choice(
            token(caseInsensitive("event")),
            token(caseInsensitive("post")),
            token(caseInsensitive("triggerevent")),
          ),
        ),
        field(
          "right",
          choice(
            $.object_name,
            $.object_method_call,
            $.function_call,
            $.dw_object_table_column_call,
            // $.array_call,
          ),
        ),
      ),

    dw_object_keyword: ($) => token(caseInsensitive("object")),
    dw_object_table_column_call: ($) =>
      prec.right(
        seq(
          $.dw_object_keyword,
          ".",
          choice(
            $.object_name,
            seq($.object_name, ".", $.idt),
            $.function_call,
          ),
        ),
      ),

    // TODO: separate to evennt and function call
    function_call: ($) => seq(
      optional(seq(token("super::"), token("event"))),
      $.function_name,
      $.function_call_parameters
    ),

    function_call_parameters: ($) =>
      seq("(", optional(repeat1(seq($.expression, optional(",")))), ")"),

    // Low-level tokens
    word: ($) => $.idt,
    idt: ($) => /[a-zA-Z_][a-zA-Z0-9_\-]*/,

    idt_with_underscore: ($) => /[a-zA-Z]+[_]+[a-zA-Z0-9_\-]*/,
    newline: ($) => seq(optional(';'), /[\n\r]/),

    // Use a non-token recursive rule for nested block comments
    comment: $ => choice($.line_comment, $.block_comment),

    line_comment: $ =>
      token(seq('//', /[^\n\r]*/)),

    block_comment: $ => token(seq("/*", /[^*]*\*+([^/*][^*]*\*+)*/, "/"),),
    // ...rest of your grammar...
    string_literal_content_single: ($) =>
      choice(
        $.escape_sequence,
        token.immediate(prec(PREC.STRING_LITERAL, /[^\~'\n]+/)),
      ),
    string_literal_content: ($) =>
      choice(
        $.escape_sequence,
        token.immediate(prec(PREC.STRING_LITERAL, /[^\~"\n]+/)),
      ),
    escape_sequence: (_$) => choice(token('~~'), token('~"'), token("~'"), token("~t")),

    // Helper rules
    global_class_dummy: ($) => seq($.dummy_keyword, $.idt, $.idt),
    dummy_keyword: ($) => $.idt,
    array_construction: ($) => seq("[", commaSep1($.expression), "]"),
    object_name: ($) => prec.left(seq($.idt, optional($.array_construction))),

    local_declaration: ($) =>
      prec(PREC.LOCAL_DECLARATION, seq($.type, $.variable_list, $.newline)),
  },
});

// ... existing helper functions ...

/*
 * Creates a rule to match one or more of the rules separated by a comma
 *
 * @param {Rule} rule
 *
 * @returns {SeqRule}
 */
/**
 * @param {RuleOrLiteral} rule
 */
function commaSep1(rule) {
  return seq(rule, repeat(field("comma", seq(",", rule))));
}

/**
 * @param {RuleOrLiteral} rule
 */
function commaSepUp1(rule) {
  return seq(rule, repeat(field("up_comma", seq("`", rule))));
}

/**
 * @param {string} keyword
 */
function caseInsensitive(keyword) {
  return new RegExp(
    keyword
      .split("")
      .map((char) => `[${char.toLowerCase()}${char.toUpperCase()}]`)
      .join(""),
  );
}
