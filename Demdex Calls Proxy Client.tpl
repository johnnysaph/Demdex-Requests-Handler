___INFO___

{
  "type": "CLIENT",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Demdex Calls Proxy Client",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "organizationId",
    "displayName": "Experience Cloud organization ID",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

// Imports for Sandboxed Javascript
const claimRequest = require('claimRequest');
const logToConsole = require('logToConsole');
const getRequestHeader = require('getRequestHeader');
const getRequestPath = require('getRequestPath');
const getRequestQueryString = require('getRequestQueryString');
const getRequestQueryParameter = require('getRequestQueryParameter');
const returnResponse = require('returnResponse');
const sendHttpGet = require('sendHttpGet');
const setResponseBody = require('setResponseBody');
const setResponseHeader = require('setResponseHeader');
const setResponseStatus = require('setResponseStatus');
const setCookie = require('setCookie');
const computeEffectiveTldPlusOne = require('computeEffectiveTldPlusOne');
const getCookieValues = require('getCookieValues');

const proxyResponse = (response, headers, statusCode, origin, cookieDomain) => {
	setResponseStatus(statusCode);
	setResponseBody(response);
    // cors
	setResponseHeader('Access-Control-Allow-Origin', origin);
	setResponseHeader('Access-Control-Allow-Credentials', 'true');
    // headers
	for (const key in headers) {
        // demdex cookie
		if (key == 'set-cookie') {
			logToConsole('setting newCookieValue...');
			var demdexCookie = headers[key][0];
			// logToConsole(demdexCookie);
			var demdexCookieValue = getDemdexCookieValue(demdexCookie);
			// logToConsole(demdexCookieValue);
			setCookie('demdex', demdexCookieValue, {'max-age': 15552000, 'domain': cookieDomain, 'path': '/'});
		} else {
			setResponseHeader(key, headers[key]);
		}
	}
	returnResponse();
};

const getDemdexCookieValue = (demdexCookie) => {
	var parsedValue = demdexCookie.split('; ');
	return  parsedValue[0].split('=')[1];
};

const removeGetParameter = (queryString, parameterName) => {
	var queryStringValues = queryString.split('&');
	var newQueryStringValues = [];
	for (var i = 0; i < queryStringValues.length; i++) {
		if (parameterName != queryStringValues[i].split('=')[0]) {
			newQueryStringValues.push(queryStringValues[i]);
		}
	}
	return newQueryStringValues.join('&');
};

if(getRequestPath() == '/id' && getRequestQueryParameter('d_orgid') == data.organizationId) {
	claimRequest();
    var queryString;
    var origin = getRequestHeader('origin');
    var cookieDomain = '.' + computeEffectiveTldPlusOne(origin);
    if (getRequestQueryParameter('d_coppa')) {
      queryString = removeGetParameter(getRequestQueryString(), 'd_coppa');
    } else {
      queryString = getRequestQueryString();
    }
    var demdexRequestUrl = 'https://dpm.demdex.net/id?' + queryString;
    // checking if demdex cookie is in incoming request header
    if (getCookieValues('demdex') && getCookieValues('demdex')[0]) {
      // taking the current demdex cookie value and sending it to the demdex.net
      var currentDemdexCookieValue = 'demdex=' + getCookieValues('demdex')[0];
      sendHttpGet(demdexRequestUrl, (statusCode, headers, body) => {
        proxyResponse(body, headers, statusCode, origin, cookieDomain);
      }, {headers: {'Cookie': currentDemdexCookieValue}, timeout: 500});
    } else {
      sendHttpGet(demdexRequestUrl, (statusCode, headers, body) => {
	    proxyResponse(body, headers, statusCode, origin, cookieDomain);
      }, {timeout: 5000});
    }
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "return_response",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "all"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "demdex"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "demdex"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 10/27/2021, 4:19:23 PM
