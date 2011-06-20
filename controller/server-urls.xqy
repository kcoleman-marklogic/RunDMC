(: Processes the server URL configuration in server-urls.xml :)

module namespace s = "http://marklogic.com/rundmc/server-urls";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace u = "http://marklogic.com/rundmc/util"
       at "../lib/util-2.xqy";

declare variable $s:hosts := u:get-doc('/config/server-urls.xml')/hosts/host;

declare variable $s:host-name := xdmp:host-name(xdmp:host());

declare variable $s:this-host :=  if ($s:hosts[@name eq $s:host-name])
                                 then $s:hosts[@name eq $s:host-name]
                                 else $s:hosts[@default-host]; (: default means we're on a development machine :)

(: "staging", "production", or "development" :)
declare variable $s:host-type := string($s:this-host/@type);

declare variable $s:current-request-host := xdmp:get-request-header('Host');

declare variable $s:request-host-without-port := if (contains($s:current-request-host,':'))
                                        then substring-before($s:current-request-host,':')
                                        else                  $s:current-request-host;

declare variable $s:main-server   := s:server-url("main");
declare variable $s:draft-server  := s:server-url("draft");
declare variable $s:webdav-server := s:server-url("webdav");
declare variable $s:api-server    := s:server-url("api");

(: Use the @url if provided in the config; otherwise, use the same server but with the specified @port :)
declare function s:server-url($type as xs:string) {
  let $element-name  := concat($type,'-server'),
      $server-config := $s:this-host/*[local-name(.) eq $element-name] return
  if ($server-config/@url)
  then string($server-config/@url)
  else concat('http://',$s:request-host-without-port,':',$server-config/@port)
};
