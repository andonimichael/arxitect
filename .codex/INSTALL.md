# Installing Arxitect for Codex

## Installation

To install the Arxitect skills in Codex:

1. Clone the repository

```bash
git clone https://github.com/andonimichael/arxitect.git ~/.codex/arxitect
```

2. Symlink the skills:

```bash
ln -s ~/.codex/arxitect/skills ~/.agents/skills/arxitect
```

3. Restart Codex to pick up the new skills.

## Updating

```bash
cd ~/.codex/arxitect && git pull
```

## Uninstall

```bash
rm ~/.agents/skills/arxitect && rm -rf ~/.codex/arxitect
```
