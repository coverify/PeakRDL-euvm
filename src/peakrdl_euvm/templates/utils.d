/*
 * If node is an array, emit the array suffixes for each dimension
 * for example, a 3-dimensional array:
 *  [2][4][6]
 */
{% macro array_inst_suffix(node) -%}
    {%- if node.is_array -%}
        {%- for dim in node.array_dimensions -%}
            [{{dim}}]
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}


/*
 * If node is an array, emit a list of iterators
 * for example, a 3-dimensional array:
 *  i0, i1, i2
 */
{% macro array_iterator_list(node) -%}
    {%- if node.is_array -%}
        {%- for dim in node.array_dimensions -%}
            {{- "i%d" % loop.index0 -}}
            {%- if not loop.last %}, {% endif -%}
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}


/*
 * If node is an array, emit a list of array suffix iterators
 * for example, a 3-dimensional array:
 *  [i0][i1][i2]
 */
{% macro array_iterator_suffix(node) -%}
    {%- if node.is_array -%}
        {%- for dim in node.array_dimensions -%}
            {{- "[i%d]" % loop.index0 -}}
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}


/*
 * If node is an array, emit an array suffix format string
 * for example, a 3-dimensional array:
 *  [%0d][%0d][%0d]
 */
{% macro array_suffix_format(node) -%}
    {%- if node.is_array -%}
        {%- for _ in node.array_dimensions -%}
            {{- "[%0d]" -}}
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}

{% macro array_element(node, index) -%}
    {%- if node.is_array -%}
       {{- node.inst_name + "_elem%d" % index -}}
    {%- endif -%}
{%- endmacro %}

{% macro array_iterator(index) -%}
    {{- "i%d" % index -}}
{%- endmacro %}

{% macro array_subarray(node, index) -%}
    {%- if node.is_array -%}
        {%- if index == 0 -%}
            {{- "this." + node.inst_name -}}
        {%- else -%}
            {{- node.inst_name + "_elem%d" % (index|int - 1) -}}
        {%- endif -%}
    {%- endif -%}
{%- endmacro %}

{% macro array_elements_leaf(node) -%}
    {%- if node.is_array -%}
        {%- for dim in node.array_dimensions -%}
            {%- if loop.last %} {{- node.inst_name + "_elem%d" % loop.index0 -}} {% endif -%}
        {%- endfor -%}
    {%- endif -%}
{%- endmacro %}

