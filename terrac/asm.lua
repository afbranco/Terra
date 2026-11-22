
opcode={
op_nop=0,
op_end=1,
op_bnot=2,
op_lnot=3,
op_neg=4,
op_sub=5,
op_add=6,
op_mod=7,
op_mult=8,
op_div=9,
op_bor=10,
op_band=11,
op_lshft=12,
op_rshft=13,
op_bxor=14,
op_eq=15,
op_neq=16,
op_gte=17,
op_lte=18,
op_gt=19,
op_lt=20,
op_lor=21,
op_land=22,
op_popx=23,


op_neg_f=25,
op_sub_f=26,
op_add_f=27,
op_mult_f=28,
op_div_f=29,
op_eq_f=30,
op_neq_f=31,
op_gte_f=32,
op_lte_f=33,
op_gt_f=34,
op_lt_f=35,
op_func=36,
op_outevt_e=37,
op_outevt_z=38,
op_clken_e=39,
op_clken_v=40,
op_clken_c=41,
op_set_v=42,
op_setarr_vc=43,
op_setarr_vv=44,



op_poparr_v=48,
op_pusharr_v=50,
op_getextdt_e=52,
op_trg=54,
op_exec=56,
op_chkret=58,
op_tkins_z=60,


op_push_c=64,
op_cast=68,
op_memclr=72,
op_ifelse=76,
op_asen=80,
op_tkclr=84,
op_outevt_c=88,
op_getextdt_v=92,
op_inc=96,
op_dec=100,
op_set_e=104,
op_deref=112,
op_memcpy=120,

op_tkins_max=136,
op_push_v=144,
op_pop=160,
op_outevt_v=176,
op_set_c=192,

}

typelen={
ubyte=0,byte=0,   -- 1 byte
ushort=1,short=1, -- 2 bytes
ulong=2,long=2,   -- 4 bytes
float=2,          -- 4 bytes
void=0,
}

sig={
ubyte='u',byte='s',
ushort='u',short='s',
ulong='u',long='s',
float='s',
void='u',
}
sign={
ubyte=0,byte=1,
ushort=0,short=1,
ulong=0,long=1,
float=1,
void=0,
}

vartype={
ubyte=0,byte=4,
ushort=1,short=5,
ulong=2,long=6,
float=3,
int=6,
}

--mode= 00:u32->f; 01:s32->f; 10:f->u32; 11:f->s32; 
castMode={
ulongfloat=0,
longfloat=1,
floatulong=2,
floatlong=3,
}


function OPCODE (me,line,codeA,codeB,n_stack)
	n_stack = n_stack or 0;
	code = code or '--'
	local idx=1
	LINE(me,line,0)
  local offset = table.getn(me.opcode)
	for token in string.gmatch(line, "[^%s]+") do
		me.opcode[offset+idx]=token
		me.n_stack[offset+idx]=n_stack
		n_stack = 0
		idx=idx+1
	end
    spc2 = 30 - string.len(codeA)
    if (spc2 < 0) then spc2 = 2 end
    spc2 = string.rep(' ', spc2)
    me.code2[offset+1] = (codeA or '')..spc2..'| '..(codeB or '') 
end

function BYTECODE(me,codeB,mnemonic,...)
	_OPCODES[mnemonic](me,codeB,...)
end



 _OPCODES = {

-- Generic opcode functions


-- Specific opcode functions
  -- arg={}
  op_nop= function (me,codeB)
    local bytecode = string.format('%02x',(opcode['op_nop']))
    local codeA = 'nop'
    OPCODE(me,bytecode,codeA,codeB)
  end, 

  -- arg={}
  op_end = function (me,codeB)
    local bytecode = string.format('%02x',(opcode['op_end']))
    local codeA = 'end'
    OPCODE(me,bytecode,codeA,codeB)
  end,

--[[
op_bnot= function (me,codeB,arg) end, 
op_lnot= function (me,codeB,arg) end, 
op_neg= function (me,codeB,arg) end, 
op_sub= function (me,codeB,arg) end, 
op_add= function (me,codeB,arg) end, 
op_mod= function (me,codeB,arg) end, 
op_mult= function (me,codeB,arg) end, 
op_div= function (me,codeB,arg) end, 
op_bor= function (me,codeB,arg) end, 
op_band= function (me,codeB,arg) end, 
op_lshft= function (me,codeB,arg) end, 
op_rshft= function (me,codeB,arg) end, 
op_bxor= function (me,codeB,arg) end, 
op_eq= function (me,codeB,arg) end, 
op_neq= function (me,codeB,arg) end, 
op_gte= function (me,codeB,arg) end, 
op_lte= function (me,codeB,arg) end, 
op_gt= function (me,codeB,arg) end, 
op_lt= function (me,codeB,arg) end, 
op_lor= function (me,codeB,arg) end, 
op_land= function (me,codeB,arg) end, 


op_neg_f= function (me,codeB,arg) end, 
op_sub_f= function (me,codeB,arg) end, 
op_add_f= function (me,codeB,arg) end, 
op_mult_f= function (me,codeB,arg) end, 
op_div_f= function (me,codeB,arg) end, 
op_eq_f= function (me,codeB,arg) end, 
op_neq_f= function (me,codeB,arg) end, 
op_gte_f= function (me,codeB,arg) end, 
op_lte_f= function (me,codeB,arg) end, 
op_gt_f= function (me,codeB,arg) end, 
op_lt_f= function (me,codeB,arg) end, 
--]]

  -- arg={funcID}
  op_func= function (me,codeB,funcID) 
    local bytecode = string.format('%02x',(opcode['op_func']))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(funcID))
    local codeA = 'func '..funcID
    OPCODE(me,bytecode,codeA,codeB,(-1*(_ENV.func_nArgs[funcID]))+1) -- nArgs pop's  + 1 return push
  end, 

 
  -- arg={evtId}
  op_outevt_e= function (me,codeB,evtId) 
    local bytecode=''
    local codeA = ''
      bytecode = string.format('%02x %02x',(opcode['op_outevt_e']),evtId)
      codeA = 'outevt_e '..evtId
    OPCODE(me,bytecode,codeA,codeB,-1)     
  end,
    
  -- arg={evtId}
  op_outevt_z = function (me,codeB,evtId)
    local bytecode = string.format('%02x',(opcode['op_outevt_z']))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(evtId))    
    local codeA = 'outevt_z '..evtId
    OPCODE(me,bytecode,codeA,codeB)     
  end, 
 
  -- arg={gate,unit,lblAddr}
  op_clken_e= function (me,codeB,gate,unit,lblAddr)
    local bytecode = string.format('%02x %02x',opcode['op_clken_e'],unit*(2^4)+_TP.getConstLen(gate)*(2^1)+_TP.getConstLenLbl(lblAddr)*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(gate),_TP.getConstBytesLbl(lblAddr))
    local codeA = 'clken_e '..gate ..' '..unit ..' '..lblAddr
    OPCODE(me,bytecode,codeA,codeB)     
  end,
 
 
  -- arg={gate,unit, varType, varAddr,lblAddr}
  op_clken_v= function (me,codeB,gate,unit, varType, varAddr,lblAddr)
    local bytecode = string.format('%02x %02x',opcode['op_clken_v'],unit*(2^5)+typelen[varType]*(2^3)+_TP.getConstLen(gate)*(2^2)+_TP.getConstLen(varAddr)*(2^1)+_TP.getConstLenLbl(lblAddr)*(2^0))
    bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(gate),_TP.getConstBytes(varAddr),_TP.getConstBytesLbl(lblAddr))
    local codeA = 'clken_v '..gate ..' '..unit ..' '..varType ..' '..varAddr ..' '..lblAddr
    OPCODE(me,bytecode,codeA,codeB)     
  end,


  -- arg={gate,constTime,lblAddr}
  op_clken_c= function (me,codeB,gate,constTime,lblAddr) 
    local bytecode = string.format('%02x %02x',opcode['op_clken_c'],_TP.getConstLen(gate)*(2^3)+_TP.getConstLen(constTime)*(2^1)+_TP.getConstLenLbl(lblAddr)*(2^0))
    bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(gate),_TP.getConstBytes(constTime),_TP.getConstBytesLbl(lblAddr))
    local codeA = 'clken_c '..gate ..' '..constTime ..' '..lblAddr 
    OPCODE(me,bytecode,codeA,codeB)   
  end, 
 
  -- arg={var1Type,var2Type,var1Addr,var2Addr}  
  op_set_v= function (me,codeB,var1Type,var2Type,var1Addr,var2Addr) 
    local bytecode = string.format('%02x %02x', opcode['op_set_v'], _TP.getConstLen(var1Addr)*(2^7) + vartype[var1Type]*(2^4) + _TP.getConstLen(var2Addr)*(2^3) + vartype[var2Type]*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(var1Addr),_TP.getConstBytes(var2Addr))   
    local codeA = 'set_v' ..' ' ..var1Type ..' '..var1Addr..' ' ..var2Type  ..' '..var2Addr
    OPCODE(me,bytecode,codeA,codeB)
  end, 
 
  -- arg={arrType,arrAddr,idxType,idxAddr,idxMax,constVal}
  op_setarr_vc= function (me,codeB,arrType,arrAddr,idxType,idxAddr,idxMax,constVal) 
    local bytecode = string.format('%02x %02x %02x', 
        opcode['op_setarr_vc'], 
        _TP.getConstLen(arrAddr)*(2^7) + vartype[arrType]*(2^4) + _TP.getConstLen(idxAddr)*(2^3) + vartype[idxType]*(2^0),
        _TP.getConstLen(idxMax)*(2^2)+_TP.getConstLen(constVal)*(2^0))
    bytecode = string.format('%s %s %s %s %s',bytecode,_TP.getConstBytes(arrAddr),_TP.getConstBytes(idxAddr),_TP.getConstBytes(idxMax),_TP.getConstBytes(constVal))
    local codeA = 'setarr_vc '..arrType ..' '..arrAddr ..' '..idxType ..' '..idxAddr ..' '..idxMax ..' '..constVal
    OPCODE(me,bytecode,codeA,codeB)
  end, 
 
  -- arg={arrType,arrAddr,idxType,idxAddr,idxMax,varType,varAddr}
  op_setarr_vv= function (me,codeB,arrType,arrAddr,idxType,idxAddr,idxMax,varType,varAddr) 
    local bytecode = string.format('%02x %02x %02x', 
        opcode['op_setarr_vv'], 
        _TP.getConstLen(arrAddr)*(2^7) + vartype[arrType]*(2^4) + _TP.getConstLen(idxAddr)*(2^3) + vartype[idxType]*(2^0),
        _TP.getConstLen(idxMax)*(2^4) + _TP.getConstLen(varAddr)*(2^3) + vartype[varType]*(2^0))
    bytecode = string.format('%s %s %s %s %s',bytecode,_TP.getConstBytes(arrAddr),_TP.getConstBytes(idxAddr),_TP.getConstBytes(idxMax),_TP.getConstBytes(varAddr))
    local codeA = 'setarr_vv '..arrType ..' '..arrAddr ..' '..idxType ..' '..idxAddr ..' '..idxMax ..' '..varType ..' '..varAddr
    OPCODE(me,bytecode,codeA,codeB)
  end, 



  -- arg={varType,idxType,idxAddr,ArrSize,ArrAddr}
  op_poparr_v= function (me,codeB,varType,idxType,idxAddr,ArrSize,ArrAddr)
    local bytecode = string.format('%02x %02x',
      (opcode['op_poparr_v'])+_TP.getConstLen(ArrSize)*(2^0),
      (_TP.getConstLen(ArrAddr)*(2^7) + vartype[varType]*(2^4) + _TP.getConstLen(idxAddr)*(2^3) + vartype[idxType]*(2^0)))
    bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(ArrAddr),_TP.getConstBytes(idxAddr),_TP.getConstBytes(ArrSize))
    local codeA = 'poparr_v '..varType ..' '..ArrAddr ..' '..idxType ..' '..idxAddr ..' '..ArrSize
    OPCODE(me,bytecode,codeA,codeB,-1)  
  end, 
  
  -- arg={varType,idxType,idxAddr,ArrSize,ArrAddr}
  op_pusharr_v= function (me,codeB,varType,idxType,idxAddr,ArrSize,ArrAddr)
    local bytecode = string.format('%02x %02x',
      (opcode['op_pusharr_v'])+_TP.getConstLen(ArrSize)*(2^0),
      (_TP.getConstLen(ArrAddr)*(2^7) + vartype[varType]*(2^4) + _TP.getConstLen(idxAddr)*(2^3) + vartype[idxType]*(2^0)))
    bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(ArrAddr),_TP.getConstBytes(idxAddr),_TP.getConstBytes(ArrSize))
    local codeA = 'pusharr_v '..varType ..' '..ArrAddr ..' '..idxType ..' '..idxAddr ..' '..ArrSize
    OPCODE(me,bytecode,codeA,codeB,1)
  end,

  -- arg={size}
  op_getextdt_e= function (me,codeB,size)
    local bytecode = string.format('%02x',(opcode['op_getextdt_e']) + _TP.getConstLen(size))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(size))
    local codeA = 'getextdt_e '..size
    OPCODE(me,bytecode,codeA,codeB)   
  end, 

  -- arg={gate}
  op_trg= function (me,codeB,gate) 
    local bytecode = string.format('%02x',(opcode['op_trg'])+(_TP.getConstLen(gate)))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(gate))
    local codeA = 'trg '..gate
    OPCODE(me,bytecode,codeA,codeB) 
  end,

  -- arg={lblAddr}
  op_exec = function (me,codeB,lblAddr)
    local bytecode = string.format('%02x',(opcode['op_exec'])+(_TP.getConstLenLbl(lblAddr)))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytesLbl(lblAddr))
    local codeA = 'exec '..lblAddr
    OPCODE(me,bytecode,codeA,codeB)
  end,
  
  -- arg={lblAddr}
  op_chkret= function (me,codeB,lblAddr)
    local bytecode = string.format('%02x',(opcode['op_chkret'])+(_TP.getConstLen(lblAddr)))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(lblAddr)) -- Não marcar como Label, já aponta diretor para memória de dados.
    local codeA = 'chkret '..lblAddr
    OPCODE(me,bytecode,codeA,codeB)
  end,


  -- arg={ConstValue}
  op_push_c= function (me,codeB,ConstValue)
    local bytecode = string.format('%02x',(opcode['op_push_c'])+_TP.getConstLen(ConstValue))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(ConstValue))
    local codeA = 'push_c '..ConstValue
    OPCODE(me,bytecode,codeA,codeB,1)
  end,

  -- arg={fromType,toType}
  op_cast= function (me,codeB,fromType,toType)      
    local bytecode = string.format('%02x',(opcode['op_cast'])+(castMode[fromType .. toType] or 0)*(2^0))
    local codeA = 'cast '..fromType ..' '..toType .. ' ('.. (castMode[fromType .. toType] or "--")..')'
    OPCODE(me,bytecode,codeA,codeB)
  end,

  -- arg={size,addr}
  op_memclr = function (me,codeB,size,addr)
    local bytecode = string.format('%02x',(opcode['op_memclr']) + _TP.getConstLen(addr)*(2^1) + _TP.getConstLen(size)*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(addr),_TP.getConstBytes(size))
    local codeA = 'memclr '..addr ..' '..size
    OPCODE(me,bytecode,codeA,codeB)
  end,

  -- arg={lblTAddr,lblFAddr}
  op_ifelse= function (me,codeB,lblTAddr,lblFAddr) 
    local bytecode = string.format('%02x',(opcode['op_ifelse']) + _TP.getConstLenLbl(lblTAddr)*(2^1) + _TP.getConstLenLbl(lblFAddr)*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytesLbl(lblTAddr),_TP.getConstBytesLbl(lblFAddr))
    local codeA = 'ifelse '..lblTAddr ..' '..lblFAddr
    OPCODE(me,bytecode,codeA,codeB,-1)      
  end, 

  -- arg={gate,lblAddr)
  op_asen= function (me,codeB,gate,lblAddr)
    local bytecode = string.format('%02x',(opcode['op_asen']) + _TP.getConstLen(gate)*(2^1) + _TP.getConstLenLbl(lblAddr)*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(gate),_TP.getConstBytesLbl(lblAddr))
    local codeA = 'asen '..gate ..' '..lblAddr
    OPCODE(me,bytecode,codeA,codeB)   
  end, 

  -- arg={lbl1Addr,lbl2Addr}
  op_tkclr= function (me,codeB,lbl1Addr,lbl2Addr) 
    local bytecode = string.format('%02x',(opcode['op_tkclr']) + _TP.getConstLenLbl(lbl1Addr)*(2^1) + _TP.getConstLenLbl(lbl2Addr)*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytesLbl(lbl1Addr),_TP.getConstBytesLbl(lbl2Addr))
    local codeA = 'tkclr '..lbl1Addr ..' '..lbl2Addr
    OPCODE(me,bytecode,codeA,codeB)     
  end, 
 
  -- arg={evtId,constVal}
  op_outevt_c = function (me,codeB,evtId,constVal)
    local bytecode = string.format('%02x',(opcode['op_outevt_c']) + _TP.getConstLen(constVal)*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(evtId),_TP.getConstBytes(constVal))   
    local codeA = 'outevt_c '..evtId..' '..constVal
    OPCODE(me,bytecode,codeA,codeB)     
  end, 

  -- arg={addr,size}
  op_getextdt_v= function (me,codeB,addr,size)
    local bytecode = string.format('%02x',(opcode['op_getextdt_v']) + _TP.getConstLen(addr)*(2^1) + _TP.getConstLen(size)*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(addr),_TP.getConstBytes(size))
    local codeA = 'getextdt_v '..addr ..' '..size
    OPCODE(me,bytecode,codeA,codeB)   
  end, 
 
  -- arg={type}
  op_inc= function (me,codeB,type)
    local bytecode = string.format('%02x',(opcode['op_inc'])+(typelen[type] or '0' )*(2^0))
    local codeA = 'inc'..' '..type
    OPCODE(me,bytecode,codeA,codeB,-1)
  end, 

  -- arg={type}
  op_dec= function (me,codeB,type)      
    local bytecode = string.format('%02x',(opcode['op_dec'])+(typelen[type] or '0' )*(2^0))
    local codeA = 'dec'..' '..type
    OPCODE(me,bytecode,codeA,codeB,-1)
  end, 
 
  -- arg={type}
  op_set_e= function (me,codeB,type) 
    local bytecode = string.format('%02x',(opcode['op_set_e'])+vartype[type]*(2^0))
    local codeA = 'set_e'..' '.. type
    OPCODE(me,bytecode,codeA,codeB,-2)
  end,
 
  -- arg={type}
  op_deref= function (me,codeB,type)      
    local bytecode = string.format('%02x',(opcode['op_deref'])+vartype[type]*(2^0))
    local codeA = 'deref '..type
    OPCODE(me,bytecode,codeA,codeB)
  end, 

  -- arg={size,addrFrom,addrTo}
  op_memcpy= function (me,codeB,size,addrFrom,addrTo)
  local bytecode = string.format('%02x',(opcode['op_memcpy']) + _TP.getConstLen(size)*(2^2) + _TP.getConstLen(addrFrom)*(2^1) + _TP.getConstLen(addrTo)*(2^0))
  bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(size),_TP.getConstBytes(addrFrom),_TP.getConstBytes(addrTo))
  local codeA = 'memcpy '..size ..'B. '..addrFrom ..' -> '.. addrTo
  OPCODE(me,bytecode,codeA,codeB)   
  end, 

 
  -- arg={chk,tree,lblAddr)
  op_tkins_z= function (me,codeB,chk,tree,lblAddr) 
    local bytecode = string.format('%02x %02x',(opcode['op_tkins_z']) + _TP.getConstLenLbl(lblAddr)*2^0, chk*(2^7)+tree*(2^0))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytesLbl(lblAddr))   
    local codeA = 'tkins_z '..chk ..' '..tree ..' '..lblAddr
    OPCODE(me,bytecode,codeA,codeB)       
  end, 
 
  -- arg={stack,lblAddr)
  op_tkins_max= function (me,codeB,stack,lblAddr) 
    local bytecode = string.format('%02x',(opcode['op_tkins_max']) +  stack*(2^1) + _TP.getConstLenLbl(lblAddr)*2^0)
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytesLbl(lblAddr))    
    local codeA = 'tkins_max '..stack..' '..lblAddr
    OPCODE(me,bytecode,codeA,codeB)     
  end, 
 
  -- arg={type,addr}
  op_push_v= function (me,codeB,type,addr)
    local bytecode=''
    bytecode = string.format('%02x',(opcode['op_push_v'])+_TP.getConstLen(addr)*(2^3)+vartype[type]*(2^0))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(addr))
    local codeA = 'push_v'..' '..type ..' '..addr
    OPCODE(me,bytecode,codeA,codeB,1)
  end,
 
  -- arg={type,addr}
  op_pop= function (me,codeB,type,addr) 
    local bytecode = string.format('%02x',(opcode['op_pop'])+_TP.getConstLen(addr)*(2^3)+vartype[type]*(2^0))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(addr))
    local codeA = 'pop'..' '..type ..' '..addr
    OPCODE(me,bytecode,codeA,codeB,-1)
  end,

  -- arg={type,addr}
  op_popx= function (me,codeB) 
    local bytecode = string.format('%02x',(opcode['op_popx']))
    local codeA = 'popx'
    OPCODE(me,bytecode,codeA,codeB,-1)
  end,

  -- arg={evtId,varAddr,type}
  op_outevt_v= function (me,codeB,evtId,varAddr,type) 
    local bytecode = string.format('%02x',(opcode['op_outevt_v'])+_TP.getConstLen(varAddr)*(2^3)+vartype[type]*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(evtId),_TP.getConstBytes(varAddr))   
    local codeA = 'outevt_v '..evtId ..' '..varAddr
    OPCODE(me,bytecode,codeA,codeB)     
  end,
 
  -- arg={varType,varAddr,constVal,lblAddr}
  op_set_c= function (me,codeB,varType,varAddr,constVal,lblAddr) 
    local bytecode = string.format('%02x',(opcode['op_set_c']) + ((lblAddr and 1) or _TP.getConstLen(constVal))*(2^4) +_TP.getConstLen(varAddr)*(2^3)+vartype[varType]*(2^0))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(varAddr),(lblAddr and _TP.getConstBytesLbl(constVal)) or _TP.getConstBytes(constVal))
    local codeA = 'set_c '..varType..' '..varAddr..' '.. constVal
    OPCODE(me,bytecode,codeA,codeB)     
  end,


 	-- arg={lblAddr} 	
	lbl = function (me,codeB,lblAddr)
		local bytecode = string.format('L%04x',lblAddr)
		local codeA = bytecode
		OPCODE(me,bytecode,codeA,codeB)
	end,

------
-- Deprecated
-- 
--[[
  -- arg={}
  op_any = function (me,codeB,arg)
--print("asm::op_any:",arg[1],arg[2],arg[3])
    local bytecode = string.format('%02x %02x',(opcode['op_'..arg[1] ])+(typelen[arg[3] ] or '0' ),arg[2])
    local codeA = arg[1]..' '..arg[3]..' '..arg[2]
    OPCODE(me,bytecode,codeA,codeB)
  end,
--]]

 	-- arg={oper}
	op1_any = function (me,codeB,oper)
		local bytecode = string.format('%02x',(opcode['op_'..oper]))
		local codeA = oper
		OPCODE(me,bytecode,codeA,codeB)
	end,

 	-- arg={oper}
	op2_any = function (me,codeB,oper)
--print(unpack(arg))
		local bytecode = string.format('%02x',(opcode['op_'..oper]))
		local codeA = oper
		OPCODE(me,bytecode,codeA,codeB,-1)
	end,

}


