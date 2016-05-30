/***********************************************
 * TerraVM - Terra virtual machine project
 * March, 2014
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
// #include "usrMsg.h"
configuration VMCustomC{
	provides interface VMCustom;
}
implementation{
	components VMCustomP as custom;
	components BasicServicesIxC as BS;
	custom.VM = VMCustom;
	custom.BSRadio -> BS;
	components RandomC;
	custom.Random -> RandomC;

}