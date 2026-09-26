# Virex — Documentation

Virex est un mini-langage de programmation interprété, écrit en **C++17**, qui exécute des fichiers `.vx` (scripts) et `.vxm` (modules). L'interpréteur est un fichier unique (`main.cpp` + headers dans `src/`) compilé avec Clang.

> Analogie Roblox / Python : un `.vxm` avec des `public fn` joue le même rôle qu'un `ModuleScript` exposant des fonctions via `require()`. Un `.vx` est l'équivalent d'un `Script` / point d'entrée. Le mode `virex` sans argument (REPL) fonctionne comme taper `python` seul dans un terminal.

## Sommaire

- [Architecture du projet](#architecture-du-projet)
- [Installation et compilation](#installation-et-compilation)
- [Mode console](#mode-console)
- [Syntaxe de base](#syntaxe-de-base)
- [Modules et import](#modules-et-import)
- [Fonctions intégrées](#fonctions-intégrées)
- [Fenêtres et dessin (Windows / GDI)](#fenêtres-et-dessin-windows--gdi)
- [Rendu GPU Direct3D 11](#rendu-gpu-direct3d-11)
- [Assembleur inline (ASM_snippet)](#assembleur-inline-asm_snippet)
- [Extension VS Code](#extension-vs-code)
- [Erreurs possibles et corrections](#erreurs-possibles-et-corrections)

---

## Architecture du projet

```
Virex/
├── main.cpp                 # Point d'entrée (parsing des arguments CLI)
├── src/
│   ├── Lexer.h               # Découpage du code source en tokens
│   ├── Parser.h               # Construction de l'AST à partir des tokens
│   ├── Interpreter.h          # Exécution, gestion des imports .vxm
│   ├── VirexCore.h            # Valeurs, environnement, ~90 fonctions natives
│   ├── Graphics.h             # Fenêtres Win32 + dessin GDI
│   ├── Direct3D11.h           # Backend GPU Direct3D 11
│   └── Assembly.h             # Compilation/exécution de fragments ASM via Clang
├── build.bat                  # Compile + installe virex dans le PATH Windows
├── sample.vx / graphics.vx    # Exemples
├── mathlib.vxm                # Module math réutilisable d'exemple
├── CompleteTest/               # Démo : cube filaire tournant en Direct3D 11
├── tests/                      # Scripts .vx de test par fonctionnalité
├── vscode-extension/            # Coloration syntaxique + icônes pour VS Code
├── dist/                        # Sortie du build (virex.exe, README, sample.vx)
└── installer.iss               # Script Inno Setup (VirexSetup.exe)
```

## Installation et compilation

### Compiler depuis les sources

```bash
clang++ -std=c++17 -O2 main.cpp -o virex
```

À lancer depuis le dossier `Virex/` (racine du projet), car `main.cpp` inclut `src/Interpreter.h` par chemin relatif. Aucune option de link supplémentaire n'est nécessaire : les libs Direct3D (`d3d11.lib`, `dxgi.lib`, `d3dcompiler.lib`) sont liées automatiquement via des `#pragma comment(lib, ...)` dans `Direct3D11.h`.

### Build automatisé (recommandé, Windows)

```bat
build.bat
```

Ce script :
1. Compile `main.cpp` en `dist\virex.exe` avec `clang++ -std=c++17 -O2`.
2. Copie `README.md`, `sample.vx` et `build.bat` dans `dist/`.
3. Appelle `install-path.bat`, qui installe un lanceur `virex.cmd` dans `%AppData%\Local\Microsoft\WindowsApps` (déjà dans le `PATH` Windows) — utilisable ensuite depuis n'importe quel dossier.

Il existe aussi `installer.iss` (Inno Setup) permettant de générer `VirexSetup.exe`, un installeur graphique.

### Prérequis

- **Clang** installé et accessible (`clang++` dans le `PATH`), ciblant l'ABI Windows x64.
- Cible **Windows** obligatoire pour tout ce qui touche aux fenêtres (GDI), au GPU (Direct3D 11) et à l'assembleur inline (`ASM_snippet`) — le reste du langage (variables, fonctions, maths, fichiers, JSON…) est portable en C++17 standard.

## Mode console

Comme `python`, l'exécutable a plusieurs modes selon les arguments passés :

| Commande | Effet |
|---|---|
| `virex` (aucun argument, terminal interactif) | Ouvre le **REPL** interactif (`>>>`), ligne par ligne |
| `virex` (avec une entrée redirigée, ex. `virex < script.vx`) | Exécute directement le contenu reçu sur `stdin`, sans REPL |
| `virex fichier.vx` | Exécute un script depuis n'importe quel dossier |
| `virex -i` / `virex repl` | Ouvre le REPL interactif |
| `virex --help` / `-h` | Affiche l'aide |
| `virex --version` / `-v` | Affiche la version (`Virex 0.4.0`) |
| `virex --build-info` | Affiche les fonctionnalités compilées (langage, graphismes, assembleur) |
| `virex --no-graphics fichier.vx` | Exécute un script sans créer de fenêtre (désactive `VirexGraphics`) |

Dans le REPL, tape `exit` ou `quit` pour sortir. Chaque ligne tapée est interprétée immédiatement comme une instruction `.vx` complète (termine-la par `;`).

## Syntaxe de base

### Variables

```virex
let x = 10;
let y = 2 * (x + 3);
x = x + 5;
```

Pas de typage explicite. Types internes : nombre (`double`), chaîne, booléen, `null`, liste, dictionnaire/objet, nombre complexe.

### Fonctions

Deux visibilités : privée (défaut) et publique.

```virex
fn mul(a, b) {
  return a * b;
}

public fn mul(a, b) {   // utile uniquement dans un .vxm, exposée à l'import
  return a * b;
}
```

### Contrôle de flux

Le langage supporte `if` / `else` (avec `else if`), `while`, `for`, `break`, `continue`, `return`, et `try / catch` :

```virex
try {
    readFile("missing.txt");
} catch (error) {
    print(error);
}
```

### Affichage

```virex
print("Bonjour Virex");
print(x);
```

## Modules et import

| Extension | Rôle |
|---|---|
| `.vx` | Script exécutable, point d'entrée |
| `.vxm` | Module réutilisable, regroupe des `public fn` |

```virex
import "mathlib";
```

Résolution du chemin (voir `Interpreter::importModule`) :
- Le nom est résolu **relativement au dossier du script principal** (`baseDir_`), sauf si le chemin donné est absolu.
- Si aucune extension n'est précisée, `.vxm` est ajouté automatiquement (`import "mathlib"` → `mathlib.vxm`).
- Seules les fonctions déclarées `public fn` dans le module sont importées ; les fonctions privées et les variables locales au module restent invisibles depuis l'appelant.

Exemple (`mathlib.vxm`) :

```virex
public fn add(a, b) {
    return a + b;
}
```

Utilisé depuis `main.vx` :

```virex
import "mathlib";

let total = add(4, 7);
print(total);
```

## Fonctions intégrées

Environ 90 fonctions natives sont enregistrées dans `VirexCore.h`. Résumé par catégorie :

**Maths de base** : `sin`, `cos`, `tan`, `sqrt`, `abs`, `pow`, `log`, `exp`, `floor`, `ceil`, `round`, `clamp`, `rand`, `min`, `max`.

**Statistiques / matrices / vecteurs** : `sum`, `average`, `median`, `variance`, `stddev`, `matrix`, `mget`, `mset`, `transpose`, `matrixAdd`, `matrixMul`, `vector`, `dot`, `cross`, `magnitude`, `normalize`, `distance`.

**Chaînes** : `upper`, `lower`, `trim`, `split`, `join`, `substr`, `str`, `startsWith`, `endsWith`, `indexOf`, `replace`, `repeat`, `reverse`, `charAt`, `isNumber`, `regexMatch`, `regexReplace`.

**Listes** : `list`, `push`, `pop`, `append`, `get`, `set`, `contains`, `len`, `range(end)` / `range(start, end)` / `range(start, end, step)`.

**Type et conversion** : `type(valeur)` (`"number"`, `"string"`, `"bool"`, `"null"`, `"list"`, `"dict"`, `"complex"`), `number(valeur)`.

**Entrée/sortie console** : `input(prompt)`, `inputNum(prompt)`.

**Fichiers et système** : `readFile`, `writeFile`, `appendFile`, `deleteFile`, `exists`, `copyFile`, `moveFile`, `createDirectory`, `isDirectory`, `fileSize`, `currentDirectory`, `platform`, `time`, `timeMs`, `sleep`, `shell` (exécute une commande système, renvoie son code de sortie).

**Dictionnaires** : `dict`, `dictGet`, `dictSet`, `dictKeys`.

**JSON** : `jsonParse`, `jsonStringify`, `objectGet`, `objectSet`, `objectKeys`.

**Nombres complexes** : `complex(reel, imaginaire)`, `real`, `imag`, `complexAbs`. Les opérateurs `+ - * /` fonctionnent nativement avec les complexes.

```virex
let data = jsonParse("{\"name\":\"Virex\",\"version\":1}");
print(objectGet(data, "name"));
data = objectSet(data, "ready", true);
writeFile("config.json", jsonStringify(data));

let z = complex(2, 3);
print(z * complex(1, -1));
print(complexAbs(z));
```

## Fenêtres et dessin (Windows / GDI)

```virex
let screen = window("Virex", 640, 400);
windowClear(screen, 25, 30, 40);
drawRect(screen, 40, 40, 220, 120, 30, 150, 240);
drawText(screen, 60, 190, "Bonjour depuis Virex", 255, 255, 255);
windowWait(5000);
windowClose(screen);
```

Fonctions : `window`, `windowOpen`, `windowWidth`, `windowHeight`, `windowClose`, `windowClear`, `drawRect`, `drawLine`, `drawText`, `windowRefresh`, `windowPump`, `windowWait`. Les commandes de dessin sont stockées et rejouées automatiquement lors des événements `WM_PAINT`.

> ⚠️ API Win32/GDI — **Windows uniquement**. Couleurs en RGB, composantes `0` à `255`.

## Rendu GPU Direct3D 11

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

Backend basé sur un device matériel Direct3D 11, une swap chain, un vertex shader et un pixel shader HLSL. `gpuLine` dessine une ligne (2 points + RGB), `gpuRect` un rectangle plein. `CompleteTest/main.vx` illustre un cube filaire tournant, rendu avec `gpuLine`.

Textures BMP 24/32 bits non compressées :

```virex
let image = gpuLoadTexture(screen, "image.bmp");
gpuDrawTexture(screen, image, -0.8, 0.8, 0.8, -0.8);
```

Entrées : `keyDown(nomTouche)`, `mouseX`, `mouseY`, `mouseDown`.

> ⚠️ Coordonnées GPU normalisées entre `-1` et `1`, couleurs entre `0` et `1` — échelle différente de l'API GDI (0–255). Ne pas mélanger les deux.

## Assembleur inline (ASM_snippet)

Cible : `x86_64`, syntaxe Intel, ABI Windows x64, assembleur intégré Clang, optimisation `O2`, valeur de retour dans `RAX`.

```virex
print(ASM_config());
let result = ASM_snippet("mov rax, 42");
print(result);
```

`ASM_snippet` compile temporairement le fragment en DLL via Clang, la charge, l'exécute (fonction sans argument retournant un entier 64 bits dans `RAX`), puis supprime les fichiers temporaires. La variable d'environnement `VIREX_CLANG` permet d'indiquer un autre exécutable Clang.

> ⚠️ **Danger** : exécute du code natif arbitraire dans le processus de l'interpréteur. À réserver au code de confiance uniquement.

## Extension VS Code

Dossier `vscode-extension/` : coloration syntaxique (`.vx` = script, `.vxm` = module), icônes de fichiers dédiées, appariement de crochets/accolades, commentaires `#` avec `Ctrl+/`.

```bash
cd vscode-extension
install.bat            # Windows
./install.sh           # macOS/Linux (chmod +x install.sh d'abord)
```

Installation manuelle : copier le contenu de `vscode-extension/` dans `%USERPROFILE%\.vscode\extensions\virex-syntax-1.0.0` (ou `~/.vscode/extensions/...`), puis recharger VS Code (`Ctrl+Shift+P` → *Reload Window*).

---

## Erreurs possibles et corrections

Toutes les erreurs sont interceptées dans `main()` et affichées sous la forme `Virex error: <message>` (le programme s'arrête avec le code 1). Dans le REPL, une erreur n'interrompt pas la session : seule la ligne en cours échoue.

### 1. Erreurs de syntaxe (analyse lexicale / parsing)

Formats `Line N: ...`, levées par `Lexer.h` / `Parser.h`.

| Message | Cause | Correction |
|---|---|---|
| `Line N: unexpected character '?'` | Caractère non reconnu par le lexer (ex. `&` seul au lieu de `&&`, `|` seul au lieu de `||`, symbole exotique) | Vérifie la syntaxe autour de la ligne N ; utilise `&&` / `||` complets, retire les caractères parasites |
| `Line N: invalid number literal '...'` | Nombre mal formé (ex. `3.14.5`, `12abc`) | Corrige le littéral numérique |
| `Line N: unterminated string literal` | Chaîne ouverte avec `"` mais jamais refermée (ou fin de fichier atteinte) | Ajoute le guillemet fermant manquant |
| `Line N: expected identifier.` | Un nom de variable/fonction était attendu (ex. après `let`, `fn`) | Ajoute le nom manquant |
| `Line N: expected 'catch' after try.` | Un bloc `try { }` n'est pas suivi de `catch (err) { }` | Ajoute le bloc `catch` obligatoire |
| `Line N: expected 'fn' after visibility modifier.` | `public` utilisé sans `fn` derrière | Écris `public fn nom(...) { ... }` |
| `Line N: unterminated function body.` / `unterminated block.` | Accolade `{` jamais refermée avant la fin du fichier | Vérifie l'équilibre des `{ }` |
| `Line N: expected module name after import.` | `import` sans nom de module ou sans guillemets | Écris `import "nom_du_module";` |
| `Line N: invalid expression near '...'.` | Expression incomplète ou mal construite (opérateur en trop, parenthèse manquante) | Relis l'expression autour du token signalé |
| Erreur générique `Line N: <message attendu>` | Token attendu absent, ex. `;` manquant en fin d'instruction, `)` ou `}` manquant | Ajoute la ponctuation attendue indiquée dans le message |

### 2. Erreurs à l'exécution — variables, fonctions, valeurs

| Message | Cause | Correction |
|---|---|---|
| `Undefined variable: 'x'.` | Variable utilisée avant d'être déclarée avec `let`, ou hors de sa portée (ex. définie dans une fonction/module) | Déclare la variable avant usage, vérifie la portée (une variable d'un `.vxm` n'est pas visible depuis l'appelant, seules les `public fn` le sont) |
| `Unknown function: 'nom'.` | Appel d'une fonction qui n'existe ni en natif ni définie par l'utilisateur (faute de frappe, module non importé) | Vérifie l'orthographe, ajoute `import "module";` si la fonction vient d'un `.vxm` |
| `Function 'nom' expects N argument(s) but got M.` | Mauvais nombre d'arguments pour une fonction définie par l'utilisateur (`fn`/`public fn`) | Ajuste le nombre d'arguments à l'appel |
| `<fonction> expects N argument(s).` (ex. `sin expects 1 argument.`) | Mauvais nombre d'arguments pour une fonction native | Consulte la signature dans la section [Fonctions intégrées](#fonctions-intégrées) |
| `<fonction> expects a string / a list / a dictionary / numeric ...` | Mauvais type passé à une fonction native (ex. `upper(42)`) | Convertis la valeur avec `str()`/`number()` ou passe le bon type |
| `Division by zero.` / `Modulo by zero.` | `x / 0` ou `x % 0` | Vérifie le diviseur avant l'opération |
| `sqrt of a negative number.` | `sqrt(-4)` | Vérifie que la valeur est positive, ou utilise `complex()` pour une racine de nombre négatif |
| `log of a non-positive number.` | `log(0)` ou `log(-5)` | Assure-toi que l'argument est strictement positif |
| `list index out of range.` / `matrix row/column out of range.` / `substr index out of range.` / `charAt index out of range.` | Index en dehors des bornes d'une liste, chaîne ou matrice | Vérifie `len()` avant d'indexer, corrige l'index |
| `pop on empty list.` | `pop()` appelé sur une liste vide | Vérifie que la liste n'est pas vide avant de dépiler |
| `Internal error: function registry not initialized.` | Bug interne (ne devrait pas se produire en usage normal) | Signale le bug si rencontré, sinon relance le script |

### 3. Erreurs de fichiers, modules et JSON

| Message | Cause | Correction |
|---|---|---|
| `Could not open file: '...'` | Fichier `.vx` passé en argument introuvable | Vérifie le chemin/l'orthographe, utilise un chemin absolu si besoin |
| `Unable to import module: '...'.` | Le module `.vxm` importé n'existe pas au chemin résolu | Vérifie que le fichier existe à côté du script (ou au chemin donné), que l'extension `.vxm` est correcte |
| `Could not open module: '...'.` | Le fichier module existe mais n'a pas pu être ouvert (droits d'accès, verrouillé) | Vérifie les permissions du fichier |
| `Could not read file: '...'.` / `Could not write file: '...'.` / `Could not append to file: '...'.` | `readFile`/`writeFile`/`appendFile` échoue (chemin invalide, droits insuffisants, disque plein) | Vérifie le chemin et les permissions |
| `Could not copy file: ...` / `Could not move file: ...` / `Could not create directory: ...` / `Could not read file size: ...` | Erreur système renvoyée par `std::filesystem` (chemin invalide, disque plein, fichier verrouillé) | Le message inclut le détail système ; corrige le chemin ou libère les ressources |
| `Invalid JSON.` / `Invalid JSON string.` / `Invalid JSON value.` / `Unsupported JSON escape.` / `Unexpected JSON content.` | Chaîne passée à `jsonParse` mal formée | Valide le JSON (guillemets échappés avec `\"`, structure correcte) |
| `JSON cannot serialize complex numbers.` | `jsonStringify` appelé sur une valeur contenant un nombre complexe | Convertis le complexe (`real()`/`imag()`) avant sérialisation |
| `Invalid regular expression.` | Motif regex invalide dans `regexMatch`/`regexReplace` | Corrige la syntaxe de l'expression régulière (grammaire ECMAScript standard C++) |
| `Could not convert input to number.` | `inputNum()` reçoit une entrée non numérique | Redemande une entrée valide, ou valide avec `isNumber()` avant conversion |
| `Could not convert string to number: '...'.` | `number("abc")` sur une chaîne non numérique | Vérifie la chaîne avec `isNumber()` avant d'appeler `number()` |

### 4. Erreurs graphiques (GDI) et GPU (Direct3D 11)

| Message | Cause | Correction |
|---|---|---|
| `Could not create window.` / `Could not register window class.` | Échec de création de fenêtre Win32 | Vérifie que le script tourne bien sous Windows et sans `--no-graphics` |
| `Window handle is not open.` | Fonction de dessin/fenêtre appelée après `windowClose()`, ou id de fenêtre invalide | Vérifie l'ordre des appels ; n'utilise plus l'id après `windowClose` |
| `Graphics windows are only supported on Windows.` | Tentative d'ouvrir une fenêtre sur un OS autre que Windows | Ces fonctions nécessitent Windows ; sur d'autres OS, retire les appels graphiques ou lance en `--no-graphics` |
| `Direct3D 11 is only supported on Windows.` / `GPU textures are only supported on Windows.` | Fonctions `gpu*` appelées hors Windows | Idem : GPU réservé à Windows |
| `Could not initialize Direct3D 11 hardware device.` / `Could not access Direct3D 11 back buffer.` / `Could not create Direct3D 11 render target.` | Échec d'initialisation du device D3D11 (pilote GPU absent/obsolète) | Mets à jour les pilotes graphiques, vérifie le support Direct3D 11 du matériel |
| `Direct3D 11 context is not initialized.` | Fonction `gpu*` appelée avant `gpuInit(screen)` | Appelle `gpuInit(screen)` avant toute autre fonction `gpu*` |
| `Could not compile Direct3D 11 vertex/pixel shader.` | Erreur de compilation HLSL interne | Généralement un problème d'environnement (drivers/SDK) plutôt que du code utilisateur |
| `Could not open texture: ...` / `Texture must be an uncompressed 24-bit or 32-bit BMP.` | Fichier BMP introuvable, ou compressé/mauvais format | Utilise un BMP non compressé en 24 ou 32 bits |
| `Could not create GPU texture.` / `Could not create GPU texture view.` | Échec d'upload de la texture vers le GPU | Vérifie la taille/le format de l'image, la mémoire GPU disponible |
| `Unknown GPU texture.` | Id de texture invalide passé à `gpuDrawTexture` | Réutilise l'id renvoyé par `gpuLoadTexture` |

### 5. Erreurs d'assembleur inline

| Message | Cause | Correction |
|---|---|---|
| `ASM_snippet currently requires Windows x86_64.` | `ASM_snippet` appelé sur une autre plateforme/architecture | Fonctionnalité réservée à Windows x86_64 |
| `ASM_snippet cannot be empty.` | Chaîne vide passée à `ASM_snippet` | Fournis un fragment assembleur valide |
| `Could not create temporary assembly file.` | Échec d'écriture du fichier temporaire (droits, disque) | Vérifie les droits d'écriture dans le dossier temporaire |
| `Could not assemble ASM_snippet. Set VIREX_CLANG to a clang executable.` | Clang introuvable ou échec de compilation du fragment | Installe Clang, ou définis la variable d'environnement `VIREX_CLANG` vers le bon exécutable |
| `Could not load assembled ASM_snippet.` / `Assembled snippet has no entry point.` | La DLL compilée est invalide ou son point d'entrée est absent | Vérifie que le fragment assembleur est syntaxiquement correct et se termine par un `ret` implicite/explicite cohérent |

### Bonnes pratiques pour éviter ces erreurs

- Toujours terminer chaque instruction par `;` et équilibrer `{ }` / `( )`.
- Utiliser `try { ... } catch (error) { print(error); }` autour des opérations risquées (fichiers, JSON, regex, entrées utilisateur).
- Vérifier `exists(chemin)` avant `readFile`, et `len(liste)` avant d'indexer.
- Séparer clairement l'échelle de couleurs GDI (0–255) de l'échelle GPU (0–1), et les coordonnées GPU (-1 à 1) des coordonnées pixels GDI.
- N'utiliser `ASM_snippet` qu'avec du code de confiance, jamais avec une entrée utilisateur non validée.
- Tester avec `virex --no-graphics script.vx` pour isoler un bug logique d'un problème lié aux fenêtres/GPU.

---

*Documentation générée à partir du code source réel du projet (`main.cpp`, `src/*.h`, `README.md`, `FUNCTIONS.md`, `INSTALL.md`, `PHASE2_COMPLETE.md`) fourni par l'utilisateur.*
