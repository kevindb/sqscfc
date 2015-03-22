# Amazon SQS CFC #

Exported from code.google.com/p/sqscfc

## Summary ##

A [ColdFusion](http://adobe.com/coldfusion) component for accessing the [Amazon Simple Queue Service (SQS) API](http://www.amazon.com/Simple-Queue-Service-home-page/b/ref=sc_fe_l_2/105-0650141-8105232?ie=UTF8&node=13584001&no=3435361&me=A36L942TSJ2AJA).

## Description ##

The Amazon Simple Queue Service (SQS) provides large, scalable, distributed queues for storing and retrieving data ("messages").

The component provides an abstraction layer over the SQS API so that you don't have to get your hands dirty with forming HTTP headers and parsing CFHTTP.FileContent and traversing XML trees. Since the SQS API is accessible via query-string and REST (and SOAP) interfaces, and since the query-string implementation has limitations compared with the REST implementation for certain operations, the SQS CFC uses REST for those operations and query-string for the others, so you can get the maximum functionality out of SQS.

## Requirements ##

  * Amazon Web Services account
  * HMAC.cfc, (included) for signing requests

## Compatibility ##

Compatible with ColdFusion MX 7 and above.
