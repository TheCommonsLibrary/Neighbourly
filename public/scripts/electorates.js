document.ready(function () {
  var submitButton = $('submit-electorate');
  var electorateName = $('electorate').text();

  submitButton.onClick(function () {
    var elasticSearchUrl = 'https://site:a1534a534ef72b948437133ae441e134@kili-eu-west-1.searchly.com/_search';
    var requestPayload = {
      "query": {
        "bool": {
          "must": [
            {
              "query_string": {
                "default_field": "slug",
                "query": electorateName
              }
            }
          ]
        }
      }
    };

    $.post(elasticSearchUrl, requestPayload, function (response) {

    });
  });
});