# Posterior

<p align="center">
    <img src="assets/images/logo.png"/>
</p>

**Posterior** - movie recommender system based on **poster** analysis.

# Running
To run the app use the following command:

```sh
julia --project=. posterior/main.jl
```

It is also possible to specify current project through env variable:

```sh
export JULIA_PROJECT=.

julia posterior/main.jl
```

# Installing julia

For installing julia see the appropriate [installation script](install-julia.sh)

# Installing dependencies

To install dependencies activate and instantiate the environment:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```
