/***********************************************
 * wdvm - WSNDyn virtual machine project
 * July, 2012
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Configuration: GroupControlC
 * Group control support
 * 
 */

configuration GroupControlC{
	provides interface GroupControl as GrCtl;
}
implementation{
	components GroupControlP;
	components BasicServicesC;
	
	GroupControlP.BSRadio -> BasicServicesC;
	GrCtl = GroupControlP.GrCtl;
	
}