{% import 'utils.d' as utils with context %}

//------------------------------------------------------------------------------
// uvm_reg_block definition
//------------------------------------------------------------------------------
{% macro class_definition(node) -%}
{%- if class_needs_definition(node) %}
// {{get_class_friendly_name(node)}}
class {{get_class_name(node)}}: uvm_reg_block {
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
{%- for child in node.children() if isinstance(child, AddressableNode) -%}
@rand {{get_class_name(child)}}{{utils.array_inst_suffix(child)}} {{get_inst_name(child)}};
{% endfor -%}
{%- endmacro %}


//------------------------------------------------------------------------------
// new() function
//------------------------------------------------------------------------------
{% macro function_new(node) -%}
this(string name = "{{get_class_name(node)}}") {
  super(name);
}
{%- endmacro %}


//------------------------------------------------------------------------------
// build() function
//------------------------------------------------------------------------------
{% macro function_build(node) -%}
void build() {
  this.default_map = create_map("reg_map", 0, {{get_bus_width(node)}}, {{get_endianness(node)}});
  {%- for child in node.children() -%}
  {%- if isinstance(child, RegNode) -%}
  {{uvm_reg.build_instance(child)|indent}}
  {%- elif isinstance(child, (RegfileNode, AddrmapNode)) -%}
  {{build_instance(child)|indent}}
  {%- elif isinstance(child, MemNode) -%}
  {{uvm_reg_block_mem.build_instance(child)|indent}}
  {%- endif -%}
  {%- endfor %}
}
{%- endmacro %}


//------------------------------------------------------------------------------
// build() actions for uvm_reg_block instance (called by parent)
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
  {%- if node.get_property('hdl_path') %}
  {{utils.array_elements_leaf(node)}}.configure(this, "{{node.get_property('hdl_path')}}");
  {%- else %}
  {{utils.array_elements_leaf(node)}}.configure(this);
  {%- endif %}
  {%- if node.get_property('hdl_path_gate') %}
  {{utils.array_elements_leaf(node)}}.add_hdl_path("{{node.get_property('hdl_path_gate')}}", "GATE");
  {%- endif %}
  {{utils.array_elements_leaf(node)}}.build();
  this.default_map.add_submap({{utils.array_elements_leaf(node)}}.default_map, {{get_array_address_offset_expr(node)}});
}
{%- else %}
{%- if use_uvm_factory %}
this.{{get_inst_name(node)}} = {{get_class_name(node)}}.type_id.create("{{get_inst_name(node)}}");
{%- else %}
this.{{get_inst_name(node)}} = new {{get_class_name(node)}}("{{get_inst_name(node)}}");
{%- endif %}
{%- if node.get_property('hdl_path') %}
this.{{get_inst_name(node)}}.configure(this, "{{node.get_property('hdl_path')}}");
{%- else %}
this.{{get_inst_name(node)}}.configure(this);
{%- endif %}
{%- if node.get_property('hdl_path_gate') %}
this.{{get_inst_name(node)}}.add_hdl_path("{{node.get_property('hdl_path_gate')}}", "GATE");
{%- endif %}
this.{{get_inst_name(node)}}.build();
this.default_map.add_submap(this.{{get_inst_name(node)}}.default_map, {{"0x%x" % node.raw_address_offset}});
{%- endif %}
{%- endmacro %}
