; https://github.com/stevearc/aerial.nvim/blob/master/queries/php/aerial.scm
; (source_file
; (pb_header_calss_name 
(pb_file_mame
    (type_name classname: (idt)) @name
    (#set! "kind" "File")) @symbol

(forward_type_implemetation
    InstanceControlName: (type_name) @name
    (#set! "kind" "Class")) @symbol

  (function_implementation
    (function_prototype
      (function_name) @name
      (#set! "kind" "Function"))) @symbol

  (event_implementation 
    (event_prototype_implementation
      (event_name) @name )
    (#set! "kind" "Event")) @symbol
  ; ) @symbol



(dw_assign_prop 
  (dw_prop_name) 
  (dw_operator_assignment) 
  (dw_value) @name
    (#set! "kind" "Field")) @symbol



; ((event_name) @name 
;               (#set! "kind" "Function")) @Symbol



; (function_definition
;   name: (name) @name
;   (#set! "kind" "Function")) @symbol

;
; found in the LSP spec:
; https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
; A current list is below.
;
; Array
; Boolean
; Class
; Constant
; Constructor
; Enum
; EnumMember
; Event
; Field
; File
; Function
; Interface
; Key
; Method
; Module
; Namespace
; Null
; Number
; Object
; Operator
; Package
; Property
; String
; Struct
; TypeParameter
; Variable

