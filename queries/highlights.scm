; !!! check available @params for colors here:
;; https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/integrations/treesitter.lua
; Highlight class names

((ERROR) @ts.error)

[
  ";"
  "."
  ","
  "["
  "]"
  "[]"
  "("
  ")"
  "{"
  "}"
] @punctuation.delimiter

;; [
;;  "IF"
;;  "THEN"
;;  "END IF"
;;  "ELSE"
;;  "ELSEIF"
;;  ] @keyword

[
 "global type"
 "event"
 "end event"
 ;; "function"
 "end function"
 "type"
 "from"
 "within"
 "end type"
 "type variables"
 "end variables"
 ] @keyword.directive

((function_keyword) @keyword.directive)

((for_next) @keyword.repeat)
((exit_statemnt) @keyword.return)
((continue_statemnt) @keyword.return)
((do_until_alias) @keyword.repeat)
((event_prototype) @keyword.directive)
[
"++"
"--"
"="
 ] @operator

((operator_assignment) @operator)
((operator_compare) @operator)
((operator_logical) @operator.logical)
((operator_not) @operator.logical.not)


((builtin_const) @keyword)

((type_name) @class.name)

;; (clas_name) @type)
((forward_types) @keyword.directive)
((forward_prototypes) @keyword.directive)
((dummy_keyword) @keyword.directive)
((pb_inner_on_event) @keyword.directive)

; Highlight identifiers in forward prototypes
((type) @type)

(create_expression 
  (keyword) 
  (type_name 
    classname: (idt) @type))

((integer) @number)
((type_integer) @number)
((type_long) @number)
((type_string) @string)
((type_boolean) @string)
((string_literal_content) @string)
((string_literal_content_single) @string)
((boolean_literal) @string)
((builtin_type) @type)

((block_comment) @comment)
((line_comment) @comment)

;; ((function_name) @function)
((visibility) @keyword.modifier)
((keyword_return) @keyword.return)

(function_parameters 
  (function_parameter 
    (type) @type 
    (local_variable) @variable.local ))

(expression 
  (create_expression 
    (keyword) @keyword 
    (type_name) @class.name)) 

(statement 
  (destry_statement 
    (keyword) @keyword 
    (local_variable) @variable.local ))

(keyword) @keyword 
(goto_use_keyword)@keyword.return 
 
((local_variable) @variable.local)

((object_name) @variable.member_left)

(object_method_call 
  left: (object_name)  @variable.member_left
  right: (object_name) @variable.member)

; (object_method_call 
;   right: (array_call) @variable)
  ; ((array_construction) @variable.array_call)

((function_prototype) @function_prototype)
((event_prototype) @function_prototype)
((end_of_function) @function_prototype)
((end_of_event) @function_prototype)

((function_name) @function)
((event_name) @function)


;; ((sql_keywords) @sql.keyword)
((sql_start_keywords) @sql.keyword)
;; ((end_of_sql) @sql.keyword )
((using_keyword) @keyword )

;; --=[ SQl ]=-
(sql_into_params
  (local_variable) @sql.parameter
  (#set! priority 101)
)

(sql_into_params
  (local_variable) @variable.local
  (#set! priority 101)
)
; Injected sql
;; ((keyword_select) @sql.keyword)
;; ((keyword_from) @sql.keyword)
;; ((keyword_where) @sql.keyword)
;; ((keyword_join) @sql.keyword)

;; (select_keyword) @keyword
;; (update_keyword) @keyword
;; (delete_keyword) @keyword
;; (insert_keyword) @keyword
;; (sql_into (token) @keyword)
;; (end_of_sql (token) @keyword)

;statement keywords
(try_keyword) @keyword.control.conditional
(if_keyword) @keyword.control.conditional
(elseif_keyword) @keyword.control.conditional
(then_keyword) @keyword.control.conditional
(else_keyword) @keyword.control.conditional
(endif_keyword) @keyword.control.conditional

(line_carry) @keyword
(readonly_keyword) @keyword.directive 
(ref_keyword) @keyword

(choose_block_start) @keyword
(choose_case) @keyword
(choose_case_else) @keyword
(choose_end) @keyword


; --=[ DW Syntax]=---
(dw_sql_arg
  (local_variable) @sql.parameter
  (#set! priority 101)
)

(dw_sql_arg
  (local_variable) @variable.local
  (#set! priority 101)
)

((dw_prop) @variable)
((dw_operator_assignment) @operator)

(dw_assign_prop 
  (dw_prop_name) @keyword.type
  (dw_operator_assignment) 
  (dw_value) @string)

; (dw_assign_prop 
((dw_prop_db_name) @keyword.type)
((dw_table_name) @type )
((dw_table_column_name) @variable.member )

(dw_object_table_column_call 
  (dw_object_keyword) @keyword.object
  (object_name  
    (idt) @variable.member))
