# Virex — Documentation

Virex est un petit langage de programmation interprété, écrit en C++, qui exécute des fichiers `.vx` (scripts) et `.vxm` (modules).

> Analogie Roblox : un `.vxm` avec des `public fn` joue le même rôle qu'un `ModuleScript` exposant des fonctions via `require()`. Un `.vx` est l'équivalent d'un `Script`/point d'entrée qui utilise ce module.

## Sommaire

- [Installation et exécution](#installation-et-exécution)
- [Syntaxe de base](#syntaxe-de-base)
  - [Variables](#variables)
  - [Fonctions](#fonctions)
  - [Modules et import](#modules-et-import)
  - [Affichage](#affichage)
- [Fonctions mathématiques](#fonctions-mathématiques)
- [Fonctions sur les chaînes](#fonctions-sur-les-chaînes)
- [Système et fichiers](#système-et-fichiers)
- [Contrôle de flux, erreurs, dictionnaires, shell](#contrôle-de-flux-erreurs-dictionnaires-shell)
- [JSON et nombres complexes](#json-et-nombres-complexes)
- [Fenêtres et dessin (Windows / GDI)](#fenêtres-et-dessin-windows--gdi)
- [Rendu GPU Direct3D 11](#rendu-gpu-direct3d-11)
- [Assembleur inline](#assembleur-inline)
- [Mode console](#mode-console)
- [Exemple complet](#exemple-complet)

---

## Installation et exécution

Virex fournit un exécutable (`virex` / `virex.exe`, voir `Executables/` dans le dépôt) qui interprète directement les fichiers `.vx`.

```bash
virex mon_script.vx
```

## Syntaxe de base

### Variables

Déclaration avec `let`, pas de typage explicite, point-virgule obligatoire en fin d'instruction :

```virex
let x = 10;
let y = 2 * (x + 3);
x = x + 5;
```

### Fonctions

Il existe deux types de fonctions : **privées** (par défaut) et **publiques**.

Fonction privée (visible uniquement dans le fichier courant) :

```virex
fn mul(a, b) {
  return a * b;
}
```

Fonction publique (utile uniquement dans un `.vxm`, exposée aux autres fichiers via `import`) :

```virex
public fn mul(a, b) {
  return a * b;
}
```

### Modules et import

Convention de fichiers :

| Extension | Rôle |
|---|---|
| `.vx` | Script exécutable, point d'entrée (ce que lance `virex fichier.vx`) |
| `.vxm` | Module réutilisable, regroupe des `public fn` destinées à être importées |

Un `.vx` (ou un autre `.vxm`) récupère les fonctions publiques d'un module avec :

```virex
import "NOM_DU_MODULE";
```

Exemple minimal, module `math.vxm` :

```virex
public fn add(a, b) {
    return a + b;
}
```

Utilisé depuis un script :

```virex
import "math";

let resultat = add(2, 3);
print(resultat);
```

### Affichage

```virex
print("Hello Virex");
print(x);
```

## Fonctions mathématiques

Fonctions de base : `sin`, `cos`, `tan`, `sqrt`, `abs`, `pow`, `log`, `exp`, `floor`, `ceil`, `round`.

```virex
print(sin(1.57));
print(sqrt(16));
print(pow(2, 8));
```

Statistiques, matrices et vecteurs : `sum`, `average`, `median`, `variance`, `stddev`, `matrix`, `mget`, `mset`, `transpose`, `matrixAdd`, `matrixMul`, `vector`, `dot`, `cross`, `magnitude`, `normalize`, `distance`.

## Fonctions sur les chaînes

`startsWith`, `endsWith`, `indexOf`, `replace`, `repeat`, `reverse`, `charAt`, `isNumber`, `regexMatch`, `regexReplace`.

## Système et fichiers

`copyFile`, `moveFile`, `createDirectory`, `isDirectory`, `fileSize`, `time`, `sleep`, `currentDirectory`, `platform`.

## Contrôle de flux, erreurs, dictionnaires, shell

Virex prend en charge `break`, `continue`, `null`, la gestion d'erreurs `try/catch`, des dictionnaires natifs, et l'exécution de commandes système.

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

Fonctions dictionnaire : `dict`, `dictGet`, `dictSet`, `dictKeys`.

`shell` retourne le code de sortie de la commande système exécutée.

## JSON et nombres complexes

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

Fonctions JSON : `jsonParse`, `jsonStringify`, `objectGet`, `objectSet`, `objectKeys`.

Fonctions nombres complexes : `complex`, `real`, `imag`, `complexAbs`.

Les opérateurs `+`, `-`, `*`, `/` fonctionnent aussi directement avec les nombres complexes.

## Fenêtres et dessin (Windows / GDI)

Virex peut créer des fenêtres natives Windows et dessiner avec GDI :

```virex
let screen = window("Virex", 640, 400);
windowClear(screen, 25, 30, 40);
drawRect(screen, 40, 40, 220, 120, 30, 150, 240);
drawText(screen, 60, 190, "Hello from Virex", 255, 255, 255);
windowWait(5000);
windowClose(screen);
```

Fonctions disponibles : `window`, `windowOpen`, `windowWidth`, `windowHeight`, `windowClose`, `windowClear`, `drawRect`, `drawLine`, `drawText`, `windowRefresh`, `windowPump`, `windowWait`.

Les commandes de dessin sont automatiquement stockées et rejouées lors des événements `WM_PAINT`.

> ⚠️ Cette API graphique cible **Windows** et repose sur Win32/GDI. Les couleurs sont des composantes RGB comprises entre `0` et `255`.

## Rendu GPU Direct3D 11

Virex intègre aussi un backend Direct3D 11 pour du rendu accéléré matériellement sous Windows :

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

Le backend utilise Direct3D 11 : un device matériel, une swap chain, un vertex shader et un pixel shader HLSL.

> ⚠️ Les coordonnées GPU sont normalisées entre `-1` et `1`, et les couleurs entre `0` et `1` — à ne pas confondre avec l'échelle RGB 0–255 de l'API GDI.

`gpuLine` dessine une ligne GPU à partir de deux points et d'une couleur RGB. `gpuRect` dessine un rectangle plein.

Chargement et affichage de textures BMP (24-bit et 32-bit) :

```virex
let screen = window("Texture", 640, 480);
gpuInit(screen);
let image = gpuLoadTexture(screen, "image.bmp");
gpuClear(screen, 0.05, 0.05, 0.08);
gpuDrawTexture(screen, image, -0.8, 0.8, 0.8, -0.8);
gpuPresent(screen);
```

Entrées clavier/souris : `keyDown`, `mouseX`, `mouseY`, `mouseDown`.

## Assembleur inline

La configuration actuelle vise une compatibilité maximale sous Windows :

- `x86_64`
- Syntaxe Intel
- Windows x64 ABI
- Assembleur intégré Clang
- Optimisation `O2`
- Valeur de retour dans `RAX`

```virex
print(ASM_config());
let result = ASM_snippet("mov rax, 42");
print(result);
```

`ASM_snippet` accepte un fragment assembleur sans argument et l'exécute comme une fonction retournant un entier 64 bits dans `RAX`. Virex compile temporairement le fragment en DLL via Clang, le charge, l'exécute, puis supprime les fichiers temporaires.

> ⚠️ **Attention** : ceci exécute du code natif arbitraire dans le processus de l'interpréteur. À n'utiliser qu'avec du code de confiance.

La variable d'environnement `VIREX_CLANG` permet de spécifier un exécutable Clang différent de celui par défaut.

## Mode console

Virex propose un mode console façon Python :

| Commande | Effet |
|---|---|
| `virex file.vx` | Exécute un script depuis n'importe quel répertoire |
| `virex -i` | Ouvre le REPL interactif |
| `virex --help` | Affiche l'aide |
| `virex --version` | Affiche la version actuelle |
| `virex --build-info` | Affiche les fonctionnalités compilées |
| `virex --no-graphics file.vx` | Exécute un script sans créer de fenêtre |

## Exemple complet

`math.vxm` (module réutilisable) :

```virex
public fn add(a, b) {
    return a + b;
}
```

`main.vx` (script d'entrée) :

```virex
import "math";

let total = add(4, 7);
print(total);
```
