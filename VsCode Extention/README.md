# Virex VS Code Extension

Syntax highlighting and file icons for Virex scripts.

## Features

- **Syntax Highlighting**: Full support for Virex language syntax
  - Keywords: `let`, `fn`, `if`, `else`, `while`, `for`, `return`, `import`, `public`
  - Built-in functions: math, string, list, and file operations
  - Comments, strings, numbers, and operators
  
- **File Icons**: Custom icons for `.vx` and `.vxm` files

- **Language Support**: 
  - `.vx` files: Virex scripts
  - `.vxm` files: Virex modules

## Installation

### From the Repository

1. Copy the `vscode-extension` folder to your VS Code extensions directory:
   - **Windows**: `%USERPROFILE%\.vscode\extensions\virex-syntax-1.0.0`
   - **macOS**: `~/.vscode/extensions/virex-syntax-1.0.0`
   - **Linux**: `~/.vscode/extensions/virex-syntax-1.0.0`

2. Restart VS Code or reload the window (Ctrl+R / Cmd+R)

### Manual Installation via VSIX

```bash
# Install from the extension folder
code --install-extension ./vscode-extension
```

## Supported Language Features

### Keywords
```virex
let x = 10;           # Variable declaration
fn add(a, b) { }      # Function definition
public fn math() { }  # Public function
if (x > 5) { }        # Conditional
while (true) { }      # Loop
for (;;) { }          # For loop
return x;             # Return statement
import "module";      # Module import
```

### Built-in Functions

**Math**: `sin`, `cos`, `tan`, `sqrt`, `abs`, `pow`, `log`, `exp`, `floor`, `ceil`, `round`, `min`, `max`, `clamp`, `rand`

**String**: `upper`, `lower`, `trim`, `split`, `join`, `substr`, `concat`, `str`

**List**: `list`, `push`, `pop`, `append`, `get`, `set`, `contains`, `len`

**File**: `readFile`, `writeFile`, `exists`

### Operators

- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Logical: `&&`, `||`, `!`
- Assignment: `=`

### Comments

```virex
# This is a comment
let x = 42; # Inline comment
```

## Example

Create a file `hello.vx`:

```virex
print("Hello, Virex!");

let name = "World";
print(upper(name));

let x = 2 + 3 * 4;
print(x);
```

Execute with:
```bash
virex hello.vx
```

## License

MIT
