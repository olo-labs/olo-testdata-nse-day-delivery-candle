# Search and AI discoverability guide

The repository contains descriptive human documentation and machine-readable
metadata, but search position cannot be guaranteed. Rankings depend on relevance,
authority, links, crawlability, user behavior, freshness, and systems outside the
repository's control.

## Included discoverability assets

- A descriptive README title and natural-language summary
- Search-oriented FAQ with direct, factual answers
- Stable internal links between related documentation
- Schema.org `Dataset` JSON-LD metadata
- CSV on the Web (CSVW) column metadata
- `llms.txt` for AI retrieval tools that elect to read it
- `CITATION.cff` for GitHub and research citation workflows
- Explicit provenance, temporal coverage, format, variables, and limitations

These formats improve clarity and machine readability. They do not create a
special right to placement in web or AI search results.

## Repository-owner actions on GitHub

These settings cannot be committed as ordinary files and should be set by a
repository administrator.

### Suggested repository description

```text
NSE India daily OHLC, bhavcopy, volume and security delivery data in date-partitioned CSV files from September 2019 onward.
```

### Suggested GitHub topics

```text
nse
nse-india
indian-stock-market
ohlc
bhavcopy
delivery-data
historical-data
market-data
stock-market-data
financial-data
csv-dataset
end-of-day-data
backtesting
quantitative-finance
pandas
duckdb
```

### Additional actions

1. Keep the repository public and the default branch healthy.
2. Add the description and topics in GitHub's **About** settings.
3. Add a relevant social-preview image without misleading exchange branding.
4. Enable Issues and use descriptive titles for confirmed data problems.
5. Publish releases or immutable tags for research snapshots.
6. Encourage links to the canonical repository rather than undocumented copies.

## Optional dedicated dataset landing page

GitHub displays Markdown well, but JSON-LD stored as a repository file is not the
same as JSON-LD embedded in an HTML page. For stronger web dataset discovery,
publish a canonical public landing page that:

- contains a useful visible description matching the README;
- embeds `metadata/dataset.jsonld` in a
  `<script type="application/ld+json">` element;
- links to the GitHub repository and official NSE source;
- has a stable canonical URL and is crawlable without authentication;
- appears in an XML sitemap; and
- is tested with Google's Rich Results Test and URL Inspection tools.

## Content principles

- Write for users first and use terminology where it helps them.
- Answer concrete questions instead of repeating keywords unnaturally.
- Keep titles and summaries unique and accurate.
- State limitations and provenance prominently.
- Avoid claims such as “official,” “complete,” “real-time,” or “adjusted” unless
  demonstrably true.
- Keep examples runnable and internal links valid.
- Prefer one canonical dataset identity and URL.

## Measuring results

If a landing page is published, use Google Search Console to inspect indexing,
structured-data status, queries, impressions, click-through rate, and average
position. Allow time for recrawling and improve pages from genuine user questions.

Primary references:

- [Google Dataset structured data](https://developers.google.com/search/docs/appearance/structured-data/dataset)
- [Google structured data introduction](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data)
- [Schema.org Dataset](https://schema.org/Dataset)
- [Schema.org DataDownload](https://schema.org/DataDownload)
- [GitHub repository topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics)
- [GitHub repository customization](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository)
