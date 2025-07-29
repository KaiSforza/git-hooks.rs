# Rust pre-commit for git-hooks.nix

Use this flake overlay to skip using python for all of your pre-commit needs!

Using my system it saves ~120mb of python, though it still needs `git` to function.

Below are the sizes of the first couple of layers of the devshells using
different pre-commit programs. The first size is the total size of the item and
all of its dependencies, The size in parentheses is the size added by just that
package. If the package was removed, that is how much space would be saved.

```
* prefligit repo with current settings:
    * preflight-shell-dir       - 161.55M
        * git-minimal               - 138.58M (71.84M)
        * prefligit                 - 150.95M (12.36M)
        * pre-commit-config.json    -  68.91M (10.59M)
        * bash-interactive          -  32.27M  (5.96M)
        * coreutils                 -  43.46M  (2.44M)
* pre-commit repo with current settings:
    * pre-commit-shell-dir      - 284.74M
        * pre-commit                - 275.11M (131.55M)
            * python3                   - 171.94M (114.98M)
            * ...python pkgs...         - ...
        * git-minimal               - 138.58M (71.56M)
        * pre-commit-config.json    -  68.91M  (9.62M)
        * coreutils                 -  43.46M  (2.44M)
        * bash-interactive          -  32.27M  (1.86M)
```
