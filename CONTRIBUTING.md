# Contributing

Thank you for helping make the archive easier to use and verify.

## Useful contributions

- Correct or expand documentation
- Report malformed, missing, duplicated, or date-mismatched files
- Improve downloader validation and error handling
- Add small, dependency-light validation tools
- Add reproducible usage examples
- Improve accessibility and portability

Please open an issue before making a broad format change. Stable filenames and
columns are valuable to downstream users.

## Development workflow

1. Fork and clone the repository.
2. Create a focused branch.
3. Make the smallest coherent change.
4. Run the relevant checks.
5. Commit with a descriptive message.
6. Open a pull request explaining the motivation, behavior, and validation.

Example:

```bash
git switch -c docs/improve-data-dictionary
git diff --check
git status --short
```

## Documentation changes

- Use clear international English.
- Keep examples copy-pasteable and platform assumptions explicit.
- Distinguish observed dataset behavior from exchange guarantees.
- Link to primary NSE sources for exchange definitions or policies.
- Do not present research examples as financial advice.

## Data corrections

A data correction must include:

- the relative filename;
- a description of the defect;
- a reproducible validation result;
- the authoritative source used for the replacement; and
- confirmation that the proposed file can be redistributed.

Do not normalize or rewrite unrelated historical files in bulk. Such changes
create enormous diffs and make review difficult. Preserve the existing column
order and source-oriented formatting unless the project agrees on a migration.

Never invent or interpolate missing exchange data. If an official report is not
available, record the gap instead.

## Downloader changes

Downloader pull requests should preserve these properties:

- existing CSV files are not overwritten by default;
- paths resolve relative to the script, not the caller's current directory;
- partial responses are written to temporary files;
- unexpected HTML/binary responses are rejected;
- the internal report date is checked before the final filename is created;
- credentials are not embedded; and
- failures produce a non-zero exit code while holidays remain non-fatal.

Test a narrow date range before running a long historical download:

```powershell
.\download_delivery_data.ps1 -StartDate '2026-07-31' -EndDate '2026-07-31'
```

## Pull-request checklist

- [ ] The change is focused and contains no unrelated generated files.
- [ ] `git diff --check` passes.
- [ ] Documentation links and examples were checked.
- [ ] Scripts were syntax-checked or executed over a safe bounded range.
- [ ] Data changes include provenance and validation evidence.
- [ ] No secrets, tokens, cookies, or personal information are included.

## Licensing and data rights

By contributing original code or documentation, you agree that it may be
distributed under the repository's Apache License 2.0.

Underlying market data can be governed by separate NSE/NSE Data terms. Do not
submit data unless you have confirmed that the repository may receive and
redistribute it. A code license does not override third-party data rights.

## Conduct

Be respectful, specific, and evidence-driven. Assume good intent, avoid personal
attacks, and focus review discussion on improving the project and its data.
