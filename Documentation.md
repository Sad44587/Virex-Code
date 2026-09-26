# Virex — Documentation

Virex est un mini-langage de programmation simple, exécuté par un interpréteur (`virex.exe`). Il permet d'écrire des scripts `.vx` (programmes) et des modules réutilisables `.vxm`, avec support des maths avancées, des fichiers, du JSON, des fenêtres graphiques (GDI), du rendu GPU (Direct3D 11) et même de l'assembleur.

> Analogie Roblox / Python : un `.vxm` avec des `public fn` joue le même rôle qu'un `ModuleScript` exposant des fonctions via `require()`. Un `.vx` est l'équivalent d'un `Script` / point d'entrée. Le mode `virex` sans argument (REPL) fonctionne comme taper `python` seul dans un terminal.

## Sommaire

- [Installation](#installation)
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

## Installation

Virex s'installe via l'installateur Windows `VirexSetup.exe` — aucune compilation n'est nécessaire.

1. Télécharge et lance `VirexSetup.exe`.
2. Choisis le dossier d'installation (par défaut `Programmes\Virex`).
3. Coche la case **« Ajouter Virex au PATH »** pendant l'installation : cela permet d'utiliser la commande `virex` depuis n'importe quel dossier, sans taper le chemin complet.
4. À la fin de l'installation, `virex --help` s'exécute automatiquement pour vérifier que tout fonctionne.

L'installateur place dans le dossier choisi :
- `virex.exe` — l'interpréteur
- `README.md` — un aperçu rapide du langage
- `sample.vx` — un script d'exemple

Un raccourci « Virex » est aussi ajouté au menu Démarrer.

> ⚠️ Windows uniquement. Certaines fonctionnalités (fenêtres graphiques, rendu GPU, assembleur inline) ne fonctionnent que sur Windows.

### Vérifier l'installation

Ouvre une invite de commande (`cmd`) n'importe où et tape :

```bash
virex --version
virex --help
```

Si la commande `virex` n'est pas reconnue, réinstalle en cochant bien l'option d'ajout au PATH, ou ouvre une nouvelle fenêtre de terminal (le PATH n'est pris en compte que dans les terminaux ouverts après l'installation).

## Mode console

Comme `python`, l'exécutable a plusieurs modes selon comment tu l'utilises :

| Commande | Effet |
|---|---|
| `virex` (terminal, aucun argument) | Ouvre le **REPL** interactif (`>>>`) : tu écris du code Virex ligne par ligne, comme dans le mode interactif de Python |
| `virex fichier.vx` | Exécute un script depuis n'importe quel dossier |
| `virex -i` ou `virex repl` | Ouvre explicitement le REPL interactif |
| `virex --help` / `-h` | Affiche l'aide |
| `virex --version` / `-v` | Affiche la version installée |
| `virex --build-info` | Affiche les fonctionnalités disponibles dans cette version (graphismes, assembleur…) |
| `virex --no-graphics fichier.vx` | Exécute un script sans ouvrir de fenêtre (utile pour des scripts purement logiques) |

Dans le REPL, tape `exit` ou `quit` pour sortir. Chaque ligne tapée doit être une instruction Virex complète, terminée par `;`.

## Syntaxe de base

### Variables

```virex
let x = 10;
let y = 2 * (x + 3);
x = x + 5;
```

Pas de typage explicite à déclarer. Types disponibles : nombre, chaîne, booléen, `null`, liste, dictionnaire, nombre complexe.

### Fonctions

Deux visibilités : privée (par défaut) et publique.

```virex
fn mul(a, b) {
  return a * b;
}

public fn mul(a, b) {   // utile uniquement dans un .vxm, exposée à l'import
  return a * b;
}
```

### Contrôle de flux

`if` / `else` (avec `else if`), `while`, `for`, `break`, `continue`, `return`, et gestion d'erreurs avec `try / catch` :

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
| `.vx` | Script exécutable, point d'entrée (ce que tu lances avec `virex fichier.vx`) |
| `.vxm` | Module réutilisable, regroupe des fonctions `public fn` |

```virex
import "mathlib";
```

Quelques règles à connaître :
- Le nom du module est cherché **dans le même dossier que ton script** (sauf si tu donnes un chemin complet).
- Si tu ne précises pas d'extension, `.vxm` est ajouté automatiquement (`import "mathlib"` → cherche `mathlib.vxm`).
- Seules les fonctions déclarées `public fn` dans le module sont utilisables depuis l'extérieur ; les fonctions privées et les variables du module restent invisibles.

Exemple, fichier `mathlib.vxm` :

```virex
public fn add(a, b) {
    return a + b;
}
```

Utilisé depuis `main.vx` (dans le même dossier) :

```virex
import "mathlib";

let total = add(4, 7);
print(total);
```

## Fonctions intégrées

Virex fournit près de 90 fonctions prêtes à l'emploi, sans rien à installer.

**Maths de base** : `sin`, `cos`, `tan`, `sqrt`, `abs`, `pow`, `log`, `exp`, `floor`, `ceil`, `round`, `clamp`, `rand`, `min`, `max`.

**Statistiques / matrices / vecteurs** : `sum`, `average`, `median`, `variance`, `stddev`, `matrix`, `mget`, `mset`, `transpose`, `matrixAdd`, `matrixMul`, `vector`, `dot`, `cross`, `magnitude`, `normalize`, `distance`.

**Chaînes** : `upper`, `lower`, `trim`, `split`, `join`, `substr`, `str`, `startsWith`, `endsWith`, `indexOf`, `replace`, `repeat`, `reverse`, `charAt`, `isNumber`, `regexMatch`, `regexReplace`.

**Listes** : `list`, `push`, `pop`, `append`, `get`, `set`, `contains`, `len`, `range(fin)` / `range(debut, fin)` / `range(debut, fin, pas)`.

**Type et conversion** : `type(valeur)` (renvoie `"number"`, `"string"`, `"bool"`, `"null"`, `"list"`, `"dict"` ou `"complex"`), `number(valeur)`.

**Entrée utilisateur (console)** : `input(prompt)`, `inputNum(prompt)`.

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

Fonctions disponibles : `window`, `windowOpen`, `windowWidth`, `windowHeight`, `windowClose`, `windowClear`, `drawRect`, `drawLine`, `drawText`, `windowRefresh`, `windowPump`, `windowWait`. Les commandes de dessin sont automatiquement mémorisées et réaffichées si la fenêtre se redessine.

> ⚠️ Windows uniquement. Les couleurs sont des composantes RGB entre `0` et `255`.

## Rendu GPU Direct3D 11

Pour du rendu accéléré matériellement :

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

`gpuLine` dessine une ligne (2 points + couleur RGB), `gpuRect` dessine un rectangle plein.

Textures BMP 24/32 bits non compressées :

```virex
let image = gpuLoadTexture(screen, "image.bmp");
gpuDrawTexture(screen, image, -0.8, 0.8, 0.8, -0.8);
```

Entrées clavier/souris : `keyDown(nomTouche)`, `mouseX`, `mouseY`, `mouseDown`.

> ⚠️ Coordonnées GPU normalisées entre `-1` et `1`, couleurs entre `0` et `1` — échelle différente de l'API fenêtre/GDI classique (0–255). Ne mélange pas les deux.

## Assembleur inline (ASM_snippet)

Virex permet d'exécuter directement un petit fragment assembleur x86_64 (syntaxe Intel), qui doit renvoyer un entier 64 bits :

```virex
print(ASM_config());
let result = ASM_snippet("mov rax, 42");
print(result);
```

> ⚠️ **Danger** : ceci exécute du code natif arbitraire dans le processus de l'interpréteur. À utiliser uniquement avec du code de confiance, jamais avec du texte venant d'un utilisateur non fiable.

## Extension VS Code

Une extension optionnelle ajoute la coloration syntaxique et des icônes dédiées pour les fichiers `.vx` et `.vxm` dans Visual Studio Code : mots-clés, chaînes, nombres et commentaires colorés, appariement automatique des accolades/parenthèses, commentaires basculables avec `Ctrl+/`.

Installation : depuis VS Code, ouvre la palette de commandes (`Ctrl+Shift+P`) → *Extensions: Install from location...* si l'extension t'a été fournie sous forme de dossier, ou suis les instructions d'installation fournies avec l'extension. Après installation, recharge VS Code (`Ctrl+Shift+P` → *Reload Window*).

---

## Erreurs possibles et corrections

Toute erreur s'affiche sous la forme `Virex error: <message>` et arrête le script (sauf dans le REPL, où seule la ligne en cours échoue). Voici les messages les plus courants, leur cause probable et comment les corriger.

### 1. Erreurs de syntaxe (dans ton code `.vx`/`.vxm`)

| Message | Cause | Correction |
|---|---|---|
| `Line N: unexpected character '?'` | Caractère non reconnu (ex. `&` seul au lieu de `&&`, `|` seul au lieu de `||`, symbole en trop) | Vérifie la ligne N ; utilise `&&` / `||` complets, retire le caractère parasite |
| `Line N: invalid number literal '...'` | Nombre mal écrit (ex. `3.14.5`, `12abc`) | Corrige le nombre |
| `Line N: unterminated string literal` | Chaîne ouverte avec `"` mais jamais refermée | Ajoute le guillemet fermant manquant |
| `Line N: expected identifier.` | Un nom de variable/fonction était attendu (ex. après `let`, `fn`) | Ajoute le nom manquant |
| `Line N: expected 'catch' after try.` | Un bloc `try { }` n'est pas suivi de `catch (err) { }` | Ajoute le `catch` obligatoire |
| `Line N: expected 'fn' after visibility modifier.` | `public` utilisé sans `fn` derrière | Écris `public fn nom(...) { ... }` |
| `Line N: unterminated function body.` / `unterminated block.` | Une accolade `{` n'a jamais été refermée | Vérifie l'équilibre des `{ }` dans ton script |
| `Line N: expected module name after import.` | `import` utilisé sans nom de module entre guillemets | Écris `import "nom_du_module";` |
| `Line N: invalid expression near '...'.` | Expression incomplète ou mal construite | Relis l'expression autour du mot signalé |
| Erreur générique `Line N: ...` | Ponctuation attendue absente (ex. `;`, `)`, `}` manquant) | Ajoute la ponctuation indiquée dans le message |

### 2. Erreurs de variables, fonctions et valeurs

| Message | Cause | Correction |
|---|---|---|
| `Undefined variable: 'x'.` | Variable utilisée avant d'être créée avec `let`, ou hors de sa portée | Déclare la variable avant de l'utiliser ; rappelle-toi qu'une variable d'un `.vxm` n'est pas visible depuis le script qui l'importe, seules les `public fn` le sont |
| `Unknown function: 'nom'.` | Fonction inexistante appelée (faute de frappe, ou module non importé) | Vérifie l'orthographe, ajoute `import "module";` si la fonction vient d'un `.vxm` |
| `Function 'nom' expects N argument(s) but got M.` | Mauvais nombre d'arguments pour une fonction que tu as toi-même définie | Corrige le nombre d'arguments à l'appel |
| `<fonction> expects N argument(s).` (ex. `sin expects 1 argument.`) | Mauvais nombre d'arguments pour une fonction intégrée | Consulte la liste des [fonctions intégrées](#fonctions-intégrées) |
| `<fonction> expects a string / a list / a dictionary / numeric ...` | Mauvais type passé à une fonction (ex. `upper(42)`) | Convertis la valeur avec `str()` ou `number()`, ou passe directement le bon type |
| `Division by zero.` / `Modulo by zero.` | `x / 0` ou `x % 0` | Vérifie le diviseur avant de faire l'opération |
| `sqrt of a negative number.` | `sqrt(-4)` | Vérifie que la valeur est positive, ou utilise `complex()` si tu veux une racine de nombre négatif |
| `log of a non-positive number.` | `log(0)` ou `log(-5)` | Assure-toi que la valeur est strictement positive |
| `list index out of range.` / `matrix row/column out of range.` / `substr index out of range.` / `charAt index out of range.` | Index en dehors des limites d'une liste, chaîne ou matrice | Vérifie `len()` avant d'accéder à un index, corrige l'index |
| `pop on empty list.` | `pop()` appelé sur une liste vide | Vérifie que la liste contient des éléments avant de dépiler |

### 3. Erreurs de fichiers, modules et JSON

| Message | Cause | Correction |
|---|---|---|
| `Could not open file: '...'` | Le fichier `.vx` passé à `virex` est introuvable | Vérifie le chemin/l'orthographe du fichier |
| `Unable to import module: '...'.` | Le module `.vxm` importé n'existe pas là où Virex l'a cherché | Place le fichier `.vxm` dans le même dossier que ton script, vérifie le nom et l'extension |
| `Could not open module: '...'.` | Le module existe mais n'a pas pu être ouvert (droits d'accès, fichier verrouillé) | Vérifie les permissions du fichier |
| `Could not read file: '...'.` / `Could not write file: '...'.` / `Could not append to file: '...'.` | `readFile`/`writeFile`/`appendFile` échoue (chemin invalide, droits insuffisants, disque plein) | Vérifie le chemin et les permissions du fichier/dossier |
| `Could not copy file: ...` / `Could not move file: ...` / `Could not create directory: ...` / `Could not read file size: ...` | Erreur système (chemin invalide, disque plein, fichier verrouillé) | Le message donne le détail ; corrige le chemin ou libère de l'espace |
| `Invalid JSON.` / `Invalid JSON string.` / `Invalid JSON value.` / `Unsupported JSON escape.` / `Unexpected JSON content.` | Le texte donné à `jsonParse` n'est pas du JSON valide | Vérifie la structure du JSON (guillemets échappés avec `\"`, virgules, accolades) |
| `JSON cannot serialize complex numbers.` | `jsonStringify` appelé sur une valeur contenant un nombre complexe | Convertis le complexe avec `real()`/`imag()` avant de le sérialiser |
| `Invalid regular expression.` | Motif regex invalide dans `regexMatch`/`regexReplace` | Corrige la syntaxe de l'expression régulière |
| `Could not convert input to number.` | `inputNum()` a reçu une entrée non numérique | Redemande une valeur, ou vérifie avec `isNumber()` avant de convertir |
| `Could not convert string to number: '...'.` | `number("abc")` sur une chaîne non numérique | Vérifie la chaîne avec `isNumber()` avant d'appeler `number()` |

### 4. Erreurs graphiques (fenêtres) et GPU

| Message | Cause | Correction |
|---|---|---|
| `Could not create window.` / `Could not register window class.` | Échec de création de la fenêtre | Relance le script ; assure-toi de ne pas être en mode `--no-graphics` |
| `Window handle is not open.` | Une fonction de fenêtre/dessin est appelée après `windowClose()`, ou avec un id de fenêtre invalide | N'utilise plus l'id de fenêtre après l'avoir fermée avec `windowClose` |
| `Graphics windows are only supported on Windows.` / `Direct3D 11 is only supported on Windows.` / `GPU textures are only supported on Windows.` | Fonctions de fenêtre/GPU utilisées sur un système autre que Windows | Ces fonctions demandent Windows ; sur un autre OS, retire ces appels ou lance en `--no-graphics` |
| `Could not initialize Direct3D 11 hardware device.` / `Could not access Direct3D 11 back buffer.` / `Could not create Direct3D 11 render target.` | La carte graphique ou ses pilotes ne supportent pas correctement Direct3D 11 | Mets à jour les pilotes graphiques |
| `Direct3D 11 context is not initialized.` | Une fonction `gpu*` a été appelée avant `gpuInit(screen)` | Appelle toujours `gpuInit(screen)` avant les autres fonctions `gpu*` |
| `Could not open texture: ...` / `Texture must be an uncompressed 24-bit or 32-bit BMP.` | Fichier BMP introuvable, compressé, ou mauvais format | Utilise un BMP non compressé en 24 ou 32 bits |
| `Could not create GPU texture.` / `Could not create GPU texture view.` | Échec d'envoi de la texture vers la carte graphique | Vérifie la taille/le format de l'image |
| `Unknown GPU texture.` | Id de texture invalide passé à `gpuDrawTexture` | Réutilise l'id renvoyé par `gpuLoadTexture` |

### 5. Erreurs d'assembleur inline

| Message | Cause | Correction |
|---|---|---|
| `ASM_snippet currently requires Windows x86_64.` | `ASM_snippet` utilisé sur une machine non compatible | Fonctionnalité réservée à Windows en 64 bits |
| `ASM_snippet cannot be empty.` | Chaîne vide passée à `ASM_snippet` | Fournis un fragment assembleur valide |
| `Could not create temporary assembly file.` | Impossible d'écrire un fichier temporaire (droits, disque plein) | Vérifie les droits d'écriture / l'espace disque disponible |
| `Could not assemble ASM_snippet. Set VIREX_CLANG to a clang executable.` | Le compilateur nécessaire au traitement du fragment est introuvable | Installe l'outil requis (Clang), ou configure la variable d'environnement `VIREX_CLANG` vers son emplacement |
| `Could not load assembled ASM_snippet.` / `Assembled snippet has no entry point.` | Le fragment assembleur généré est invalide | Vérifie que ton fragment assembleur est syntaxiquement correct |

### Bonnes pratiques pour éviter ces erreurs

- Termine toujours chaque instruction par `;` et équilibre bien `{ }` / `( )`.
- Entoure les opérations risquées (fichiers, JSON, regex, entrées utilisateur) avec `try { ... } catch (error) { print(error); }`.
- Vérifie `exists(chemin)` avant `readFile`, et `len(liste)` avant d'accéder à un index.
- Ne confonds pas l'échelle de couleurs des fenêtres classiques (0–255) et celle du GPU (0–1), ni les coordonnées GPU (-1 à 1) avec les coordonnées en pixels.
- N'utilise `ASM_snippet` qu'avec du code de confiance, jamais avec du texte saisi par un utilisateur.
- En cas de doute sur un bug, teste avec `virex --no-graphics script.vx` pour savoir si le problème vient de la logique du script ou de la partie graphique/GPU.
