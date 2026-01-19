<script runat="server">
Platform.Load("core","1.1.1");

/**
 * WSProxy Batch Processing:
 * Optimized for memory efficiency and system stability.
 */

var DE_KEY = "YOUR_EXTERNAL_KEY"; // Use CustomerKey/ExternalKey
var prox = new Script.Util.WSProxy();
var objectType = "DataExtensionObject[" + DE_KEY + "]";
var cols = getFields(DE_KEY);

var moreData = true;
var reqID = null;
var totalCount = 0;

while (moreData) {
  // Use 2 parameters for getNextBatch to ensure compatibility
  var resp = (reqID === null) ? prox.retrieve(objectType, cols) : prox.getNextBatch(objectType, reqID, cols);

  if (!resp || !resp.Results) break;

  moreData = !!resp.HasMoreRows;
  reqID = resp.RequestID;

  for (var i = 0; i < resp.Results.length; i++) {
    var row = formatRow(resp.Results[i].Properties);
    totalCount++;
    
    // BUSINESS LOGIC HERE: 
    // e.g., Update another DE, Call an API, etc.
    // Processing row-by-row prevents Memory Overflow.
  }
}

Write("Successfully processed: " + totalCount + " rows.");

function getFields(key) {
  var de = DataExtension.Init(key);
  var fields = de.Fields.Retrieve();
  var out = [];
  for (var i = 0; i < fields.length; i++) { out.push(fields[i].Name); }
  return out;
}

function formatRow(props) {
  var obj = {};
  for (var j = 0; j < props.length; j++) {
    var k = props[j].Name;
    var v = props[j].Value;
    if (k && k.charAt(0) !== "_") obj[k] = v; 
  }
  return obj;
}
</script>
