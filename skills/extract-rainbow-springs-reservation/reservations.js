function getReservationsSheet() {
  return SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Reservations");
}

function applyDateFormat() {
  getReservationsSheet().getRange("A2:A").setNumberFormat("yyyy-mm-dd (ddd)");
}

function applyAlignment() {
  var range = getReservationsSheet().getRange("A:D");
  range.setHorizontalAlignment("left");
  range.setVerticalAlignment("middle");
}

function removeDuplicates() {
  var sheet = getReservationsSheet();
  var lastRow = sheet.getLastRow();
  if (lastRow < 2) return;

  var dataRange = sheet.getRange(2, 1, lastRow - 1, 4);
  var data = dataRange.getValues();

  var seen = {};
  var deduped = data.filter(function (row) {
    var key = String(row[1]);
    if (!key || seen[key]) return false;
    seen[key] = true;
    return true;
  });

  dataRange.clearContent();
  if (deduped.length > 0)
    sheet.getRange(2, 1, deduped.length, 4).setValues(deduped);
}

function applySort() {
  var sheet = getReservationsSheet();
  sheet
    .getRange(2, 1, sheet.getLastRow() - 1, 4)
    .sort({ column: 1, ascending: false });
}

function onOpen() {
  applyDateFormat();
  applyAlignment();
  removeDuplicates();
  applySort();
}
