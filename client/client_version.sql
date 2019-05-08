Alap esetben a v$session_connect_info nézetből kérdezhető le a kliensek verziója, de sajnos ez 11.2.0.4-es DB verziótól működik, előtte BUG-os.

SELECT   vinf.sid,
            TO_NUMBER (SUBSTR (vinf.v, 8, 2), 'xx')
         || '.'
         || SUBSTR (vinf.v, 10, 1)
         || '.'
         || SUBSTR (vinf.v, 11, 2)
         || '.'
         || SUBSTR (vinf.v, 13, 1)
         || '.'
         || SUBSTR (vinf.v, 14, 2)
            client_version,
         s.*
  FROM   (SELECT   DISTINCT ksusenum sid, TO_CHAR (ksuseclvsn, 'xxxxxxxxxxxxxx') v
            FROM   x$ksusecon
           WHERE   ksuseclvsn != 0) vinf,
         v$session s
 WHERE   s.sid = vinf.sid(+);