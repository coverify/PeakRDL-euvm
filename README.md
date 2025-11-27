[![build](https://github.com/coverify/PeakRDL-euvm/workflows/build/badge.svg)](https://github.com/coverify/PeakRDL-euvm/actions?query=workflow%3Abuild+branch%3Amain)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/peakrdl-uvm.svg)](https://pypi.org/project/peakrdl-uvm)

# PeakRDL-euvm
Generate eUVM register model from compiled SystemRDL input.

For the command line tool, see the [PeakRDL project](https://peakrdl.readthedocs.io).

## Installing
Install from [PyPi](https://pypi.org/project/peakrdl-uvm) using pip:

    python3 -m pip install peakrdl-euvm


## Example

The easiest way to use PeakRDL-euvm is via the [PeakRDL command line tool](https://peakrdl.readthedocs.io/):

```bash
# Install the command line tool
python3 -m pip install peakrdl

# Generate eUVM
peakrdl euvm your_design.rdl -o your_design.sv
```


## Reference

### `eUVMExporter(**kwargs)`
Constructor for the eUVM Exporter class

**Optional Parameters**

* `user_template_dir`
    * Path to a directory where user-defined template overrides are stored.
* `user_template_context`
    * Additional context variables to load into the template namespace.

### `eUVMExporter.export(node, path, **kwargs)`
Perform the export!

**Parameters**

* `node`
    * Top-level node to export. Can be the top-level `RootNode` or any internal `AddrmapNode`.
* `path`
    * Output file.

**Optional Parameters**

* `export_as_package`
    * If True (Default), eUVM register model is exported as a SystemVerilog
      package. Package name is based on the output file name.
    * If False, register model is exported as an includable header.
* `reuse_class_definitions`
    * If True (Default), exporter attempts to re-use class definitions
      where possible. Class names are based on the lexical scope of the
      original SystemRDL definitions.
    * If False, class definitions are not reused. Class names are based on
      the instance's hierarchical path.
* `use_uvm_factory`
    * If True, class definitions and class instances are created using the
      UVM factory.
    * If False (Default), UVM factory is disabled. Classes are created
      directly via new() constructors.

### API Example
Pass the elaborated output of the [SystemRDL Compiler](http://systemrdl-compiler.readthedocs.io)
to the exporter.

```python
import sys
from systemrdl import RDLCompiler, RDLCompileError
from peakrdl_euvm import eUVMExporter

rdlc = RDLCompiler()

try:
    rdlc.compile_file("path/to/my.rdl")
    root = rdlc.elaborate()
except RDLCompileError:
    sys.exit(1)

exporter = eUVMExporter()
exporter.export(root, "test.d")
```
