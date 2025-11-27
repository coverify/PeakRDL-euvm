{% import 'utils.d' as utils with context %}

//------------------------------------------------------------------------------
// uvm_reg definition
//------------------------------------------------------------------------------
{% macro class_definition(node) -%}
{%- if class_needs_definition(node) %}
// {{get_class_friendly_name(node)}}
class {{get_class_name(node)}}: uvm_reg {
{%- if use_uvm_factory %}
    mixin uvm_object_utils;
{%- endif %}
    {{child_insts(node)|indent}}
    {{function_new(node)|indent}}

    {{function_build(node)|indent}}
}
{% endif -%}
{%- endmacro %}


//------------------------------------------------------------------------------
// Child instances
//------------------------------------------------------------------------------
{% macro child_insts(node) -%}
{%- for field in node.fields() -%}
@rand uvm_reg_field {{get_inst_name(field)}};
{% endfor -%}
{%- endmacro %}


//------------------------------------------------------------------------------
// new() function
//------------------------------------------------------------------------------
{% macro function_new(node) -%}
this(string name = "{{get_class_name(node)}}") {
    super(name, {{node.get_property('regwidth')}}, UVM_NO_COVERAGE);
}
{%- endmacro %}


//------------------------------------------------------------------------------
// build() function
//------------------------------------------------------------------------------
{% macro function_build(node) -%}
void build() {
    {%- for field in node.fields() %}
    {%- if use_uvm_factory %}
    this.{{get_inst_name(field)}} = uvm_reg_field.type_id.create("{{get_inst_name(field)}}");
    {%- else %}
    this.{{get_inst_name(field)}} = new uvm_reg_field("{{get_inst_name(field)}}");
    {%- endif %}
    this.{{get_inst_name(field)}}.configure(this, {{field.width}}, {{field.lsb}}, "{{get_field_access(field)}}", {{field.is_volatile|lower}},cast(uvm_reg_data_t) {{"0x%x" % field.get_property('reset', default=0)}}, {{field.get_property('reset') is not none|int}}, 1, 0);
    {%- endfor %}
}
{%- endmacro %}


//------------------------------------------------------------------------------
// build() actions for uvm_reg instance (called by parent)
//------------------------------------------------------------------------------
{% macro build_instance(node) -%}
{%- if node.is_array %}
  {%- for dim in node.array_dimensions %}
foreach (uint {{utils.array_iterator(loop.index0)}}, ref {{utils.array_element(node, loop.index0)}}; {{utils.array_subarray(node, loop.index0)}})
  {%- if loop.last %} { {% endif -%}
  {%- endfor -%}
  {%- if use_uvm_factory %}
  {{utils.array_elements_leaf(node)}} = {{get_class_name(node)}}.type_id.create(format("{{get_inst_name(node)}}{{utils.array_suffix_format(node)}}", {{utils.array_iterator_list(node)}}));
  {%- else %}
  {{utils.array_elements_leaf(node)}} = new {{get_class_name(node)}}(format("{{get_inst_name(node)}}{{utils.array_suffix_format(node)}}", {{utils.array_iterator_list(node)}}));
  {%- endif %}
  {{utils.array_elements_leaf(node)}}.configure(this);
  {{add_hdl_path_slices(node, get_inst_name(node) + utils.array_iterator_suffix(node))|trim|indent}}
  {{utils.array_elements_leaf(node)}}.build();
  this.default_map.add_reg({{utils.array_elements_leaf(node)}}, {{get_array_address_offset_expr(node)}});
}
{%- else %}
{%- if use_uvm_factory %}
this.{{get_inst_name(node)}} = {{get_class_name(node)}}.type_id.create("{{get_inst_name(node)}}");
{%- else %}
this.{{get_inst_name(node)}} = new {{get_class_name(node)}}("{{get_inst_name(node)}}");
{%- endif %}
this.{{get_inst_name(node)}}.configure(this);
{{add_hdl_path_slices(node, get_inst_name(node))|trim}}
this.{{get_inst_name(node)}}.build();
this.default_map.add_reg(this.{{get_inst_name(node)}}, {{"0x%x" % node.raw_address_offset}});
{%- endif %}
{%- endmacro %}

//------------------------------------------------------------------------------
// Load HDL path slices for this reg instance
//------------------------------------------------------------------------------
{% macro add_hdl_path_slices(node, inst_ref) -%}
{%- if node.get_property('hdl_path') %}
{{inst_ref}}.add_hdl_path_slice("{{node.get_property('hdl_path')}}", -1, -1);
{%- endif -%}

{%- if node.get_property('hdl_path_gate') %}
{{inst_ref}}.add_hdl_path_slice("{{node.get_property('hdl_path_gate')}}", -1, -1, 0, "GATE");
{%- endif -%}

{%- for field in node.fields() %}
{%- if field.get_property('hdl_path_slice') is none -%}
{%- elif field.get_property('hdl_path_slice')|length == 1 %}
{{inst_ref}}.add_hdl_path_slice("{{field.get_property('hdl_path_slice')[0]}}", {{field.lsb}}, {{field.width}});
{%- elif field.get_property('hdl_path_slice')|length == field.width %}
{%- for slice in field.get_property('hdl_path_slice') %}
{%- if field.msb > field.lsb %}
{{inst_ref}}.add_hdl_path_slice("{{slice}}", {{field.msb - loop.index0}}, 1);
{%- else %}
{{inst_ref}}.add_hdl_path_slice("{{slice}}", {{field.msb + loop.index0}}, 1);
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endfor -%}

{%- for field in node.fields() %}
{%- if field.get_property('hdl_path_gate_slice') is none -%}
{%- elif field.get_property('hdl_path_gate_slice')|length == 1 %}
{{inst_ref}}.add_hdl_path_slice("{{field.get_property('hdl_path_gate_slice')[0]}}", {{field.lsb}}, {{field.width}}, 0, "GATE");
{%- elif field.get_property('hdl_path_gate_slice')|length == field.width %}
{%- for slice in field.get_property('hdl_path_gate_slice') %}
{%- if field.msb > field.lsb %}
{{inst_ref}}.add_hdl_path_slice("{{slice}}", {{field.msb - loop.index0}}, 1, 0, "GATE");
{%- else %}
{{inst_ref}}.add_hdl_path_slice("{{slice}}", {{field.msb + loop.index0}}, 1, 0, "GATE");
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endfor %}
{%- endmacro %}
