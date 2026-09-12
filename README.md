# Virex

Virex est un mini-langage de programmation simple, conçu pour exécuter des fichiers `.vx` avec un interpréteur écrit en C++.

## Syntaxe de base

### Variables
```virex
let x = 10;
let y = 2 * (x + 3);
x = x + 5;
```

### Affichage
```virex
print("Bonjour Virex");
print(x);
```

### Fonctions mathématiques
```virex
print(sin(1.57));
print(sqrt(16));
print(pow(2, 8));
```

Fonctions supportées : `sin`, `cos`, `tan`, `sqrt`, `abs`, `pow`, `log`, `exp`, `floor`, `ceil`, `round`.

Fonctions mathématiques supplémentaires : `sum`, `average`, `median`, `variance`, `stddev`, `matrix`, `mget`, `mset`, `transpose`, `matrixAdd`, `matrixMul`, `vector`, `dot`, `cross`, `magnitude`, `normalize` et `distance`.

Fonctions strings supplémentaires : `startsWith`, `endsWith`, `indexOf`, `replace`, `repeat`, `reverse`, `charAt`, `isNumber`, `regexMatch` et `regexReplace`.

Fonctions système et fichiers : `copyFile`, `moveFile`, `createDirectory`, `isDirectory`, `fileSize`, `time`, `sleep`, `currentDirectory` et `platform`.

Le langage supporte aussi `break`, `continue`, `null`, `try/catch`, les dictionnaires natifs et l’exécution de commandes système :

```virex
let data = dict();
data = dictSet(data, "name", "Virex");
print(dictGet(data, "name"));

try {
	readFile("missing.txt");
} catch (error) {
	print(error);
}

shell("echo Bonjour");
```

Fonctions dictionnaire : `dict`, `dictGet`, `dictSet` et `dictKeys`. `shell` renvoie le code de sortie de la commande système.

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

Fonctions JSON : `jsonParse`, `jsonStringify`, `objectGet`, `objectSet` et `objectKeys`.
Fonctions complexes : `complex`, `real`, `imag` et `complexAbs`. Les opérateurs `+`, `-`, `*` et `/` fonctionnent avec les complexes.

## Fenêtres et dessin Windows

Virex peut créer une fenêtre native Windows et dessiner avec GDI :

```virex
let screen = window("Virex", 640, 400);
windowClear(screen, 25, 30, 40);
drawRect(screen, 40, 40, 220, 120, 30, 150, 240);
drawText(screen, 60, 190, "Bonjour depuis Virex", 255, 255, 255);
windowWait(5000);
windowClose(screen);
```

Fonctions disponibles : `window`, `windowOpen`, `windowWidth`, `windowHeight`, `windowClose`, `windowClear`, `drawRect`, `drawLine`, `drawText`, `windowRefresh`, `windowPump` et `windowWait`. Les commandes de dessin sont conservées et rejouées automatiquement lors des événements `WM_PAINT`.

Cette première API cible Windows et utilise Win32/GDI. Les valeurs de couleur sont des composantes RGB entre 0 et 255.

## Rendu GPU Direct3D 11

Virex possède aussi un backend Direct3D 11 pour le rendu matériel Windows :

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

Le backend utilise Direct3D 11, un device matériel, un swap chain, un vertex shader et un pixel shader HLSL. Les coordonnées GPU sont normalisées entre `-1` et `1`, et les couleurs entre `0` et `1`. `gpuLine` permet de dessiner une arête GPU avec deux points et une couleur RGB, et `gpuRect` dessine un rectangle rempli. `CompleteTest/main.vx` utilise maintenant `gpuLine` pour rendre le cube directement par Direct3D 11.

Les textures BMP 24/32 bits peuvent être chargées et dessinées sur le GPU :

```virex
let screen = window("Texture", 640, 480);
gpuInit(screen);
let image = gpuLoadTexture(screen, "image.bmp");
gpuClear(screen, 0.05, 0.05, 0.08);
gpuDrawTexture(screen, image, -0.8, 0.8, 0.8, -0.8);
gpuPresent(screen);
```

Le clavier et la souris sont accessibles avec `keyDown`, `mouseX`, `mouseY` et `mouseDown`.

## Assembleur

La configuration actuelle cible le maximum de compatibilité disponible sur Windows : `x86_64`, syntaxe Intel, ABI Windows x64, assembleur intégré Clang, optimisation `O2` et résultat dans `RAX`.

```virex
print(ASM_config());
let result = ASM_snippet("mov rax, 42");
print(result);
```

`ASM_snippet` accepte un fragment sans argument et exécute une fonction qui retourne un entier 64 bits dans `RAX`. Virex compile temporairement le fragment en DLL avec Clang, le charge, l’exécute, puis supprime les fichiers temporaires. La fonction exécute du code natif arbitraire dans le processus : elle doit donc être utilisée uniquement avec du code de confiance. La variable d’environnement `VIREX_CLANG` permet de choisir un autre exécutable Clang.

## VS Code Setup

Pour une meilleure expérience de développement, installez l'extension VS Code :

```bash
cd vscode-extension
install.bat     # Windows
# ou
chmod +x install.sh && ./install.sh  # macOS/Linux
```

L'extension ajoute :
- **Coloration syntaxique** pour `.vx` et `.vxm`
- **Icônes de fichier** personnalisées
- **Autocomplétion** pour les mots-clés et fonctions

Voir [INSTALL.md](./INSTALL.md) pour plus de détails.

## Exécution

### Compilation
```bash
clang++ -std=c++17 -O2 main.cpp -o virex
```

### Mode console Python-like
- `virex file.vx` : exécute un script depuis n’importe quel dossier
- `virex -i` : ouvre le REPL interactif
- `virex --help` : affiche l’aide
- `virex --version` : affiche la version
- `virex --build-info` : affiche les fonctionnalités compilées
- `virex --no-graphics file.vx` : exécute un script sans créer de fenêtre

### PATH Windows
Après le build, le script `build.bat` installe un lanceur `virex.cmd` dans le dossier système `AppData\Local\Microsoft\WindowsApps`, qui est déjà dans le `PATH` Windows. Ensuite, tu peux utiliser Virex depuis n’importe quel dossier :

```bash
virex --help
virex sample.vx
```

Exemples :
```bash
virex sample.vx
virex -i
virex --help
```

## Packaging Windows
Le script `build.bat` produit une version packagée dans le dossier `dist/` avec :
- `virex.exe`
- `sample.vx`
- `README.md`

Exemple :
```bat
build.bat
```

## Exemple
Voir le fichier `sample.vx`.

## Test complet

Le dossier `CompleteTest/` contient une démonstration entièrement écrite en Virex : un cube filaire tourne autour des axes X, Y et Z dans une fenêtre avec fond gris foncé. Lance-la avec :

```bash
virex CompleteTest/main.vx
```
