# Data quality

This repository is a convenient archive, not a certified market-data feed. Use
validation appropriate to the importance of your application.

## Known issue

At the time this document was added:

- `Day_Delivery/NSE/delivery_08-Aug-2022.csv` begins with a ZIP/Office signature
  (`PK`) and is not a normal text CSV, despite its extension.

Consumers loading the full archive should detect and skip/quarantine this file.
Contributors are welcome to replace it with a correctly sourced report after
verifying the contents and applicable data-use terms.

Do not assume this list is exhaustive. Run validation against the exact commit
used by your application.

## Minimum file checks

For every candidate file:

1. Confirm the name matches `delivery_DD-MMM-YYYY.csv`.
2. Reject HTML, ZIP, Office, JSON error, and empty responses.
3. Confirm the expected 15-column header.
4. Parse every row as CSV.
5. Confirm each `DATE1` equals the filename date.
6. Confirm `(SYMBOL, SERIES, DATE1)` is unique.
7. Check numeric ranges and OHLC relationships.

The downloader performs checks 2, 3, and a sample-based date check for newly
downloaded files. Downstream consumers should still validate the full file.

## PowerShell: identify non-text responses

```powershell
Get-ChildItem '.\Day_Delivery\NSE' -Filter 'delivery_*.csv' | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    if ($bytes.Length -lt 2 -or
        ($bytes[0] -eq 0x50 -and $bytes[1] -eq 0x4B) -or
        ($bytes[0] -eq 0x3C)) {
        [pscustomobject]@{ File = $_.Name; Problem = 'Unexpected file signature' }
    }
}
```

`0x50 0x4B` is the common ZIP signature. `0x3C` can indicate an HTML/XML error
page and should be inspected rather than automatically accepted or deleted.

## Python: validate structure and rows

```python
import csv
from datetime import datetime
from pathlib import Path

EXPECTED = [
    "SYMBOL", "SERIES", "DATE1", "PREV_CLOSE", "OPEN_PRICE", "HIGH_PRICE",
    "LOW_PRICE", "LAST_PRICE", "CLOSE_PRICE", "AVG_PRICE", "TTL_TRD_QNTY",
    "TURNOVER_LACS", "NO_OF_TRADES", "DELIV_QTY", "DELIV_PER",
]

errors = []

for path in sorted(Path("Day_Delivery/NSE").glob("delivery_*.csv")):
    expected_date = datetime.strptime(
        path.stem.removeprefix("delivery_"), "%d-%b-%Y"
    ).date()

    with path.open("rb") as raw:
        if raw.read(2) == b"PK":
            errors.append((str(path), "ZIP/Office content"))
            continue

    try:
        with path.open(newline="", encoding="utf-8-sig") as handle:
            reader = csv.DictReader(handle, skipinitialspace=True)
            headers = [name.strip() for name in (reader.fieldnames or [])]
            if headers != EXPECTED:
                errors.append((str(path), f"unexpected header: {headers}"))
                continue

            keys = set()
            for line_number, raw_row in enumerate(reader, start=2):
                row = {key.strip(): value.strip() for key, value in raw_row.items()}
                actual_date = datetime.strptime(row["DATE1"], "%d-%b-%Y").date()
                if actual_date != expected_date:
                    errors.append((str(path), f"line {line_number}: date mismatch"))

                key = (row["SYMBOL"], row["SERIES"], row["DATE1"])
                if key in keys:
                    errors.append((str(path), f"line {line_number}: duplicate {key}"))
                keys.add(key)
    except (OSError, UnicodeError, csv.Error, ValueError) as exc:
        errors.append((str(path), str(exc)))

for path, message in errors:
    print(f"{path}: {message}")

raise SystemExit(1 if errors else 0)
```

## Numerical checks

Apply checks only where the relevant fields are populated and numeric:

```text
HIGH_PRICE >= LOW_PRICE
LOW_PRICE <= OPEN_PRICE <= HIGH_PRICE
LOW_PRICE <= LAST_PRICE <= HIGH_PRICE
LOW_PRICE <= CLOSE_PRICE <= HIGH_PRICE
TTL_TRD_QNTY >= 0
NO_OF_TRADES >= 0
DELIV_QTY >= 0
0 <= DELIV_PER <= 100
DELIV_QTY <= TTL_TRD_QNTY
```

Some market conventions or exceptional records may require interpretation. A
failed check should be investigated against the official report; it should not
be “fixed” by guessing.

## Calendar checks

An absent calendar date is not automatically missing data. It can be:

- a Saturday or Sunday;
- an NSE holiday;
- a report that was not yet published when automation ran; or
- a genuine collection failure.

Conversely, special trading sessions can occur on weekends. Compare coverage to
an authoritative exchange trading calendar and inspect the official report page.

## Reporting a data problem

Open an issue containing:

- repository commit hash;
- exact relative filename;
- affected symbol/series and row, if applicable;
- expected and actual values;
- validation command or minimal reproduction; and
- official source/reference used to determine the expected value.

Do not attach proprietary datasets or credentials.
