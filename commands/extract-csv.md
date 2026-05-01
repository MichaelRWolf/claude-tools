Extract structured data from one or more confirmation or receipt screenshots and deliver it as CSV ready to paste into a spreadsheet.

## Steps

1. **Examine all provided images** — note how many distinct records each image contains; some images hold multiple confirmations
2. **Identify columns** — use headers stated by the user, or infer them from the repeating fields in the images
3. **Extract every record** — one row per confirmation; do not skip records from multi-record images
4. **Sort rows by date** if a date field is present
5. **Display the CSV as a fenced code block** in the response
6. **Copy to clipboard** — write the CSV to `/tmp/extracted.csv` and run `pbcopy < /tmp/extracted.csv` using the Bash tool so the user can paste directly into a spreadsheet

## Output rules

- First row: column headers
- One row per record
- Comma-separated; quote any field that contains a comma
- No trailing blank lines
- Confirm how many records were found at the end of your response
