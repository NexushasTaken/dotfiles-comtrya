# dotfiles

My dotfiles, managed by mdot.

```sh
cd ~/dotfiles
mdot plan
mdot apply
```

## Layout

- `config.lua`: shared variables (`mdot.vars`).
- `hosts/nexos.lua`: what this machine gets.
- `specs/`: one directory per program. Without a `spec.lua` it's linked to `~/.config/<name>`.
- `legacy/`: the old configs
