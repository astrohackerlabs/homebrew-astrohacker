# Homebrew Astrohacker

Homebrew tap for Astrohacker releases.

## Astrohacker TermSurf

```nu
brew tap astrohackerlabs/astrohacker
brew trust astrohackerlabs/astrohacker
brew install --cask termsurf
```

NuTorch is installed automatically as a dependency from this same trusted tap.

## NuTorch independently

After the tap/trust setup above:

```nu
brew install nutorch
```

Product source and release downloads remain in their individual repositories.
The former `astrohacker` cask is renamed to `termsurf`.
