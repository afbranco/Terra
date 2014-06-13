
opcode={
  op_nop=0,
  op_end=1,
  op_return=2,
  op_bnot=3,
  op_lnot=4,
  op_neg=5,
  op_sub=6,
  op_add=7,
  op_mod=8,
  op_mult=9,
  op_div=10,
  op_bor=11,
  op_band=12,
  op_lshft=13,
  op_rshft=14,
  op_bxor=15,
  op_eq=16,
  op_neq=17,
  op_gte=18,
  op_lte=19,
  op_gt=20,
  op_lt=21,
  op_lor=22,
  op_land=23,
  op_set_c=24,
  op_func=25,
  op_outevt_z=26,
  op_outevt_e=27,
  op_pop=28,
  op_popx=32,
  op_poparr_v=36,
  op_push_c=40,
  op_push_p=44,
  op_push_v=48,
  op_pushx_p=52,
  op_pushx_v=56,
  op_pusharr_v=60,
  op_set_e=64,
  op_setarr_vc=68,
  op_setarr_vv=72,
  op_getextdt_p=76,
  op_getextdt_v=80,
  op_cast=84,
  op_inc=88,
  op_dec=92,
  op_incx=96,
  op_decx=100,
  op_outevt_c=104,
  op_outevt_v=108,
  op_outevtx_v=112,
  op_exec=116,
  op_memclr=120,
  op_ifelse=124,
  op_trg=128,
  op_tkins_z=132,
  op_tkclr=136,
  op_chkret=140,
  op_asen=144,
  op_deref=148,
  op_clken_c=160,
  op_clken_v=176,
  op_clken_e=192,
  op_tkins_max=208,
  op_set16_c=224,
  op_set_v=240,
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
		local bytecode = string.format('%02x',(opcode['op_cast']))+typelen[arg[1]]
		local codeA = 'cast '..arg[1]
		OPCODE(me,bytecode,codeA,codeB)
	end, 

  -- arg={type,addr}
  op_inc= function (me,codeB,arg)      
    local bytecode=''
    local codeA = ''
    if (_TP.getConstLen(arg[2]) == 0) then
      bytecode = string.format('%02x',(opcode['op_incx'])+(typelen[arg[1]] or '0' ))
      bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))
      codeA = 'incx'..' '..arg[1]..' '..arg[2]
    else
      bytecode = string.format('%02x',(opcode['op_inc'])+(typelen[arg[1]] or '0' ))
      bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2],2))
      codeA = 'inc'..' '..arg[1]..' '..arg[2]
    end
    OPCODE(me,bytecode,codeA,codeB,-1)
  end, 

  -- arg={type,addr}
  op_dec= function (me,codeB,arg)      
print("asm::op_dec:",_TP.getConstBytes(arg[2],2))
    local bytecode=''
    local codeA = ''
    if (_TP.getConstLen(arg[2]) == 0) then
      bytecode = string.format('%02x',(opcode['op_decx'])+(typelen[arg[1]] or '0' ))
      bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))
      codeA = 'decx'..' '..arg[1]..' '..arg[2]
    else
      bytecode = string.format('%02x',(opcode['op_dec'])+(typelen[arg[1]] or '0' ))
      bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2],2))
      codeA = 'dec'..' '..arg[1]..' '..arg[2]
    end
    OPCODE(me,bytecode,codeA,codeB,-1)
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
			bytecode = string.format('%02x',(opcode['op_pushx_v'])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))
			codeA = 'pushx_v'..' '..arg[1]..' '..arg[2]
		else
			bytecode = string.format('%02x',(opcode['op_push_v'])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2],2))
			codeA = 'push_v'..' '..arg[1]..' '..arg[2]
		end
		OPCODE(me,bytecode,codeA,codeB,1)
	end,
	 
	-- arg={type,&addr}
	op_push_p= function (me,codeB,arg) 
		local bytecode=''
		local codeA = ''
		if (_TP.getConstLen(arg[2]) == 0) then
			bytecode = string.format('%02x',(opcode['op_pushx_p'])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))
			codeA = 'pushx_p'..' '..arg[1]..' '..arg[2]
		else
			bytecode = string.format('%02x',(opcode['op_push_p'])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2],2))
			codeA = 'push_p'..' '..arg[1]..' '..arg[2]
		end
		OPCODE(me,bytecode,codeA,codeB,1)
	end, 
	
	-- arg={var_type,Idx_type,Idx_addr,ArrSize,ArrAddr}
	op_pusharr_v= function (me,codeB,arg)
		local bytecode = string.format('%02x %02x',
			(opcode['op_pusharr_v'])+(typelen[arg[1]] or '0' ),
			(_TP.getConstLen(arg[4])*(2^6) + typelen[arg[2]]*(2^4) + _TP.getConstLen(arg[3])*(2^2)) + _TP.getConstLen(arg[4])*(2^0))
		bytecode = string.format('%s %s %s %s',bytecode,_TP.getConstBytes(arg[5]),_TP.getConstBytes(arg[3]),_TP.getConstBytes(arg[4]))
		local codeA = 'pusharr_v '..arg[1]..' '..arg[5]..' '..arg[2]..' '..arg[3]..' '..arg[4]
		OPCODE(me,bytecode,codeA,codeB,1)
	end, 

	-- arg={type,addr}
	op_pop= function (me,codeB,arg) 
		local bytecode=''
		local codeA = ''
		if (_TP.getConstLen(arg[2]) == 0) then
			bytecode = string.format('%02x',(opcode['op_popx'])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2]))
			codeA = 'popx'..' '..arg[1]..' '..arg[2]
		else
			bytecode = string.format('%02x',(opcode['op_pop'])+(typelen[arg[1]] or '0' ))
			bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[2],2))
			codeA = 'pop'..' '..arg[1]..' '..arg[2]
		end
		OPCODE(me,bytecode,codeA,codeB,-1)
	end,
	 

  -- arg={type}
  op_set_e= function (me,codeB,arg) 
    local bytecode=''
    local codeA = ''
--print("asm::op_set:",arg[1])
    bytecode = string.format('%02x',(opcode['op_set_e'])+(typelen[arg[1]] or '0' ))
    codeA = 'set_e'..' '..arg[1]
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

  -- arg={evt}
  op_outevt_e= function (me,codeB,arg) 
    local bytecode=''
    local codeA = ''
      bytecode = string.format('%02x %02x',(opcode['op_outevt_e']),arg[1])
      codeA = 'outevt_e '..arg[1]
    OPCODE(me,bytecode,codeA,codeB)     
  end,
  	
	-- arg={evt,const_val}
	op_outevt_c = function (me,codeB,arg)
		local bytecode=''
		local codeA = ''
		bytecode = string.format('%02x',(opcode['op_outevt_c']) + _TP.getConstLen(arg[2]))
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]))		
		codeA = 'outevt_c '..arg[1]..' '..arg[2]
		OPCODE(me,bytecode,codeA,codeB)			
	end, 

	-- arg={evt,var_addr,tp}
	op_outevt_v= function (me,codeB,arg) 
		local bytecode=''
		local codeA = ''
    if _TP.getConstLen(arg[2]) == 0 then
      bytecode = string.format('%02x',(opcode['op_outevtx_v']) + typelen[arg[3]])
      bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2],1))   
      codeA = 'outevtx_v '..arg[1]..' '..arg[2]
    else
      bytecode = string.format('%02x',(opcode['op_outevt_v']) + typelen[arg[3]])
      bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2],2))   
      codeA = 'outevt_v '..arg[1]..' '..arg[2]
    end
		OPCODE(me,bytecode,codeA,codeB)			
	end,

 
	-- arg={evt}
	op_outevt_z = function (me,codeB,arg)
		local bytecode = string.format('%02x',(opcode['op_outevt_z']))
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
--		local p2_len
--		local p2_1len
--		p2_len = 2^typelen[arg[1]]
--		if (2^_TP.getConstLen(arg[3]) <= 2^typelen[arg[1]]/2) then p2_1lenx=1 p2_len=p2_len/2 end
--		local bytecode = string.format('%02x',(opcode['op_set_c']) +  typelen[arg[1]]*2^2 + _TP.getConstLen(arg[2])*2 + p2_1lenx)
--		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3],p2_len))		
    if (2^_TP.getConstLen(arg[3]) <= 2) then
      local bytecode = string.format('%02x',(opcode['op_set16_c']) +  typelen[arg[1]]*2^2 + _TP.getConstLen(arg[2])*2 + _TP.getConstLen(arg[3]))
      bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3]))    
      local codeA = 'set16_c '..arg[1]..' '..arg[2]..' '..arg[3]
      OPCODE(me,bytecode,codeA,codeB)     
    else
      local bytecode = string.format('%02x %02x',(opcode['op_set_c']),
           typelen[arg[1]]*2^4 + _TP.getConstLen(arg[2])*2^2 + _TP.getConstLen(arg[3]))
      bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[2]),_TP.getConstBytes(arg[3]))    
      local codeA = 'set_c '..arg[1]..' '..arg[2]..' '..arg[3]
      OPCODE(me,bytecode,codeA,codeB)     
    end
	end, 

  -- arg={funcID}
  op_func= function (me,codeB,arg) 
    local bytecode = string.format('%02x',(opcode['op_func']))
    bytecode = string.format('%s %s',bytecode,_TP.getConstBytes(arg[1]))
    local codeA = 'func '..arg[1]
    OPCODE(me,bytecode,codeA,codeB) 
  end, 


	-- arg={var_type,var1_addr,var2_addr}	
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
  -- arg={gate,unit,label}
  op_clken_e= function (me,codeB,arg) 
print("asm::op_clken_e:",arg[1],arg[2],arg[3])
    local bytecode = string.format('%02x',(opcode['op_clken_e']) +  _TP.getConstLen(arg[1])*2^3 + _TP.getConstLen(arg[3])*2^2 + arg[2])
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[3]))
    local codeA = 'clken_e '..arg[1]..' '..arg[2]..' '..arg[3]
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
		local bytecode = string.format('%02x',(opcode['op_tkins_z']) +  _TP.getConstLen(arg[3])*2 + arg[1])
		bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[2],1),_TP.getConstBytes(arg[3]))		
		local codeA = 'tkins_z '..arg[1]..' '..arg[2]..' '..arg[3]
		OPCODE(me,bytecode,codeA,codeB)				
	end, 

  -- arg={gate,label)
  op_asen= function (me,codeB,arg)
    local bytecode = string.format('%02x',(opcode['op_asen']) + _TP.getConstLen(arg[1])*2 + _TP.getConstLen(arg[2]))
    bytecode = string.format('%s %s %s',bytecode,_TP.getConstBytes(arg[1]),_TP.getConstBytes(arg[2]))
    local codeA = 'asen '..arg[1]..' '..arg[2]
    OPCODE(me,bytecode,codeA,codeB)   end, 

  -- arg={type}
  op_deref= function (me,codeB,arg)      
    local bytecode = string.format('%02x',(opcode['op_deref']))+typelen[arg[1]]
    local codeA = 'deref '..arg[1]
    OPCODE(me,bytecode,codeA,codeB)
  end, 


}


