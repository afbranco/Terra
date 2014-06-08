/*{-{*/

changequote(<,>)
changequote(`,´)
changecom(//,)


// Boolean
@define(TRUE,1)
@define(FALSE,0)
// Leds Constants
@define(ON,1)
@define(OFF,0)
@define(TOGGLE,2)
// Interrupt config
@define(RISING,1)
@define(FALLING,0)
@define(DISABLE,2)
// Sensor IDs
@define(SID_TEMP,1)
@define(SID_PHOTO,2)
@define(SID_LEDS,3)
@define(SID_VOLT,4)
@define(SID_PORT_A,5)
@define(SID_PORT_B,6)
@define(SID_INT_A,7)
@define(SID_INT_B,8)
// Port Cfg
@define(pIN,0)
@define(pOUT,1)
// Message
@define(BROADCAST,0xffff)



dnl Out Events counter
define(`__out_seq´, `0´)
define(`_out_seq´, `_$0`´define(`_$0´,incr(_$0))´)
dnl In Events counter
define(`__in_seq´, `0´)
define(`_in_seq´, `_$0`´define(`_$0´,incr(_$0))´)
dnl Group Id counter
define(`__gr_seq´, `1´)
define(`_gr_seq´, `_$0`´define(`_$0´,incr(_$0))´)
dnl Aggreg Id counter
define(`__ag_seq´, `0´)
define(`_ag_seq´, `_$0`´define(`_$0´,incr(_$0))´)

@define(EVT_OUT, `/*{-{*/
dnl [ 1: name ] Event name
dnl [ 2: type ] Event type
output $2 $1;
@define(OUT_$1,_out_seq)
/*}-}*/´)

@define(EVT_IN, `/*{-{*/
dnl [ 1: name ] Event name
dnl [ 2: type ] Event type
input $2 $1;
@define(IN_$1,_in_seq)
/*}-}*/´)

// Terra Default events

EVT_OUT(INIT,int)
EVT_OUT(LEDS,int)
EVT_OUT(LED0,int)
EVT_OUT(LED1,int)
EVT_OUT(LED2,int)
EVT_OUT(REQ_TEMP,void)
EVT_OUT(REQ_PHOTO,void)
EVT_OUT(REQ_VOLTS,void)
EVT_OUT(SEND,_usrMsg_t*)
EVT_OUT(SEND_ACK,_usrMsg_t*)
EVT_OUT(SET_PORT_A,int)
EVT_OUT(SET_PORT_B,int)
EVT_OUT(CFG_PORT_A,int)
EVT_OUT(CFG_PORT_B,int)
EVT_OUT(REQ_PORT_A,int)
EVT_OUT(REQ_PORT_B,int)
EVT_OUT(CFG_INT_A,int)
EVT_OUT(CFG_INT_B,int)
EVT_OUT(REQ_CUSTOM_A,int)
EVT_OUT(Q_PUT,_usrMsg_t*)
EVT_OUT(Q_GET,_usrMsg_t*)
EVT_OUT(Q_SIZE,int*)
EVT_OUT(Q_CLEAR,void)

EVT_IN(TEMP,int)
EVT_IN(PHOTO,int)
EVT_IN(VOLTS,int)
EVT_IN(SEND_DONE,int)
EVT_IN(SEND_DONE_ACK,int)
EVT_IN(RECEIVE,_usrMsg_t*)
EVT_IN(Q_READY,int)
EVT_IN(PORT_A,int)
EVT_IN(PORT_B,int)
EVT_IN(INT_A,int)
EVT_IN(INT_B,int)
EVT_IN(CUSTOM_A,int)



@define(`_trim´,`patsubst($1,`\s+´,`´)´)

var u16 nodeId;
emit INIT(nodeId);


@define(usrMsg_t, `/*{-{*/
dnl [ 1: name    ] Structure name
dnl [ 2: msgId   ] MsgId
`//******* struct msg BS: $1 ************´
ifelse(eval(`$#´ == 2),0,
`errprint(`WDceu:´__file__:__line__: `Expecting three parameter: wd_msg_bs_t( name, msgId, varDefs)
´)´,
eval(len($2) > 0),eval(`0´),
`errprint(`WDceu:´__file__:__line__: `Expecting one numerical value
´)´,
eval( eval($2) > 0),1,`var u8 _trim($1)_id = $2;´,
`errprint(`WDceu:´__file__:__line__: `Id must be > 0
´)´
)
C _`´_trim($1)_t = 25;
var u16 _trim($1)_source;
var u16 _trim($1)_target;
var u8 _trim($1)_d8_1;
var u8 _trim($1)_d8_2;
var u8 _trim($1)_d8_3;
var u8 _trim($1)_d8_4;
var u16 _trim($1)_d16_1;
var u16 _trim($1)_d16_2;
var u16 _trim($1)_d16_3;
var u16 _trim($1)_d16_4;
var u32 _trim($1)_d32_1;
var u32 _trim($1)_d32_2;
var _`´_trim($1)_t* $1 = &$1_id;

//------------------------------
/*}-}*/´)




/*}-}*/dnl
