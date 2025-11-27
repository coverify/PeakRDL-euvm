{% import 'utils.d' as utils with context %}

//------------------------------------------------------------------------------
// uvm_vreg definition
//------------------------------------------------------------------------------
{% macro class_definition(node) -%}
{%- if class_needs_definition(node) %}
// {{get_class_friendly_name(node)}}
class {{get_class_name(node)}}: uvm_vreg {
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
@rand uvm_vreg_field {{get_inst_name(field)}};
{% endfor -%}
{%- endmacro %}


//------------------------------------------------------------------------------
// new() function
//------------------------------------------------------------------------------
{% macro function_new(node) -%}
this(string name = "{{get_class_name(node)}}") {
  super(name, {{node.get_property('regwidth')}});
}
{%- endmacro %}


//------------------------------------------------------------------------------
// build() function
//------------------------------------------------------------------------------
{% macro function_build(node) -%}
void build() {
  {%- for field in node.fields() %}
  {%- if use_uvm_factory %}
  this.{{get_inst_name(field)}} = uvm_vreg_field.type_id.create("{{get_inst_name(field)}}");
  {%- else %}
  this.{{get_inst_name(field)}} = new uvm_vreg_field("{{get_inst_name(field)}}");
  {%- endif %}
  this.{{get_inst_name(field)}}.configure(this, {{field.width}}, {{field.lsb}});
  {%- endfor %}
}
{%- endmacro %}


//------------------------------------------------------------------------------
// build() actions for uvm_reg instance (called by parent)
//------------------------------------------------------------------------------
{% macro build_instance(node) -%}
{%- if use_uvm_factory %}
this.{{get_inst_name(node)}} = {{get_class_name(node)}}.type_id.create("{{get_inst_name(node)}}");
{%- else %}
this.{{get_inst_name(node)}} = new {{get_class_name(node)}}("{{get_inst_name(node)}}");
{%- endif %}
this.{{get_inst_name(node)}}.configure(this, this.m_mem, {{node.n_elements}});
this.{{get_inst_name(node)}}.build();
{%- endmacro %}
