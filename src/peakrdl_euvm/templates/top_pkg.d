{% import 'main.d' as main with context %}
// This file was autogenerated by PeakRDL-euvm
module {{package_name}};


import esdl;
import uvm;
import uvm.reg;
    {{ main.top()|indent}}

