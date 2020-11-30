# Common Shader Language

## Table of contents
- [Introduction](#introduction)
- [Considerations](#considerations)
- [Project](#project)
  * [Compiling](#compiling)
  * [Usage](#usage)
  * [Examples](#examples)
  * [Shader test](#shader-test)
- [Language grammar](#language-grammar)
  * [Data types](#data-types)
  * [Operators](#operators)
  * [Statements](#statements)
  * [Function definition](#function-definition)
- [Development difficulties and shortcomings](#development-difficulties-and-shortcomings)
- [Future extensions](#future-extensions)
- [References](#references)

## Introduction

CSL is a language for programming platform-independent shaders, that can be compiled to more available shading languages such as GLSL. CSL's syntax is tailored to facilitate mathematical descriptions of geometric primitives (i.e. by signed distance functions), and other common operations in raymarching techniques.

## Considerations

As the chosen target shader languages (GLSL, WebGL) restrict certain operations, CSL does not support character strings manipulation, and does not allow for external debugging this way. The preferred way of debugging these shaders remains writing to additional buffers for later analysis.
In the same way, 'do-while' and 'while' loops are disallowed in WebGL since they are of optional implementation in the GLSL spec. Therefore, only 'for' loops where the maximum number of iterations is determinable at compile time are allowed. 

## Project

This project contains the description of the CSL language in the Lex 'grammar.l' and Yacc 'grammar.y' files. The wrapping C code is located in the 'src' folder.
The source file parsing generates an Abstract Syntax Tree with a similar structure to the language grammar. The resulting AST is then visited during the code generation phase. Syntax errors during parsing are reported with line number and error message provided by YACC.

### Compiling

```shell
git clone https://github.com/JColonnello/CSL
cd CSL/
make
```

### Usage

The generated compiler is found in _build_.

```shell
./build/csl [input.csl] [output.glsl]
```

Without an output file, output defaults to stdout. The same way, with no input file, input defaults to stdin.

### Examples

Also included are several test shaders, located in the _examples_ folder. These shaders take 3 uniform inputs:
- _iResolution_, a vector with the canvas width and height in pixels
- _iMouse_, a vector with mouse coordinates in pixels up to the value of _iResolution_ ([0,0] at top-left corner)
- _iTime_, with the elapsed time in seconds

These examples can be compiled with a Makefile target:
```shell
make tests
```
The resulting '.glsl' files are located in the 'generated/examples' folder, and can be then tested with the included tool.

### Shader test

Located in the 'viewer' folder, is a simple HTML application to test the compiled GLSL shaders. An online version of the one featured in this repository can be found [here](https://jcolonnello.github.io/CSL/viewer/).
This application uses the ThreeJS library to draw with a WebGL fragment shader over an HTML canvas.
On this page, the '.glsl' files can be uploaded and visualized. To send mouse inputs, click and drag over the canvas.

## Language grammar

### Data types

CSL features more simplified data types:
* **float** (real number)
* **vec** (4-component vector)
* **mat** (4x4 matrix)

Float constants of these forms are allowed:
```glsl
4
3.
0.243
```
The vector type allows for _swizzling_ to access its components. Suffixes of up to 4 letters x, y, z, or w form a new vector with those components in order. The remaining components are set to 0. Suffixes of 1 letter generate a value of type _float_.
```glsl
vec someVec;
float f = someVec.x + someVec.y + 0.3;
vec otherVec = someVec.xyz + someVec.wwyz;
```
Matrices do not allow for swizzling, and indexing is not supported for now.

Every data type has a constructor by the same name. They reflect GLSL behavior
- Vector constructors with one argument initialize all components to that value
- Vector constructors with 2 or 3 arguments initialize the remaining components to 0. 
- Matrix constructors with one scalar argument initialize all values of its diagonal to that value
- Matrix constructors with multiple scalar values store them in column-major order (first 4 in the first column, next 4 in the second, etc). The remaining values are filled with the identity matrix
- Matrix constructors with vector arguments store them in their columns in order. The remaining values are filled with the identity matrix

```glsl
float a = float(3);	//Serves no purpouse
vec v = vec(1.)		// [1, 1, 1, 1]
vec v2 = vec(1, 2)	// [1, 2, 0, 0]
```

### Operators

All operations are applied component-wise, except matrix and vector multiplication, which transforms the vector by that matrix.
In order of precedence, from lower to higher:

1. ?:				_(Conditional operator)_
2. ||				_(Logical OR)_
3. &&				_(Logical AND)_
4. < > <= >= == !=	_(Comparators)_
5. \- +
6. / *
7. max min			_(Minimum and maximum)_
8. float() vec() mat() _(Constructors)_
9. ||x||			_(Length)_
10. a.x				_(Swizzling)_

Logical operators can not be used outside of _if_ and _for_ conditions.
Precedence can be avoided by wrapping expressions in parenthesis.


```glsl
float a = 2.;
float b = a min 3 max 0;	// clamping
vec v = vec(1, 0);
float c = ||v||;			// Vector length
```
Function calls are of the form
```
func(param1, param2...)
```
as in other languages.

### Statements

A statement can be a:
- Declaration
```
<type> <identifier>;
<type> <identifier> = <expression>;
```
- Assignment
```
<identifier> = <expression>;
<identifier>.<swizzle> = expression;
```
Some operators are allowed during assignment:
```
+= -= *= /=
```
- Early return
```
return;
```
- Code block
```
{ [statements] }
```
- If (else) condition
```
if(condition)
	<then-statement>
[else]
	<else-statement>
```
- For loop
```
for(<declaration>; <condition>; <increment>)
```
A declaration is obligatory. The maximum number of iterations must be easily determinable at compile time. _Increment_ can only be assignments of the type:
```
a += <constant>
a -= <constant>
```
- Break (only inside loops)
```
break;
```


### Function definition
```
void <identifier>([parameter declarations]) { [body] }
<type> <identifier>([parameter declarations]) = [return-value] { [body] }
void <identifier>([parameter declarations]) [return-value]
```

_return-value_ is an expression that evaluates at the end of the function body and defines the returned value. A function can return early with the _return_ statement, but can not specify another expression.
The entry point of the shader is always the _void main()_ function.
Standard GLSL functions are available for use (clamp, abs, normalize, etc).

## Development difficulties and shortcomings

GLSL has a lengthy standard and imposes many restrictions. The set of features necessary to allow a complex shader to compile were a challenge.
There were some complications when porting existing shaders to CSL due to all vectors and matrices being of the same size.
At the same time, standard functions are already overloaded and accept different input types. This, and swizzling makes type checking complicated.

## Future extensions

- More operators that simplify common patterns in raymarching: Relatively easy implementation, mainly affects syntax.
- Extensive type checking of standard functions: Requires more investigation on the GLSL standard
- Compiling to HLSL (DirectX shader language): May require a more generic reimplementation of the code generator and some changes in the AST
- Matrix indexing: Relatively easy to add with better type checks implemented

## References

- GLSL parser reference (https://github.com/nnesse/glsl-parser)
- GLSL core reference (https://www.khronos.org/opengl/wiki/Core_Language_(GLSL))
- GLSL control structures (http://learnwebgl.brown37.net/12_shader_language/glsl_control_structures.html)
- Dangling else problem (http://marvin.cs.uidaho.edu/Teaching/CS445/danglingElse.html) 
	and (https://stackoverflow.com/questions/1737460/how-to-find-shift-reduce-conflict-in-this-yacc-file)
- C operator precedence (https://en.cppreference.com/w/c/language/operator_precedence)
- GLSL data types (http://learnwebgl.brown37.net/12_shader_language/glsl_data_types.html)
	and (https://www.khronos.org/opengl/wiki/Data_Type_(GLSL))
- ThreeJs mouse input (https://stackoverflow.com/questions/55850554/how-can-i-pass-the-mouse-positions-from-js-to-shader-through-a-uniform)
- ThreeJs API reference (https://threejs.org/docs/#api/en/materials/ShaderMaterial)
- HTML file upload (https://stackoverflow.com/a/40580004)
- Fragment shader visualizer (https://threejsfundamentals.org/threejs/lessons/threejs-shadertoy.html)
- "Spiky cube" shader example (https://www.shadertoy.com/view/Wsjfzd)
- Primitives shader example (https://www.shadertoy.com/view/Xds3zN)
- Rain shader example (https://webgl-shaders.com/shaders/frag-rain.glsl)