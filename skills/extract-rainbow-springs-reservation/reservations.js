function getReservationsSheet() {
  return SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Reservations");
}

function applyDateFormat() {
  var sheet = getReservationsSheet();
  sheet.getRange("A2:A").setNumberFormat("yyyy-mm-dd (ddd)");
  sheet.getRange("B2:B").setNumberFormat("@");
  sheet.getRange("C2:C").setNumberFormat("@");
  sheet.getRange("D2:D").setNumberFormat("yyyy-mm-dd");
  sheet.getRange("E2:E").setNumberFormat("#,##0;(#,##0)");
}

function applyAlignment() {
  var sheet = getReservationsSheet();
  sheet
    .getRange("A:D")
    .setHorizontalAlignment("left")
    .setVerticalAlignment("middle");
  sheet
    .getRange("E:E")
    .setHorizontalAlignment("right")
    .setVerticalAlignment("middle");
}

function removeDuplicates() {
  var sheet = getReservationsSheet();
  var lastRow = sheet.getLastRow();
  if (lastRow < 2) return;

  var dataRange = sheet.getRange(2, 1, lastRow - 1, 4);
  var data = dataRange.getValues();

  var seen = {};
  var deduped = data.filter(function (row) {
    var key = String(row[0]) + "|" + String(row[1]);
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
