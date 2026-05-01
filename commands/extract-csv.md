Extract Florida State Parks day-use vehicle entry reservations from one or more screenshots.

Each confirmation shows fields like "Date: Fri 05/01/2026", "Standard Parking Space - P 057", "Confirmation #: 22569340", and "Purchased: 04/29/2026". A single image may contain multiple reservations stacked vertically.

## Output columns (always these four, always in this order)

Date, Confirmation Number, Parking Space, Purchased

## Steps

1. Examine all provided images
2. Extract every reservation found — do not skip records in multi-reservation images
3. Sort rows by Date ascending
4. Display the CSV as a fenced code block
5. Write the CSV to `/tmp/park_reservations.csv` and run `pbcopy < /tmp/park_reservations.csv` using the Bash tool
6. State how many reservations were extracted

## Format rules

- First row: `Date,Confirmation Number,Parking Space,Purchased`
- Date as MM/DD/YYYY (e.g. `05/01/2026`)
- Parking Space as shown (e.g. `P 057`)
- Confirmation Number and Purchased exactly as printed
- No trailing blank lines
