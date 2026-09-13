# Virex Language Documentation

Virex is a lightweight scripting language, implemented as a tree-walking interpreter in C++, for executing `.vx` (script) and `.vxm` (module) files. It ships with a large built-in standard library covering math, strings, statistics, matrices/vectors, complex numbers, JSON, the filesystem, system commands, native Win32/GDI windows, Direct3D 11 GPU rendering, and even inline x86_64 assembly execution.

- **License:** MIT (Copyright (c) 2026 Sad44587)
- **Repository:** [Sad44587/Virex-Code](https://github.com/Sad44587/Virex-Code)
- **Platform:** Primarily Windows (native windowing, GPU rendering, and assembly features rely on Win32/Direct3D/Clang)
- **Current release:** `v0.4.0` (see `Executables/v0.4.0/VirexSetup.exe`)

> **Note on scope:** This repository publishes the Virex installer/executable and a folder of example scripts, but not the interpreter's C++ source code. This documentation is therefore based on the published `README.md` and on every example script shipped in the `Exemples/` folder.

---

## Table of Contents

1. [Installation & Running Scripts](#installation--running-scripts)
2. [Command-Line Interface](#command-line-interface)
3. [Language Basics](#language-basics)
   - [Variables](#variables)
   - [Functions](#functions)
   - [Modules (`.vxm` files)](#modules-vxm-files)
   - [Control Flow](#control-flow)
   - [Output & Input](#output--input)
   - [Types, `null`, and Errors](#types-null-and-errors)
4. [Standard Library Reference](#standard-library-reference)
   - [Math Functions](#math-functions)
   - [Statistics Functions](#statistics-functions)
   - [Vector Functions](#vector-functions)
   - [Matrix Functions](#matrix-functions)
   - [Complex Number Functions](#complex-number-functions)
   - [String Functions](#string-functions)
   - [Regex Functions](#regex-functions)
   - [Dictionary Functions](#dictionary-functions)
   - [List Functions](#list-functions)
   - [JSON / Object Functions](#json--object-functions)
   - [File & System Functions](#file--system-functions)
   - [Shell Execution](#shell-execution)
   - [Windowing & GDI Drawing](#windowing--gdi-drawing)
   - [Direct3D 11 GPU Rendering](#direct3d-11-gpu-rendering)
   - [Keyboard & Mouse Input](#keyboard--mouse-input)
   - [Inline Assembly](#inline-assembly)
5. [Full Example Scripts](#full-example-scripts)
6. [Security Considerations](#security-considerations)
7. [License](#license)

---

## Installation & Running Scripts

Virex is distributed as a Windows installer (`VirexSetup.exe`, found under `Executables/v0.4.0/` in this repository). After installing, the `virex` executable is available and can run any `.vx` script directly, similar to a Python-style interpreter.

```bash
virex file.vx
```

## Command-Line Interface

Virex behaves like a small console-based interpreter with the following invocation modes:

| Command | Description |
|---|---|
| `virex file.vx` | Executes a script from any directory |
| `virex -i` | Opens the interactive REPL |
| `virex --help` | Displays the help page |
| `virex --version` | Displays the current interpreter version |
| `virex --build-info` | Displays which optional features were compiled in (e.g. GPU/Direct3D, assembly) |
| `virex --no-graphics file.vx` | Runs a script without creating a native window |

---

## Language Basics

### Variables

Variables are declared with `let` and can be reassigned freely afterward. Standard arithmetic and parenthesized expressions are supported.

```virex
let x = 10;
let y = 2 * (x + 3);
x = x + 5;
```

Note that `let` is optional for later assignments and even for first use in some examples (see `lst = list();` in `test_functions.vx`), but using `let` for first declaration is the documented convention.

### Functions

Functions are declared with `fn` and return values with `return`.

```virex
fn mul(a, b) {
  return a * b;
}
```

There are two kinds of functions:

- **Private functions** (`fn ...`) — usable only within the file that defines them.
- **Public functions** (`public fn ...`) — usable within `.vxm` module files, and importable from other files/modules via:

```virex
import "MODULE_NAME";
```

```virex
public fn mul(a, b) {
  return a * b;
}
```

### Modules (`.vxm` files)

A `.vxm` file is a **module**: a file that only contains `public fn` declarations (and optionally private helper functions), with no top-level script logic of its own. Conceptually it works much like a Roblox `ModuleScript` — you write reusable logic once in the module, then `import` it from any `.vx` script to call its public functions directly, as if they were defined locally.

- A module file exposes its **public functions** to any script that imports it.
- Public functions inside a module can freely call each other (they share the same scope).
- A script imports a module by its file name, without the `.vxm` extension:

```virex
import "cube";
```

- Once imported, the module's public functions are called exactly like local functions — no namespace prefix is required.

**Example module — `cube.vxm`:**

This module implements the 3D math (rotation and projection) used to render a rotating cube. Every function is declared `public fn` so that it can be used from the importing script.

```virex
public fn rotateX(point, angle) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  return vector(x, y * cos(angle) - z * sin(angle), y * sin(angle) + z * cos(angle));
}

public fn rotateY(point, angle) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  return vector(x * cos(angle) + z * sin(angle), y, -x * sin(angle) + z * cos(angle));
}

public fn rotateZ(point, angle) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  return vector(x * cos(angle) - y * sin(angle), x * sin(angle) + y * cos(angle), z);
}

public fn transform(point, angleX, angleY, angleZ) {
  let rotated = rotateX(point, angleX);
  rotated = rotateY(rotated, angleY);
  return rotateZ(rotated, angleZ);
}

public fn project(point, width, height, scale) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  let depth = 5 + z;
  let factor = scale / depth;
  return vector(width / 2 + x * factor, height / 2 - y * factor);
}

public fn projectGpu(point, width, height, scale) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  let depth = 5 + z;
  let factor = scale / depth;
  return vector(x * factor / (width / 2), y * factor / (height / 2));
}
```

**Example script that imports it — `3d_cube.vx`:**

```virex
import "cube";

let screen = window("Virex - Cube qui tourne", 800, 600);
gpuInit(screen);
let angleX = 0;
// ...

let point = get(vertices, index);
let rotated = transform(point, angleX, angleY, angleZ);   // calls a public fn from cube.vxm
let projectedPoint = projectGpu(rotated, screenWidth, screenHeight, scale); // same here
```

Notice that `transform(...)` and `projectGpu(...)` are defined in `cube.vxm` but are called from `3d_cube.vx` exactly like local functions, once the module has been imported. See [`3d_cube.vx`](#3d_cubevx--rotating-3d-cube-uses-cubevxm) in the full examples section for the complete, runnable script.

### Control Flow

Virex supports `if` / `else if` / `else`, `while` loops, `break`, and `continue`:

```virex
let value = 2;
if (value == 1) {
  print("one");
} else if (value == 2) {
  print("two");
} else {
  print("other");
}
```

```virex
let total = 0;
let index = 0;
while (index < 6) {
  index = index + 1;
  if (index == 2) {
    continue;
  }
  if (index == 5) {
    break;
  }
  total = total + index;
}
print(total);
```

### Output & Input

```virex
print("Hello Virex");
print(x);
```

Reading from the console:

```virex
name = input("What is your name? ");
age = inputNum("Age: ");
```

- `input(prompt)` — reads a line of text from the console.
- `inputNum(prompt)` — reads a numeric value from the console.

### Types, `null`, and Errors

- `type(value)` returns the runtime type of a value (e.g. numbers, strings, booleans, lists).
- `null` is a first-class value and can be compared with `==`.
- Line comments start with `#` (see the first line of `3d_cube.vx`).
- `try` / `catch` provides structured error handling:

```virex
let empty = null;
print(type(empty));
print(empty == null);

try {
  readFile("missing-file.txt");
} catch (error) {
  print("caught: " + error);
}
```

---

## Standard Library Reference

### Math Functions

Trigonometric, rounding, and general-purpose math functions:

`sin`, `cos`, `tan`, `sqrt`, `abs`, `pow`, `log`, `exp`, `floor`, `ceil`, `round`

Also available in general-purpose scripts (from `test_functions.vx`): `min(...)`, `max(...)`, `range(stop)`, `range(start, stop)`, `range(start, stop, step)`, and `number(string)` to parse a string into a numeric value.

```virex
print(sin(1.57));
print(sqrt(16));
print(pow(2, 8));

print(floor(3.7));
print(ceil(3.2));
print(round(3.5));

print(min(10, 5, 8, 2));
print(max(10, 5, 8, 2));

let r = range(5);        // 0..4
let r2 = range(1, 5);    // 1..4
let r3 = range(0, 10, 2);// 0,2,4,6,8

let n = number("123");
print(n + 77);
```

### Statistics Functions

`sum`, `average`, `median`, `variance`, `stddev`

These operate on list-like values such as those produced by `range(...)`:

```virex
let values = range(1, 6);
print(sum(values));
print(average(values));
print(median(values));
print(variance(values));
print(stddev(values));
```

### Vector Functions

`vector`, `dot`, `cross`, `magnitude`, `normalize`, `distance`

```virex
let a = vector(1, 2, 3);
let b = vector(4, 5, 6);
print(a);
print(dot(a, b));
print(magnitude(a));
print(normalize(a));
print(distance(a, b));
print(cross(a, b));
```

### Matrix Functions

`matrix`, `mget`, `mset`, `transpose`, `matrixAdd`, `matrixMul`

```virex
let a = matrix(2, 2, 0);   // 2x2 matrix filled with 0
mset(a, 0, 0, 1);
mset(a, 0, 1, 2);
mset(a, 1, 0, 3);
mset(a, 1, 1, 4);
print(a);
print(mget(a, 1, 0));
print(transpose(a));

let b = matrix(2, 2, 1);   // 2x2 matrix filled with 1
print(matrixAdd(a, b));
print(matrixMul(a, b));
```

### Complex Number Functions

`complex`, `real`, `imag`, `complexAbs`

The arithmetic operators `+`, `-`, `*`, and `/` are overloaded to work directly on complex numbers.

```virex
let a = complex(2, 3);
let b = complex(1, -1);
print(a);
print(a + b);
print(a * b);
print(a / b);
print(real(a));
print(imag(a));
print(complexAbs(a));
```

### String Functions

`startsWith`, `endsWith`, `indexOf`, `replace`, `repeat`, `reverse`, `charAt`, `isNumber`, `regexMatch`, `regexReplace`

```virex
let text = "Bonjour Virex";
print(startsWith(text, "Bonjour"));
print(endsWith(text, "Virex"));
print(indexOf(text, "Virex"));
print(replace(text, "Virex", "monde"));
print(repeat("ha", 3));
print(reverse("Virex"));
print(charAt(text, 1));
print(isNumber("123.45"));
print(isNumber("hello"));
```

### Regex Functions

`regexMatch(text, pattern)`, `regexReplace(text, pattern, replacement)`

```virex
print(regexMatch("Virex 123", "[0-9]+"));
print(regexReplace("Virex 123", "[0-9]+", "language"));
```

### Dictionary Functions

Virex has native dictionaries: `dict`, `dictGet`, `dictSet`, `dictKeys`

```virex
let data = dict();
data = dictSet(data, "name", "Virex");
data = dictSet(data, "version", 1);
print(dictGet(data, "name"));
print(dictGet(data, "missing")); // returns a default/empty value when key is absent
print(dictKeys(data));
```

### List Functions

`list()`, `push(list, value)`, `get(collection, index)`, `len(collection)`, `str(value)`

- `list()` — creates a new, empty list.
- `push(list, value)` — appends a value to the end of a list.
- `get(collection, index)` — reads an element by zero-based index from a list **or** a vector (used in `cube.vxm`/`3d_cube.vx` to pull `x`/`y`/`z` out of a `vector(...)`).
- `len(collection)` — returns the number of elements in a list.
- `str(value)` — converts a value to its string representation (e.g. for concatenation with `+`).

```virex
let vertices = list();
push(vertices, vector(-1, -1, -1));
push(vertices, vector(1, -1, -1));

let index = 0;
while (index < len(vertices)) {
  let point = get(vertices, index);
  let x = get(point, 0);
  index = index + 1;
}

print("FPS: " + str(round(60)));
```

### JSON / Object Functions

`jsonParse`, `jsonStringify`, `objectGet`, `objectSet`, `objectKeys`

```virex
let data = jsonParse("{\"name\":\"Virex\",\"version\":1,\"enabled\":true,\"items\":[1,2,3]}");
print(objectGet(data, "name"));
print(objectGet(data, "version"));
print(objectGet(data, "items"));
print(objectKeys(data));

let changed = objectSet(data, "ready", true);
print(jsonStringify(changed));
```

### File & System Functions

File I/O: `readFile`, `writeFile`, `appendFile`, `exists`, `deleteFile`, `fileSize`, `copyFile`, `moveFile`, `createDirectory`, `isDirectory`

System info: `time`, `timeMs`, `sleep`, `currentDirectory`, `platform`

```virex
writeFile("test.txt", "Hello Virex!\nLine 2");
let content = readFile("test.txt");
print(content);

appendFile("test.txt", "\nLine 3");
print(readFile("test.txt"));

print(exists("test.txt"));
deleteFile("test.txt");
print(exists("test.txt"));
```

```virex
let path = "system_test.txt";
writeFile(path, "Virex");
print(exists(path));
print(fileSize(path));
copyFile(path, "system_copy.txt");
print(exists("system_copy.txt"));
moveFile("system_copy.txt", "system_moved.txt");
print(exists("system_moved.txt"));
print(isDirectory("."));
print(platform());
print(currentDirectory());
print(time() > 0);
deleteFile(path);
deleteFile("system_moved.txt");
```

Simple timestamp read:

```virex
print(timeMs());
```

### Shell Execution

`shell(command)` executes a system command and returns its exit code.

```virex
shell("echo Hello");
```

### Windowing & GDI Drawing

Virex can create native Win32 windows and draw onto them with GDI. Colors are RGB components in the range `0`–`255`. Drawing commands issued between frames are automatically stored and replayed during `WM_PAINT` events.

Available functions: `window`, `windowOpen`, `windowWidth`, `windowHeight`, `windowClose`, `windowClear`, `drawRect`, `drawLine`, `drawText`, `windowRefresh`, `windowPump`, `windowWait`

```virex
let screen = window("Virex", 640, 400);
windowClear(screen, 25, 30, 40);
drawRect(screen, 40, 40, 220, 120, 30, 150, 240);
drawText(screen, 60, 190, "Hello from Virex", 255, 255, 255);
windowWait(5000);
windowClose(screen);
```

### Direct3D 11 GPU Rendering

For hardware-accelerated rendering, Virex includes a Direct3D 11 backend (hardware device, swap chain, vertex shader, and an HLSL pixel shader). GPU coordinates are normalized between `-1` and `1`; colors use values between `0` and `1`.

Key functions: `gpuInit`, `gpuClear`, `gpuTriangle`, `gpuRect`, `gpuLine`, `gpuPresent`, `gpuShutdown`, `gpuLoadTexture`, `gpuDrawTexture`

```virex
let screen = window("GPU Virex", 640, 480);
gpuInit(screen);
gpuClear(screen, 0.06, 0.08, 0.12);
gpuTriangle(screen, 0, 0.1, 0.55, 0.2, 0.8, 1.0);
gpuPresent(screen);
windowWait(1000);
gpuShutdown(screen);
windowClose(screen);
```

`gpuRect` draws a filled rectangle, `gpuLine` draws a line between two points with an RGB color:

```virex
let screen = window("Virex Direct3D 11", 640, 480);
gpuInit(screen);
gpuClear(screen, 0.06, 0.08, 0.12);
gpuRect(screen, -0.8, 0.8, -0.3, 0.3, 0.8, 0.3, 0.2);
gpuTriangle(screen, 0, 0.1, 0.55, 0.2, 0.8, 1.0);
gpuPresent(screen);
windowWait(1000);
gpuShutdown(screen);
windowClose(screen);
```

24-bit and 32-bit BMP textures can be loaded and drawn on the GPU:

```virex
let screen = window("Texture", 640, 480);
gpuInit(screen);
let image = gpuLoadTexture(screen, "image.bmp");
gpuClear(screen, 0.05, 0.05, 0.08);
gpuDrawTexture(screen, image, -0.8, 0.8, 0.8, -0.8);
gpuPresent(screen);
```

### Keyboard & Mouse Input

`keyDown(keyName)`, `mouseX(window)`, `mouseY(window)`, `mouseDown(buttonIndex)`

```virex
let screen = window("Input test", 320, 240);
print(keyDown("SPACE"));
print(mouseX(screen));
print(mouseY(screen));
print(mouseDown(0));
windowWait(100);
windowClose(screen);
```

### Inline Assembly

Virex can compile and execute raw x86_64 assembly snippets at runtime, under the following fixed configuration:

- Architecture: `x86_64`
- Syntax: Intel
- ABI: Windows x64
- Compiler: Clang integrated assembler
- Optimization: `O2`
- Return value convention: `RAX`

```virex
print(ASM_config());
let result = ASM_snippet("mov rax, 42");
print(result);
```

- `ASM_config()` — returns the current assembly target configuration.
- `ASM_snippet(code)` — accepts an argument-free assembly fragment and executes it as a function returning a 64-bit integer in `RAX`.

Internally, Virex compiles the fragment into a temporary DLL using Clang, loads it, executes it, and deletes the temporary files afterward. The Clang executable used can be overridden via the `VIREX_CLANG` environment variable.

> ⚠ **This executes arbitrary native machine code inside the interpreter process.** Only run `ASM_snippet` with trusted code — see [Security Considerations](#security-considerations).

---

## Full Example Scripts

All scripts below are taken verbatim from the `Exemples/` folder of the repository.

### `test_language_features.vx` — loops, `null`, dictionaries, `try`/`catch`, `shell`

```virex
let total = 0;
let index = 0;
while (index < 6) {
  index = index + 1;
  if (index == 2) {
    continue;
  }
  if (index == 5) {
    break;
  }
  total = total + index;
}
print(total);

let empty = null;
print(type(empty));
print(empty == null);

let data = dict();
data = dictSet(data, "name", "Virex");
data = dictSet(data, "version", 1);
print(dictGet(data, "name"));
print(dictGet(data, "missing"));
print(dictKeys(data));

try {
  readFile("missing-file.txt");
} catch (error) {
  print("caught: " + error);
}

shell("echo VirexShell");
```

### `test_functions.vx` — types, math, ranges, file I/O

```virex
print("=== Type Testing ===");
print(type(42));
print(type("hello"));
print(type(true));
lst = list();
print(type(lst));

print("=== Math Functions ===");
print(floor(3.7));
print(ceil(3.2));
print(round(3.5));

print(sqrt(16));
print(pow(2, 8));
print(abs(-5));

print("=== Min/Max ===");
print(min(10, 5, 8, 2));
print(max(10, 5, 8, 2));

print("=== Range ===");
r = range(5);
print(r);

r2 = range(1, 5);
print(r2);

r3 = range(0, 10, 2);
print(r3);

print("=== String to Number ===");
n = number("123");
print(n + 77);

print("=== File Operations ===");
writeFile("test.txt", "Hello Virex!\nLine 2");
content = readFile("test.txt");
print(content);

appendFile("test.txt", "\nLine 3");
updated = readFile("test.txt");
print("=== After Append ===");
print(updated);

print("=== File Existence ===");
print(exists("test.txt"));
deleteFile("test.txt");
print(exists("test.txt"));
```

### `test_else_if.vx` — conditional branching

```virex
let value = 2;
if (value == 1) {
  print("one");
} else if (value == 2) {
  print("two");
} else {
  print("other");
}
```

### `test_strings.vx` — string utilities

```virex
let text = "Bonjour Virex";
print(startsWith(text, "Bonjour"));
print(endsWith(text, "Virex"));
print(indexOf(text, "Virex"));
print(replace(text, "Virex", "monde"));
print(repeat("ha", 3));
print(reverse("Virex"));
print(charAt(text, 1));
print(isNumber("123.45"));
print(isNumber("hello"));
```

### `test_regex.vx` — regular expressions

```virex
print(regexMatch("Virex 123", "[0-9]+"));
print(regexReplace("Virex 123", "[0-9]+", "language"));
```

### `test_statistics.vx` — statistics over a range

```virex
let values = range(1, 6);
print(sum(values));
print(average(values));
print(median(values));
print(variance(values));
print(stddev(values));
```

### `test_vectors.vx` — vector math

```virex
let a = vector(1, 2, 3);
let b = vector(4, 5, 6);
print(a);
print(dot(a, b));
print(magnitude(a));
print(normalize(a));
print(distance(a, b));
print(cross(a, b));
```

### `test_matrices.vx` — matrix math

```virex
let a = matrix(2, 2, 0);
mset(a, 0, 0, 1);
mset(a, 0, 1, 2);
mset(a, 1, 0, 3);
mset(a, 1, 1, 4);
print(a);
print(mget(a, 1, 0));
print(transpose(a));

let b = matrix(2, 2, 1);
print(matrixAdd(a, b));
print(matrixMul(a, b));
```

### `test_complex.vx` — complex numbers

```virex
let a = complex(2, 3);
let b = complex(1, -1);
print(a);
print(a + b);
print(a * b);
print(a / b);
print(real(a));
print(imag(a));
print(complexAbs(a));
```

### `test_json.vx` — JSON parsing/manipulation

```virex
let data = jsonParse("{\"name\":\"Virex\",\"version\":1,\"enabled\":true,\"items\":[1,2,3]}");
print(objectGet(data, "name"));
print(objectGet(data, "version"));
print(objectGet(data, "items"));
print(objectKeys(data));
let changed = objectSet(data, "ready", true);
print(jsonStringify(changed));
```

### `test_system.vx` — filesystem & system info

```virex
let path = "system_test.txt";
writeFile(path, "Virex");
print(exists(path));
print(fileSize(path));
copyFile(path, "system_copy.txt");
print(exists("system_copy.txt"));
moveFile("system_copy.txt", "system_moved.txt");
print(exists("system_moved.txt"));
print(isDirectory("."));
print(platform());
print(currentDirectory());
print(time() > 0);
deleteFile(path);
deleteFile("system_moved.txt");
```

### `test_time.vx` — timestamps

```virex
print(timeMs());
```

### `test_input.vx` — console input

```virex
print("=== Input Testing ===");
name = input("What is your name? ");
print("Hello, ");
print(name);

print("Enter your age: ");
age = inputNum("Age: ");
print("You are ");
print(age);
print(" years old");
```

### `test_input_state.vx` — keyboard & mouse polling

```virex
let screen = window("Input test", 320, 240);
print(keyDown("SPACE"));
print(mouseX(screen));
print(mouseY(screen));
print(mouseDown(0));
windowWait(100);
windowClose(screen);
```

### `test_gpu.vx` — Direct3D 11 shapes

```virex
let screen = window("Virex Direct3D 11", 640, 480);
gpuInit(screen);
gpuClear(screen, 0.06, 0.08, 0.12);
gpuRect(screen, -0.8, 0.8, -0.3, 0.3, 0.8, 0.3, 0.2);
gpuTriangle(screen, 0, 0.1, 0.55, 0.2, 0.8, 1.0);
gpuPresent(screen);
windowWait(1000);
gpuShutdown(screen);
windowClose(screen);
```

### `test_texture.vx` — GPU texture loading (uses `texture_test.bmp`)

```virex
let screen = window("GPU texture test", 640, 480);
gpuInit(screen);
let texture = gpuLoadTexture(screen, "tests/texture_test.bmp");
gpuClear(screen, 0.05, 0.05, 0.08);
gpuDrawTexture(screen, texture, -0.6, 0.6, 0.6, -0.6);
gpuPresent(screen);
windowWait(1000);
gpuShutdown(screen);
windowClose(screen);
```

### `test_assembly.vx` — inline x86_64 assembly

```virex
print(ASM_config());
print(ASM_snippet("mov rax, 42"));
```

### `cube.vxm` — reusable 3D math module

A pure module: it defines no top-level logic, only `public fn` declarations that a script can `import` and call. See [Modules (`.vxm` files)](#modules-vxm-files) for an explanation of how this works.

```virex
public fn rotateX(point, angle) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  return vector(x, y * cos(angle) - z * sin(angle), y * sin(angle) + z * cos(angle));
}

public fn rotateY(point, angle) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  return vector(x * cos(angle) + z * sin(angle), y, -x * sin(angle) + z * cos(angle));
}

public fn rotateZ(point, angle) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  return vector(x * cos(angle) - y * sin(angle), x * sin(angle) + y * cos(angle), z);
}

public fn transform(point, angleX, angleY, angleZ) {
  let rotated = rotateX(point, angleX);
  rotated = rotateY(rotated, angleY);
  return rotateZ(rotated, angleZ);
}

public fn project(point, width, height, scale) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  let depth = 5 + z;
  let factor = scale / depth;
  return vector(width / 2 + x * factor, height / 2 - y * factor);
}

public fn projectGpu(point, width, height, scale) {
  let x = get(point, 0);
  let y = get(point, 1);
  let z = get(point, 2);
  let depth = 5 + z;
  let factor = scale / depth;
  return vector(x * factor / (width / 2), y * factor / (height / 2));
}
```

### `3d_cube.vx` — rotating 3D cube (uses `cube.vxm`)

A full real-time demo that imports `cube.vxm`, builds a list of 8 cube vertices, rotates and projects them every frame with the module's public functions, and draws the wireframe cube with `gpuLine` while showing a live FPS counter.

```virex
# This file need the "cube.vxm" file to run properly.

import "cube";

let screen = window("Virex - Cube qui tourne", 800, 600);
gpuInit(screen);
let angleX = 0;
let angleY = 0;
let angleZ = 0;
let size = 1.4;
let lastFpsTime = timeMs();
let frameCount = 0;
let fps = 0;

let vertices = list();
push(vertices, vector(-size, -size, -size));
push(vertices, vector(size, -size, -size));
push(vertices, vector(size, size, -size));
push(vertices, vector(-size, size, -size));
push(vertices, vector(-size, -size, size));
push(vertices, vector(size, -size, size));
push(vertices, vector(size, size, size));
push(vertices, vector(-size, size, size));

while (windowOpen(screen)) {
  let screenWidth = windowWidth(screen);
  let screenHeight = windowHeight(screen);
  gpuClear(screen, 0.15, 0.16, 0.19);

  let projected = list();
  let index = 0;
  while (index < len(vertices)) {
    let point = get(vertices, index);
    let rotated = transform(point, angleX, angleY, angleZ);
    push(projected, projectGpu(rotated, screenWidth, screenHeight, min(screenWidth, screenHeight) * 0.32));
    index = index + 1;
  }

  gpuLine(screen, get(get(projected, 0), 0), get(get(projected, 0), 1), get(get(projected, 1), 0), get(get(projected, 1), 1), 0.3, 0.75, 1.0);
  gpuLine(screen, get(get(projected, 1), 0), get(get(projected, 1), 1), get(get(projected, 2), 0), get(get(projected, 2), 1), 0.3, 0.75, 1.0);
  gpuLine(screen, get(get(projected, 2), 0), get(get(projected, 2), 1), get(get(projected, 3), 0), get(get(projected, 3), 1), 0.3, 0.75, 1.0);
  gpuLine(screen, get(get(projected, 3), 0), get(get(projected, 3), 1), get(get(projected, 0), 0), get(get(projected, 0), 1), 0.3, 0.75, 1.0);

  gpuLine(screen, get(get(projected, 4), 0), get(get(projected, 4), 1), get(get(projected, 5), 0), get(get(projected, 5), 1), 1.0, 0.6, 0.2);
  gpuLine(screen, get(get(projected, 5), 0), get(get(projected, 5), 1), get(get(projected, 6), 0), get(get(projected, 6), 1), 1.0, 0.6, 0.2);
  gpuLine(screen, get(get(projected, 6), 0), get(get(projected, 6), 1), get(get(projected, 7), 0), get(get(projected, 7), 1), 1.0, 0.6, 0.2);
  gpuLine(screen, get(get(projected, 7), 0), get(get(projected, 7), 1), get(get(projected, 4), 0), get(get(projected, 4), 1), 1.0, 0.6, 0.2);

  gpuLine(screen, get(get(projected, 0), 0), get(get(projected, 0), 1), get(get(projected, 4), 0), get(get(projected, 4), 1), 0.45, 1.0, 0.6);
  gpuLine(screen, get(get(projected, 1), 0), get(get(projected, 1), 1), get(get(projected, 5), 0), get(get(projected, 5), 1), 0.45, 1.0, 0.6);
  gpuLine(screen, get(get(projected, 2), 0), get(get(projected, 2), 1), get(get(projected, 6), 0), get(get(projected, 6), 1), 0.45, 1.0, 0.6);
  gpuLine(screen, get(get(projected, 3), 0), get(get(projected, 3), 1), get(get(projected, 7), 0), get(get(projected, 7), 1), 0.45, 1.0, 0.6);

  frameCount = frameCount + 1;
  let now = timeMs();
  if (now - lastFpsTime >= 500) {
    fps = frameCount * 1000 / (now - lastFpsTime);
    frameCount = 0;
    lastFpsTime = now;
  }

  gpuPresent(screen);
  drawText(screen, 24, screenHeight - 58, "Cube qui tourne - GPU Direct3D 11", 245, 245, 245);
  drawText(screen, 24, screenHeight - 34, "Rotation X / Y / Z - Virex", 160, 175, 190);
  drawText(screen, screenWidth - 130, 28, "FPS: " + str(round(fps)), 180, 230, 190);

  angleX = angleX + 0.025;
  angleY = angleY + 0.035;
  angleZ = angleZ + 0.02;

  windowWait(16);
}

gpuShutdown(screen);
windowClose(screen);
```

This example also introduces `windowOpen(window)` (returns whether the window is still open, used as the render-loop condition) and `gpuLine(window, x1, y1, x2, y2, r, g, b)` (draws a GPU line between two normalized points with an RGB color, each channel `0`–`1`).

---

## Security Considerations

- **`shell(command)`** executes arbitrary system commands on the host machine. Only run scripts you trust.
- **`ASM_snippet(code)`** compiles and executes raw native machine code inside the interpreter process itself. This is effectively unrestricted code execution and should never be used with untrusted `.vx`/`.vxm` files.
- File functions (`writeFile`, `deleteFile`, `moveFile`, `copyFile`, `createDirectory`, etc.) operate directly on the filesystem with the permissions of the running process.

## License

Virex is released under the **MIT License**.

```
MIT License

Copyright (c) 2026 Sad44587

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

See the [`LICENSE`](https://github.com/Sad44587/Virex-Code/blob/main/LICENSE) file in the repository for the full text.
