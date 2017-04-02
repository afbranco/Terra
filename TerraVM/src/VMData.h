#ifndef VMDATA_H
#define VMDATA_H

#define APPNAME "terra"


enum{

	MSG_BUFF_SIZE = 28,
	BLOCK_SIZE = 22, // Must be conform to newProgBlock data structure
	SET_DATA_SIZE = 18, // Must be conform to setDataGR data structure
	SENDGR_DATA_SIZE = 16, // Must be conform to sendDataGR data structure
	SEND_DATA_SIZE = 22, // Must be conform to usrMsg_t data structure

#ifdef VM_MEM_BLKS
	CURRENT_MAX_BLOCKS = VM_MEM_BLKS, // Max memory (in blocks of BLOCK_SIZE) allocated for VM script/data - Defined from Makefile
#else
	CURRENT_MAX_BLOCKS = 24,
#endif

#ifdef GENERAL_MAX__BLKS
	GENERAL_MAX_BLOCKS = GENERAL_MAX__BLKS, // Max memory (in blocks of BLOCK_SIZE) allocated for VM script/data - Defined from Makefile
#else
	GENERAL_MAX_BLOCKS = 100,
#endif
		
};

#endif /* VMDATA_H */
