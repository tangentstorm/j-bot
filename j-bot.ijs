NB. an irc bot written in j
NB. Copyright © 2014 michal j wallace ( http://tangentstorm.com/ )
NB. Available for use under the MIT/X11 License

NB. -- socket stuff --------------------------------------------
coclass 'Socket'
coinsert 'jsocket' [ require 'socket'
create =: 3 : 0
  SOCK =: >{. sdcheck sdsocket ''
  MAXT =: 50 NB. max time in milliseconds for canr/canw
  ENDL =: CRLF NB. end literal to expect after each line
  ENDW =: CRLF NB. end literal to send after each 'send'
)
open =: 3 : 0
  'HOSTNAME PORT' =: y
  HOST =. sdcheck sdgethostbyname HOSTNAME
  sdcheck sdconnect SOCK ; HOST ,< PORT
)
send =: 3 :'sdcheck (y, ENDW) sdsend SOCK, 0'
recv =: 3 : '> sdcheck sdrecv SOCK ; y ; 0'
canr =: 3 : 'y e. >{. sdcheck sdselect y ; a:,a:,< MAXT'
canw =: 3 : 'a: , SOCK ; ,a:,< MAXT'
read =: 3 : ',; a:-.~ ,([: <@recv 1024"_)^:([: canr SOCK"_)^:a: y'

NB. -- irc stuff -----------------------------------------------
coclass 'IRCClient'
create =: 3 : 0
  s =: '' conew 'Socket'
  'NICK HOST PORT' =: y
  open__s HOST; PORT
  send__s 'NICK ', NICK
  send__s 'USER ', NICK, ' tangentcode.com bla :', NICK
  BUFF =: FRAG =: ''  NB. line and character buffers
)

join =: 3 : 0
  send__s 'JOIN ', y
)

endswith =: 4 : '(x i: y) = (<: # x)'
cutafter =: 4 : 0
 if. y e. x do. 2 {. ((i. # x) > (x i: y)) </. x
 else. y;x end.
)
assert 'end' endswith 'd'
assert ('defend' cutafter 'f') -: ('def' ; 'end')
assert ('end' cutafter 'f') -: ('f'; 'end')
assert ('' cutafter 'f') -: ('f'; '')

nextln =: 3 : 0
  assert 0 = L. chunk =: read__s''
  if. # chunk do.
    'lines FRAG' =: (FRAG, chunk) cutafter LF
    assert lines endswith LF
    BUFF =: BUFF, <;.2 CR -.~ lines
  end.
  BUFF =: }. BUFF  [ r =: {. BUFF
  r  NB. the next line (as a boxed string)
)

flush =: 3 : ';nextln^:a:y'



NB. -- the bot -------------------------------------------------
cocurrent'base'
words =: [: s: ' ' , ]
bot =: ('jjbot';'irc.freenode.net'; 6667) conew 'IRCClient'
join__bot '#j-bot'
echo flush__bot''
