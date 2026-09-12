# Virex

Virex is a simple programming language designed to execute `.vx` `.vxm` files using an interpreter written in C++.

## Basic Syntax

### Variables
```virex
let x = 10;
let y = 2 * (x + 3);
x = x + 5;
```

### Function
There are two types of functions: public and private.

```virex
fn mul(a, b) {
  return a * b;
}
```

Public functions are used only within .vxm files and can be accessed by any module via `import "MODULE_NAME"`.
```virex
public fn mul(a, b) {
  return a * b;
}
```

### Output
```virex
print("Hello Virex");
print(x);
```

### Math Functions
```virex
print(sin(1.57));
print(sqrt(16));
print(pow(2, 8));
```

Supported functions: `sin`, `cos`, `tan`, `sqrt`, `abs`, `pow`, `log`, `exp`, `floor`, `ceil`, `round`.

Additional math functions: `sum`, `average`, `median`, `variance`, `stddev`, `matrix`, `mget`, `mset`, `transpose`, `matrixAdd`, `matrixMul`, `vector`, `dot`, `cross`, `magnitude`, `normalize`, and `distance`.

Additional string functions: `startsWith`, `endsWith`, `indexOf`, `replace`, `repeat`, `reverse`, `charAt`, `isNumber`, `regexMatch`, and `regexReplace`.

System and file functions: `copyFile`, `moveFile`, `createDirectory`, `isDirectory`, `fileSize`, `time`, `sleep`, `currentDirectory`, and `platform`.

The language also supports `break`, `continue`, `null`, `try/catch`, native dictionaries, and system command execution:

```virex
let data = dict();
data = dictSet(data, "name", "Virex");
print(dictGet(data, "name"));

try {
    readFile("missing.txt");
} catch (error) {
    print(error);
}

shell("echo Hello");
```

Dictionary functions: `dict`, `dictGet`, `dictSet`, and `dictKeys`.

`shell` returns the exit code of the executed system command.

## JSON and Complex Numbers

```virex
let data = jsonParse("{\"name\":\"Virex\",\"version\":1}");
print(objectGet(data, "name"));
data = objectSet(data, "ready", true);
writeFile("config.json", jsonStringify(data));

let z = complex(2, 3);
print(z * complex(1, -1));
print(real(z));
print(imag(z));
print(complexAbs(z));
```

JSON functions: `jsonParse`, `jsonStringify`, `objectGet`, `objectSet`, and `objectKeys`.

Complex number functions: `complex`, `real`, `imag`, and `complexAbs`.

The operators `+`, `-`, `*`, and `/` also work with complex numbers.

## Windows and Drawing

Virex can create native Windows windows and draw using GDI:

```virex
let screen = window("Virex", 640, 400);
windowClear(screen, 25, 30, 40);
drawRect(screen, 40, 40, 220, 120, 30, 150, 240);
drawText(screen, 60, 190, "Hello from Virex", 255, 255, 255);
windowWait(5000);
windowClose(screen);
```

Available functions: `window`, `windowOpen`, `windowWidth`, `windowHeight`, `windowClose`, `windowClear`, `drawRect`, `drawLine`, `drawText`, `windowRefresh`, `windowPump`, and `windowWait`.

Drawing commands are automatically stored and replayed during `WM_PAINT` events.

This first graphics API targets Windows and uses Win32/GDI.

Color values are RGB components ranging from `0` to `255`.

## Direct3D 11 GPU Rendering

Virex also includes a Direct3D 11 backend for hardware-accelerated rendering on Windows:

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

The backend uses Direct3D 11, a hardware device, a swap chain, a vertex shader, and an HLSL pixel shader.

GPU coordinates are normalized between `-1` and `1`, while colors use values between `0` and `1`.

`gpuLine` draws a GPU line using two points and an RGB color, while `gpuRect` draws a filled rectangle.

`CompleteTest/main.vx` now uses `gpuLine` to render the cube directly with Direct3D 11.

24-bit and 32-bit BMP textures can also be loaded and rendered on the GPU:

```virex
let screen = window("Texture", 640, 480);
gpuInit(screen);
let image = gpuLoadTexture(screen, "image.bmp");
gpuClear(screen, 0.05, 0.05, 0.08);
gpuDrawTexture(screen, image, -0.8, 0.8, 0.8, -0.8);
gpuPresent(screen);
```

Keyboard and mouse input are available through `keyDown`, `mouseX`, `mouseY`, and `mouseDown`.

## Assembly

The current configuration targets maximum compatibility on Windows:

- `x86_64`
- Intel syntax
- Windows x64 ABI
- Clang integrated assembler
- `O2` optimization
- Return value in `RAX`

```virex
print(ASM_config());
let result = ASM_snippet("mov rax, 42");
print(result);
```

`ASM_snippet` accepts an argument-free assembly fragment and executes it as a function returning a 64-bit integer in `RAX`.

Virex temporarily compiles the fragment into a DLL using Clang, loads it, executes it, and then deletes the temporary files.

Since this executes arbitrary native code inside the interpreter process, it should only be used with trusted code.

The `VIREX_CLANG` environment variable can be used to specify a different Clang executable.

### Python-like Console Mode

- `virex file.vx` — Executes a script from any directory
- `virex -i` — Opens the interactive REPL
- `virex --help` — Displays the help page
- `virex --version` — Displays the current version
- `virex --build-info` — Displays compiled features
- `virex --no-graphics file.vx` — Runs a script without creating a window
