
opcode={
	op_nop=0,
	op_end=1,
	op_return=2,
	op_sub=3,
	op_add=4,
	op_mod=5,
	op_mult=6,
	op_div=7,
	op_bor=8,
	op_band=9,
	op_lshft=10,
	op_rshft=11,
	op_bxor=12,
	op_eq=13,
	op_neq=14,
	op_gte=15,
	op_lte=16,
	op_gt=17,
	op_lt=18,
	op_lor=19,
	op_land=20,
	op_bnot=21,
	op_lnot=22,
	op_neg=23,
	op_cast=24,
  op_inc=24,
  op_dec=25,
	op_push_c=28,
	op_push_vs=32,
	op_push_vu=36,
	op_pushx_vs=40,
	op_pushx_vu=44,
	op_push_ps=48,
	op_push_pu=52,
	op_pushx_ps=56,
	op_pushx_pu=60,
	op_pusharr_v=68,
	op_pop_s=72,
	op_pop_u=76,
	op_popx_s=80,
	op_popx_u=84,
	op_poparr_v=92,
	op_setarr_vc=96,
	op_setarr_vv=100,
	op_memclr=104,
	op_getextdt_p=108,
	op_getextdt_v=112,
	op_chkret=120,
	op_exec=124,
	op_ifelse=128,
	op_outevt_c=132,
	op_outevt_v=136,
	op_outevtx_c=140,
	op_outevtx_v=144,
	op_outevt_z=148,
	op_tkclr=152,
	op_trg=156,
	op_set_c=160,
	op_set_v=176,
	op_clken_c=192,
	op_clken_v=208,
	op_tkins_max=224,
	op_tkins_z=240,
  op_asen = 240,
}

typelen={
ubyte=0,byte=0, -- 1 byte
ushort=1,short=1, -- 2 bytes
ulong=2,long=2, -- 4 bytes
void=0,
}

sig={
ubyte='u',byte='s', -- 1 byte
ushort='u',short='s', -- 2 bytes
ulong='u',long='s', -- 4 bytes
void='u',
}
sign={
ubyte=0,byte=1, -- 1 byte
ushort=0,short=1, -- 2 bytes
ulong=0,long=1, -- 4 bytes
void=0,
}

vartype={
ubyte=0,byte=4, -- 1 byte
ushort=1,short=5, -- 2 bytes
ulong=2,long=6, -- 4 bytes
int=6, -- 4 bytes
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
	_OPCODES[mnemonic](me,codeB,arg)
end



 _OPCODES = {

-- Generic opcode functions

 	-- arg={lbl.n}
	lbl = function (me,codeB,arg)
		local bytecode = string.format('L%02x',arg[1])
		local codeA = bytecode
		OPCODE(me,bytecode,codeA,codeB)
	end,


  -- arg={}
  op_any = function (me,codeB,arg)
--print("asm::op_any:",arg[1],arg[2],arg[3])
    local bytecode = string.format('%02x %02x',(opcode['op_'..arg[1]])+(typelen[arg[3]] or '0' ),arg[2])
    local codeA = arg[1]..' '..arg[3]..' '..arg[2]
    OPCODE(me,bytecode,codeA,codeB)
  end,

 	-- arg={}
	op1_any = function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_'..arg[1]]))
		local codeA = arg[1]
		OPCODE(me,bytecode,codeA,codeB)
	end,

 	-- arg={}
	op2_any = function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_'..arg[1]]))
		local codeA = arg[1]
		OPCODE(me,bytecode,codeA,codeB,-1)
	end,

-- Specific opcode functions
 	-- arg={}
	op_nop= function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_nop']))
		local codeA = 'nop'
		OPCODE(me,bytecode,codeA,codeB)
	end, 
	
 	-- arg={}
	op_end = function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_end']))
		local codeA = 'end'
		OPCODE(me,bytecode,codeA,codeB)
	end,

 	-- arg={}
	op_return= function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_return']))
		local codeA = 'return'
		OPCODE(me,bytecode,codeA,codeB)
	end, 
	
	-- arg={type}
	op_cast= function (me,codeB,arg)   		
		local bytecode = string.format('%02x',(opcode['op_cast']))
		bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(vartype[arg[1]]*(2^4)))
		local codeA = 'cast '..arg[1]
		OPCODE(me,bytecode,codeA,codeB)
	end, 

	-- arg={ConstValue}
	op_push_c= function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_push_c'])+_TP.getConstLen(arg[1]))
		bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[1]))
		local codeA = 'push_c '..arg[1]
		OPCODE(me,bytecode,codeA,codeB,1)
	end,

	-- arg={type,addr}
	op_push_v= function (me,codeB,arg)
		local bytecode=''
		local codeA = ''
		if (_TP.getConstLen(arg[2]) == 0) then
			bytecode = string.format('%02x',(opcode['op_pushx_v'..(sig[arg[1]] or 'u')])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))
			codeA = 'pushx_v'..(sig[arg[1]] or 'u')..' '..arg[1]..' '..arg[2]
		else
			bytecode = string.format('%02x',(opcode['op_push_v'..(sig[arg[1]] or 'u')])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2],2))
			codeA = 'push_v'..(sig[arg[1]] or 'u')..' '..arg[1]..' '..arg[2]
		end
		OPCODE(me,bytecode,codeA,codeB,1)
	end,
	 
	-- arg={type,&addr}
	op_push_p= function (me,codeB,arg) 
		local bytecode=''
		local codeA = ''
		if (_TP.getConstLen(arg[2]) == 0) then
			bytecode = string.format('%02x',(opcode['op_pushx_p'..(sig[_TP.deref(arg[1])] or 'u')])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))
			codeA = 'pushx_p'..(sig[_TP.deref(arg[1])] or 'u')..' '..arg[1]..' '..arg[2]
		else
			bytecode = string.format('%02x',(opcode['op_push_p'..(sig[_TP.deref(arg[1])] or 'u')])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2],2))
			codeA = 'push_p'..(sig[_TP.deref(arg[1])] or 'u')..' '..arg[1]..' '..arg[2]
		end
		OPCODE(me,bytecode,codeA,codeB,1)
	end, 
	
	-- arg={var_type,Idx_type,Idx_addr,ArrSize,ArrAddr}
	op_pusharr_v= function (me,codeB,arg)
		local bytecode = string.format('%02x %02x',
			(opcode['op_pusharr_v'])+(typelen[arg[1]] or '0' ),
			((sign[arg[1]] or 0)*(2^7) + _TP.getConstLen(arg[4])*(2^6) + typelen[arg[2]]*(2^4) + _TP.getConstLen(arg[3])*(2^2)) + _TP.getConstLen(arg[4])*(2^0))
		bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(arg[5]),_TP.getConstBytes(arg[3]),_TP.getConstBytes(arg[4]))
		local codeA = 'pusharr_v '..arg[1]..' '..arg[5]..' '..arg[2]..' '..arg[3]..' '..arg[4]
		OPCODE(me,bytecode,codeA,codeB,1)
	end, 

	-- arg={type,addr}
	op_pop= function (me,codeB,arg) 
		local bytecode=''
		local codeA = ''
		if (_TP.getConstLen(arg[2]) == 0) then
			bytecode = string.format('%02x',(opcode['op_popx_'..(sig[arg[1]] or 'u')])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))
			codeA = 'popx_'..(sig[arg[1]] or 'u')..' '..arg[1]..' '..arg[2]
		else
			bytecode = string.format('%02x',(opcode['op_pop_'..(sig[arg[1]] or 'u')])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2],2))
			codeA = 'pop_'..(sig[arg[1]] or 'u')..' '..arg[1]..' '..arg[2]
		end
		OPCODE(me,bytecode,codeA,codeB,-1)
	end,
	 

  -- arg={type}
  op_set= function (me,codeB,arg) 
    local bytecode=''
    local codeA = ''
--print("asm::op_set:",arg[1])
    bytecode = string.format('%02x',(opcode['op_pop_'..(sig[arg[1]] or 'u')])+(typelen[arg[1]] or '0' ))
    codeA = 'set'..' '..arg[1]
    OPCODE(me,bytecode,codeA,codeB,-1)
  end,

 
	-- arg={var_type,idx_type,idx_addr,ArrSize,ArrAddr}
	op_poparr_v= function (me,codeB,arg) 
		local bytecode = string.format('%02x %02x',
			(opcode['op_poparr_v'])+(typelen[arg[1]] or '0' ),
			(_TP.getConstLen(arg[5])*(2^6) + typelen[arg[2]]*(2^4) + _TP.getConstLen(arg[3])*(2^2) + _TP.getConstLen(arg[4])*(2^0)))
		bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(arg[5]),_TP.getConstBytes(arg[3]),_TP.getConstBytes(arg[4]))
		local codeA = 'poparr_v '..arg[1]..' '..arg[5]..' '..arg[2]..' '..arg[3]..' '..arg[4]
		OPCODE(me,bytecode,codeA,codeB,-1)	
	end, 

	-- arg={arr_type,arr_addr,idx_type,idx_addr,idx_max,const_val}
	op_setarr_vc= function (me,codeB,arg) 
		local bytecode = string.format('%02x %02x',(opcode['op_setarr_vc'])+typelen[arg[1]],
								_TP.getConstLen(arg[2])*2^7+_TP.getConstLen(arg[4])*2^6 + typelen[arg[3]]*2^4 + _TP.getConstLen(arg[5])*2^3 + _TP.getConstLen(arg[6]))
		bytecode = string.format('%s %s %s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[4]),_TP.getConstBytes(arg[5]),_TP.getConstBytes(arg[6]))
		local codeA = 'setarr_vc '..arg[1]..' '..arg[2]..' '..arg[3]..' '..arg[4]..' '..arg[5]
		OPCODE(me,bytecode,codeA,codeB)
	end, 
	
	-- arg={arr_type,arr_addr,idx_type,idx_addr,idx_max,var_type,var_addr}
	op_setarr_vv= function (me,codeB,arg) 
		local bytecode = string.format('%02x %02x',(opcode['op_setarr_vv'])+typelen[arg[1]],
								_TP.getConstLen(arg[2])*2^7+_TP.getConstLen(arg[4])*2^6 + typelen[arg[3]]*2^4 + _TP.getConstLen(arg[5])*2^3 + _TP.getConstLen(arg[7])*2^2 + typelen[arg[6]])
		bytecode = string.format('%s %s %s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[4]),_TP.getConstBytes(arg[5]),_TP.getConstBytes(arg[7]))
		local codeA = 'setarr_vv '..arg[1]..' '..arg[2]..' '..arg[3]..' '..arg[4]..' '..arg[5]..' '..arg[6]..' '..arg[7]
		OPCODE(me,bytecode,codeA,codeB)
	end, 

 	-- arg={len,addr}
	op_memclr = function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_memclr']) + _TP.getConstLen(arg[2])*2 + _TP.getConstLen(arg[1]))
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[1]))
		local codeA = 'memclr '..arg[2]..' '..arg[1]
		OPCODE(me,bytecode,codeA,codeB)
	end,
	
	-- arg={addr,len}
	op_getextdt_p= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_getextdt_p']) + _TP.getConstLen(arg[1])*2 + _TP.getConstLen(arg[2]))
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]))
		local codeA = 'getextdt_p '..arg[1]..' '..arg[2]
		OPCODE(me,bytecode,codeA,codeB)	
	end, 
	
	-- arg={addr,len}
	op_getextdt_v= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_getextdt_v']) + _TP.getConstLen(arg[1])*2 + _TP.getConstLen(arg[2]))
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]))
		local codeA = 'getextdt_v '..arg[1]..' '..arg[2]
		OPCODE(me,bytecode,codeA,codeB)		
	end, 

	-- arg={addr}
	op_chkret= function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_chkret'])+(_TP.getConstLen(arg[1])))
		bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[1]))
		local codeA = 'chkret '..arg[1]
		OPCODE(me,bytecode,codeA,codeB)
	end,
	
 	-- arg={lbl.n}
	op_exec = function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_exec'])+(_TP.getConstLen(arg[1])))
		bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[1]))
		local codeA = 'exec '..arg[1]
		OPCODE(me,bytecode,codeA,codeB)
	end,
	
 	-- arg={lbl.n,lbl.n}
	op_ifelse= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_ifelse']) + _TP.getConstLen(arg[1])*2 + _TP.getConstLen(arg[2]))
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]))
		local codeA = 'ifelse '..arg[1]..' '..arg[2]
		OPCODE(me,bytecode,codeA,codeB)			
	end, 
	
	-- arg={evt,data_len,const_val}
	op_outevt_c = function (me,codeB,arg)
		local bytecode=''
		local codeA = ''
		if (_TP.getConstLen(arg[1]) == 0 and _TP.getConstLen(arg[2]) == 0) then
			bytecode = string.format('%02x',(opcode['op_outevtx_c']) +  _TP.getConstLen(arg[3]))
			bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3]))		
			codeA = 'outevtx_c '..arg[1]..' '..arg[2]..' '..arg[3]
		else
			bytecode = string.format('%02x %02x',(opcode['op_outevt_c']) +  _TP.getConstLen(arg[1])*2 + _TP.getConstLen(arg[2]),_TP.getConstLen(arg[3])*2^6)
			bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3]))		
			codeA = 'outevt_c '..arg[1]..' '..arg[2]..' '..arg[3]
		end
		OPCODE(me,bytecode,codeA,codeB)			
	end, 

	-- arg={evt,data_len,var_type,var_addr}
	op_outevt_v= function (me,codeB,arg) 
		local bytecode=''
		local codeA = ''
		if (_TP.getConstLen(arg[1]) == 0 and _TP.getConstLen(arg[2]) == 0 and _TP.getConstLen(arg[4]) == 0) then
			bytecode = string.format('%02x',(opcode['op_outevtx_v']) +  (typelen[arg[3]] or 0))
			bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[4]))		
			codeA = 'outevtx_v '..arg[1]..' '..arg[2]..' '..arg[3]..' '..arg[4]
		else
			bytecode = string.format('%02x %02x',(opcode['op_outevt_v']) +  _TP.getConstLen(arg[1])*2 + _TP.getConstLen(arg[2]),
							(typelen[arg[3]] or 0)*2^6 + _TP.getConstLen(arg[4])*2^4)
			bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[4]))		
			codeA = 'outevt_v '..arg[1]..' '..arg[2]..' '..arg[3]..' '..arg[4]
		end
		OPCODE(me,bytecode,codeA,codeB)			
	end,

  -- arg={evt,var_type}
  op_outevt= function (me,codeB,arg) 
    local bytecode=''
    local codeA = ''
      bytecode = string.format('%02x %02x',(opcode['op_outevt_v']),arg[1])
      codeA = 'outevt '..arg[1]
    OPCODE(me,bytecode,codeA,codeB)     
  end,
	 
	-- arg={evt}
	op_outevt_z = function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_outevt_z']) +  _TP.getConstLen(arg[1])*2)
		bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[1]))		
		local codeA = 'outevt_z '..arg[1]
		OPCODE(me,bytecode,codeA,codeB)			
	end, 

 	-- arg={lbl.n,lbl.n}
	op_tkclr= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_tkclr']) + _TP.getConstLen(arg[1])*2 + _TP.getConstLen(arg[2]))
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]))
		local codeA = 'tkclr '..arg[1]..' '..arg[2]
		OPCODE(me,bytecode,codeA,codeB)			
	end, 

 	-- arg={lbl.n}
	op_trg= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_trg'])+(_TP.getConstLen(arg[1])))
		bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[1]))
		local codeA = 'trg '..arg[1]
		OPCODE(me,bytecode,codeA,codeB)	
	end, 
	
	-- arg={var_type,var_addr,const_val}
	op_set_c= function (me,codeB,arg) 
		local p2_len
		local p2_1lenx = 0
		p2_len = 2^typelen[arg[1]]
		if (2^_TP.getConstLen(arg[3]) <= 2^typelen[arg[1]]/2) then p2_1lenx=1 p2_len=p2_len/2 end
		local bytecode = string.format('%02x',(opcode['op_set_c']) +  typelen[arg[1]]*2^2 + _TP.getConstLen(arg[2])*2 + p2_1lenx)
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3],p2_len))		
		local codeA = 'set_c '..arg[1]..' '..arg[2]..' '..arg[3]
		OPCODE(me,bytecode,codeA,codeB)	
	end, 

	-- arg={var_type,var1_addr,var1_addr}	
	op_set_v= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_set_v']) +  typelen[arg[1]]*2^2 + _TP.getConstLen(arg[2])*2 + _TP.getConstLen(arg[3]))
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3]))		
		local codeA = 'set_v '..arg[1]..' '..arg[2]..' '..arg[3]
		OPCODE(me,bytecode,codeA,codeB)		
	end, 

	-- arg={gate,const_time,label}
	op_clken_c= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_clken_c']) +  _TP.getConstLen(arg[1])*2^3 + _TP.getConstLen(arg[3])*2^2 + _TP.getConstLen(arg[2]))
		bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3]))		
		local codeA = 'clken_c '..arg[1]..' '..arg[2]..' '..arg[3]
		OPCODE(me,bytecode,codeA,codeB)		
	end, 

	-- arg={gate,unit, var_type, var_addr,label}
	op_clken_v= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_clken_v']) +  _TP.getConstLen(arg[1])*2^3 + _TP.getConstLen(arg[5])*2^2 + typelen[arg[3]])
		bytecode = string.format('%s %s %s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[4],2),_TP.getConstBytes(arg[5]))
		local codeA = 'clken_v '..arg[1]..' '..arg[2]..' '..arg[3]..' '..arg[4]..' '..arg[5]
		OPCODE(me,bytecode,codeA,codeB)			
	end,
 
	-- arg={stack,label)
	op_tkins_max= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_tkins_max']) +  arg[1]*2^2 + _TP.getConstLen(arg[2]))
		bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))		
		local codeA = 'tkins_max '..arg[1]..' '..arg[2]
		OPCODE(me,bytecode,codeA,codeB)			
	end, 

	-- arg={chk,tree,label)
	op_tkins_z= function (me,codeB,arg) 
		local bytecode = string.format('%02x',(opcode['op_tkins_z']) +  _TP.getConstLen(arg[2])*2^3 + _TP.getConstLen(arg[3])*2^2 + arg[1])
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3]))		
		local codeA = 'tkins_z '..arg[1]..' '..arg[2]..' '..arg[3]
		OPCODE(me,bytecode,codeA,codeB)				
	end, 

  -- arg={gate,label)
  op_asen= function (me,codeB,arg)
--print("asm::op_asen:",arg[1],arg[2]) 
    local bytecode = string.format('%02x',(opcode['op_asen']))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]))   
    local codeA = 'asen '..arg[1]..' '..arg[2]
    OPCODE(me,bytecode,codeA,codeB)       
  end, 

}


