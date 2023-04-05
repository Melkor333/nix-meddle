# nix-meddle

Meddle around in your `/nix/store/` without actually destroying anything!

Warning: Really early stage. Except breakages!

# What is this??

Quasi savely meddle around in your nix store.

How often have you thought "men, I just want to reeeaaaaally quickly change
that one line in that file in the Nix Store".
But for obvious reasons you don't do it.

Nix-Meddle is here to solve that! Instead of editing files in the nix store,
this tool copies the files into a save-to-edit path and makes a bind-mount.
And even better: instead of doing a global mount, it does an `unshare` (some
kind of shell magic), so that the mount point is only visible for your current
shell session!

Therefore the global system won't be damaged!

# Install

## Nix Flakes

Just run:
```bash
nix run github:Melkor333/nix-meddle
```

## Nix without flakes

TODO. See the manual install.

(PS: I hated people like me only providing a flake. until I learned flakes.. :) )

# Usage

* Run `nix-meddle`
* It will ask you some stuff and print out 2 commands at the end
* Run the `unshare -r -m` command first
* After that run the `mount...` command
* Meddle around in the path printed out

TODO: Smol Demo where I replace ls with sl *insert troll face*.
