# wavadeepdive

Data retrieval and analysis functions used by the park-specific deep-dive
water supply vulnerability assessments of National Park Service (NPS) units,
part of Water Vulnerability Analytics (WaVA). Function documentation is still
to be written.

## Install

`wavadeepdive` depends on [`wavacore`](https://github.com/Water-Vulnerability-Analytics/wavacore)
and on `climateR`, which is installed from GitHub.

```r
# install.packages("remotes")
remotes::install_github("Water-Vulnerability-Analytics/wavadeepdive")
```

Some functions read from the shared WaVA data folder, which is not part of this
repository. See `wavacore::wava_data_path()` for how that folder is found.

## AI Use Disclosure

AI-assisted coding tools (Claude Code, using Anthropic's Claude models) were used
during development of this repository, beginning in 2026, to help set up the
package, prepare it for release, and write tests. All AI-assisted code and text
was reviewed, tested, and validated by the authors, who made all design and
scientific decisions and remain responsible for the content.

## License

MIT. See [LICENSE.md](LICENSE.md).
